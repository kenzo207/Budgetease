import 'dart:convert';
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/settings_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/daos/accounts_dao.dart';
import '../../data/database/daos/cycle_records_dao.dart';
import 'cycle_manager_service.dart';

/// Service de création et récupération des snapshots de cycles financiers.
///
/// Responsabilités :
///   1. À chaque démarrage, détecter si le cycle précédent n'a pas encore
///      de snapshot → le créer automatiquement depuis les transactions.
///   2. Construire les payloads JSON compatibles `Vec<CycleRecord>` pour le
///      moteur Zolt (format défini dans zolt_engine/src/adaptive/mod.rs).
class CycleSnapshotService {
  final AppDatabase _db;

  CycleSnapshotService(this._db);

  // ─── API publique ────────────────────────────────────────────

  /// Vérifie et crée le snapshot du cycle précédent si manquant.
  /// À appeler au démarrage (dans engine_provider ou main).
  Future<void> ensureLastCycleSnapshotted() async {
    try {
      final settings = await _db.select(_db.settings).getSingle();
      final cycleManager = CycleManagerService(cycle: settings.financialCycle);

      final prevEnd   = _previousCycleEnd(cycleManager, settings.financialCycle);
      final prevStart = _previousCycleStart(prevEnd, settings.financialCycle);

      final dao = CycleRecordsDao(_db);
      if (await dao.hasRecordForCycle(prevStart, prevEnd)) return;

      // Construire le snapshot depuis les transactions passées
      final txDao       = TransactionsDao(_db);
      final accountsDao = AccountsDao(_db);

      final transactions = await txDao.getTransactionsByPeriod(prevStart, prevEnd);
      final accounts     = await accountsDao.getActiveAccounts();

      if (transactions.isEmpty) return; // Rien à snapshoter

      final openingBalance = accounts.fold<double>(0, (s, a) => s + a.currentBalance);
      final totalIncome    = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (s, t) => s + t.amount);
      final totalExpenses  = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (s, t) => s + t.amount);
      final closingBalance = openingBalance + totalIncome - totalExpenses;

      // Dépenses journalières
      final dailyMap = <int, double>{};
      for (final t in transactions.where((t) => t.type == TransactionType.expense)) {
        final day = t.date.difference(prevStart).inDays;
        dailyMap[day] = (dailyMap[day] ?? 0) + t.amount;
      }
      final totalDays = prevEnd.difference(prevStart).inDays + 1;
      final dailyExpenses = List<double>.generate(
        totalDays,
        (i) => dailyMap[i] ?? 0.0,
      );

      // Totaux par catégorie  [[catId, total], ...]
      final categoryMap = <String, double>{};
      for (final t in transactions.where((t) => t.type == TransactionType.expense)) {
        if (t.categoryId != null) {
          final key = t.categoryId!.toString();
          categoryMap[key] = (categoryMap[key] ?? 0) + t.amount;
        }
      }
      final categoryTotals = categoryMap.entries
          .map((e) => [e.key, e.value])
          .toList();

      final savingsGoal = settings.savingsGoal ?? 0.0;

      await dao.insertRecord(CycleRecordsCompanion.insert(
        cycleStart:        prevStart,
        cycleEnd:          prevEnd,
        openingBalance:    openingBalance,
        closingBalance:    closingBalance,
        totalIncome:       totalIncome,
        totalExpenses:     totalExpenses,
        savingsGoal:       savingsGoal,
        savingsAchieved:   (closingBalance - (openingBalance - savingsGoal))
                               .clamp(0.0, savingsGoal),
        dailyExpensesJson: Value(jsonEncode(dailyExpenses)),
        categoryTotalsJson: Value(jsonEncode(categoryTotals)),
        createdAt:         DateTime.now(),
      ));

      // Garder seulement les 24 derniers cycles
      await dao.pruneOldRecords(keepLast: 24);
    } catch (e) {
      // Non-fatal : un snapshot manquant ne bloque pas l'app
      print('⚠️ CycleSnapshotService: snapshot création échouée: $e');
    }
  }

  /// Retourne les N derniers cycles sous forme de List<Map<String, dynamic>>
  /// compatible `Vec<CycleRecord>` pour `ZoltEngine.run(history: ...)`.  
  Future<List<Map<String, dynamic>>> buildHistory({int limit = 12}) async {
    final dao     = CycleRecordsDao(_db);
    final records = await dao.getLastN(limit);
    if (records.isEmpty) return [];

    return records.map((r) {
      final dailyExpenses  = (jsonDecode(r.dailyExpensesJson)  as List)
          .map((e) => (e as num).toDouble())
          .toList();
      final categoryTotals = (jsonDecode(r.categoryTotalsJson) as List)
          .map((e) {
            final pair = e as List;
            return [pair[0] as String, (pair[1] as num).toDouble()];
          })
          .toList();

      return {
        'cycle_start': {
          'year':  r.cycleStart.year,
          'month': r.cycleStart.month,
          'day':   r.cycleStart.day,
        },
        'cycle_end': {
          'year':  r.cycleEnd.year,
          'month': r.cycleEnd.month,
          'day':   r.cycleEnd.day,
        },
        'opening_balance':   r.openingBalance,
        'closing_balance':   r.closingBalance,
        'total_income':      r.totalIncome,
        'total_expenses':    r.totalExpenses,
        'savings_goal':      r.savingsGoal,
        'savings_achieved':  r.savingsAchieved,
        'daily_expenses':    dailyExpenses,
        'category_totals':   categoryTotals,
        'transactions':      <dynamic>[], // Pas envoyé en history (trop lourd)
      };
    }).toList();
  }  // ─── Helpers privés ──────────────────────────────────────────

  /// Fin du cycle précédent = veille du début du cycle actuel
  DateTime _previousCycleEnd(
      CycleManagerService mgr, FinancialCycle cycle) {
    final currentStart = mgr.getStartOfCycle();
    return currentStart.subtract(const Duration(seconds: 1));
  }

  /// Début du cycle précédent, en reculant d'un cycle depuis sa fin
  DateTime _previousCycleStart(DateTime prevEnd, FinancialCycle cycle) {
    switch (cycle) {
      case FinancialCycle.monthly:
        return DateTime(prevEnd.year, prevEnd.month, 1);
      case FinancialCycle.weekly:
        final startOfPrevWeek = prevEnd
            .subtract(Duration(days: prevEnd.weekday - 1));
        return DateTime(
            startOfPrevWeek.year, startOfPrevWeek.month, startOfPrevWeek.day);
      case FinancialCycle.daily:
        return DateTime(prevEnd.year, prevEnd.month, prevEnd.day);
      case FinancialCycle.irregular:
        return DateTime(prevEnd.year, prevEnd.month, 1);
    }
  }
}
