import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/accounts_dao.dart';
import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/daos/recurring_charges_dao.dart';
import '../../data/database/tables/settings_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../providers/database_provider.dart';
import '../../engine/zolt_engine.dart';
import '../../engine/engine_input_builder.dart';
import '../../engine/engine_output.dart' as eng;
import '../../domain/services/cycle_manager_service.dart';
import '../../domain/services/cycle_snapshot_service.dart';

part 'engine_provider.g.dart';

/// Provider principal du moteur Zolt.
/// 
/// Retourne [ZoltEngineOutput] (depuis le moteur Rust si disponible,
/// sinon calcul Dart en fallback exact).
@riverpod
class ZoltEngineProvider extends _$ZoltEngineProvider {
  @override
  Future<eng.ZoltEngineOutput> build() async {
    final db = ref.watch(databaseProvider);

    final settings     = await db.select(db.settings).getSingle();
    final accountsDao  = AccountsDao(db);
    final txDao        = TransactionsDao(db);
    final chargesDao   = RecurringChargesDao(db);

    final accounts     = await accountsDao.getActiveAccounts();
    final charges      = await chargesDao.getActiveCharges();

    final cycleManager = CycleManagerService(cycle: settings.financialCycle);
    final cycleStart   = cycleManager.getStartOfCycle();
    final cycleEnd     = cycleManager.getEndOfCycle();
    final transactions = await txDao.getTransactionsByPeriod(cycleStart, cycleEnd);

    // ─── Snapshot du cycle précédent (non-bloquant) ──────────────
    final snapshotService = CycleSnapshotService(db);
    await snapshotService.ensureLastCycleSnapshotted();

    // ─── Essaie le moteur Rust ───────────────────────────────────
    if (ZoltEngine.isAvailable) {
      try {
        final input = buildEngineInput(
          accounts:     accounts,
          charges:      charges,
          transactions: transactions,
          settings:     settings,
        );
        // Historique réel des cycles passés (12 derniers max)
        final history = await snapshotService.buildHistory(limit: 12);
        final raw = ZoltEngine.run(input: input, history: history);
        return eng.ZoltEngineOutput.fromJson(raw);
      } catch (_) {
        // Fallback si le moteur Rust échoue
      }
    }

    // ─── Fallback : calcul Dart ──────────────────────────────────
    return _dartFallback(
      accounts:     accounts,
      charges:      charges,
      transactions: transactions,
      settings:     settings,
      cycleManager: cycleManager,
    );
  }

  void refresh() => ref.invalidateSelf();
}

/// Budget journalier (accès rapide)
@riverpod
Future<double> engineDailyBudget(EngineDailyBudgetRef ref) async {
  final output = await ref.watch(zoltEngineProviderProvider.future);
  return output.deterministic.dailyBudget;
}

/// Messages conversationnels du moteur
@riverpod
Future<List<eng.ConversationalMessage>> engineMessages(EngineMessagesRef ref) async {
  final output = await ref.watch(zoltEngineProviderProvider.future);
  return output.messages;
}

/// Prédiction de fin de cycle
@riverpod
Future<eng.EndOfCyclePrediction?> enginePrediction(EnginePredictionRef ref) async {
  final output = await ref.watch(zoltEngineProviderProvider.future);
  return output.prediction;
}

// ─── Fallback Dart ───────────────────────────────────────────────

Future<eng.ZoltEngineOutput> _dartFallback({
  required List<Account> accounts,
  required List<RecurringCharge> charges,
  required List<Transaction> transactions,
  required UserSettings settings,
  required CycleManagerService cycleManager,
}) async {
  final totalBalance  = accounts.fold<double>(0, (s, a) => s + a.currentBalance);
  final savingsGoal   = settings.savingsGoal ?? 0.0;
  final daysRemaining = cycleManager.getDaysRemainingInCycle();

  // Réserve transport (identique à TransportManagerService)
  final daysPerWeek = settings.transportDaysPerWeek ?? 5;
  final transportReserve = settings.transportMode == TransportMode.daily
      ? (settings.dailyTransportCost ?? 0.0) * daysPerWeek * (daysRemaining / 7)
      : 0.0;

  // Réserve charges DYNAMIQUE : amount / max(1, daysUntilDue)
  // (même algorithme que BudgetCalculatorService.getDailyReserveTotal * daysRemaining)
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  double dailyChargeReserve = 0.0;
  double chargesReserve = 0.0;
  for (final c in charges.where((c) => !c.isPaid && c.isActive)) {
    final daysUntilDue = c.dueDate.difference(today).inDays;
    final safeDays = daysUntilDue > 0 ? daysUntilDue : 1;
    dailyChargeReserve += c.amount / safeDays;
    chargesReserve += c.amount;
  }

  final freeMass = (totalBalance - savingsGoal - transportReserve)
      .clamp(0.0, double.infinity);

  final tomorrow = today.add(const Duration(days: 1));

  final spentToday = transactions
      .where((t) =>
          t.type == TransactionType.expense &&
          !t.date.isBefore(today) &&
          t.date.isBefore(tomorrow))
      .fold<double>(0, (s, t) => s + t.amount);

  // Budget de base = freeMass / daysRemaining, moins réserve journalière charges
  final baseDailyBudget = daysRemaining > 0 ? freeMass / daysRemaining : 0.0;
  final dailyBudget     = baseDailyBudget - dailyChargeReserve;
  final remainingToday  = dailyBudget - spentToday;

  return eng.ZoltEngineOutput(
    deterministic: eng.DeterministicResult(
      totalBalance:     totalBalance,
      committedMass:    savingsGoal + transportReserve + chargesReserve,
      freeMass:         freeMass,
      daysRemaining:    daysRemaining,
      dailyBudget:      dailyBudget,
      spentToday:       spentToday,
      remainingToday:   remainingToday,
      transportReserve: transportReserve,
      chargesReserve:   chargesReserve,
    ),
    // Note: profile/prediction restent vides en fallback (pas d'historique)
    profile: const eng.BehavioralProfile(
      rhythm:               'Linear',
      volatilityScore:      0,
      savingsAchievement:   1,
      cyclesObserved:       0,
      hiddenChargesTotal:   0,
    ),
    prediction:  null,
    messages:    [],
    suggestions: [],
    anomalies:   [],
  );
}
