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
import '../../domain/services/notification_service.dart';

part 'engine_provider.g.dart';

/// Provider principal du moteur Zolt.
///
/// Utilise [ZoltEngine.session] (v1.3) si disponible → retourne [SessionState].
/// Sinon replie sur [ZoltEngine.run] (V2) → wrappé en [SessionState] minimal.
/// En dernier recours, calcul Dart pur.
@riverpod
class ZoltEngineProvider extends _$ZoltEngineProvider {
  @override
  Future<eng.SessionState> build() async {
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
      final input = buildEngineInput(
        accounts:     accounts,
        charges:      charges,
        transactions: transactions,
        settings:     settings,
      );
      final history = await snapshotService.buildHistory(limit: 12);

      // ── Tentative zolt_session (v1.3 — pipeline complet) ──────
      try {
        final raw = ZoltEngine.session(
          engineInput: input,
          history:     history,
        );
        final session = eng.SessionState.fromJson(raw);

        // Déclencher les notifications décidées par le moteur (non-bloquant)
        _dispatchNotifications(session.engine.notifications);

        return session;
      } catch (_) {
        // zolt_session non disponible → essai zolt_run
      }

      // ── Tentative zolt_run (v1.2 — pas de SessionState complet) ─
      try {
        final raw    = ZoltEngine.run(input: input, history: history);
        final output = eng.ZoltEngineOutputV2.fromJson(raw);

        // Déclencher les notifications retournées par V2
        _dispatchNotifications(output.notifications);

        return _wrapV2AsSession(output, cycleManager);
      } catch (_) {
        // Fallback Dart
      }
    }

    // ─── Fallback : calcul Dart ──────────────────────────────────
    final dartOutput = await _dartFallback(
      accounts:     accounts,
      charges:      charges,
      transactions: transactions,
      settings:     settings,
      cycleManager: cycleManager,
    );
    return _wrapV2AsSession(dartOutput, cycleManager);
  }

  void refresh() => ref.invalidateSelf();
}

// ─────────────────────────────────────────────────────────────
// Providers dérivés (accès rapides)
// ─────────────────────────────────────────────────────────────

/// Budget journalier
@riverpod
Future<double> engineDailyBudget(EngineDailyBudgetRef ref) async {
  final session = await ref.watch(zoltEngineProviderProvider.future);
  return session.dailyBudget;
}

/// Messages conversationnels du moteur
@riverpod
Future<List<eng.ConversationalMessage>> engineMessages(EngineMessagesRef ref) async {
  final session = await ref.watch(zoltEngineProviderProvider.future);
  return session.messages;
}

/// Prédiction de fin de cycle
@riverpod
Future<eng.EndOfCyclePrediction?> enginePrediction(EnginePredictionRef ref) async {
  final session = await ref.watch(zoltEngineProviderProvider.future);
  return session.prediction;
}

/// Score de santé financière
@riverpod
Future<eng.HealthScore> engineHealthScore(EngineHealthScoreRef ref) async {
  final session = await ref.watch(zoltEngineProviderProvider.future);
  return session.health;
}

/// État du cycle courant
@riverpod
Future<eng.CycleDetectionResult> engineCycleStatus(EngineCycleStatusRef ref) async {
  final session = await ref.watch(zoltEngineProviderProvider.future);
  return session.cycle;
}

/// Suivi des charges récurrentes
@riverpod
Future<List<eng.ChargeTrackingResult>> engineChargeTracking(EngineChargeTrackingRef ref) async {
  final session = await ref.watch(zoltEngineProviderProvider.future);
  return session.chargeTracking;
}

/// Rapport d'intégrité des données
@riverpod
Future<eng.IntegrityReport> engineIntegrity(EngineIntegrityRef ref) async {
  final session = await ref.watch(zoltEngineProviderProvider.future);
  return session.integrity;
}

/// Analytics d'un mois donné via zolt_analytics.
/// [month] = DateTime(year, month, 1) — seuls year et month comptent.
/// Retourne null si le moteur n'est pas disponible.
@riverpod
Future<eng.AnalyticsResult?> engineAnalytics(
  EngineAnalyticsRef ref,
  DateTime month,
) async {
  final db = ref.watch(databaseProvider);
  if (!ZoltEngine.isAvailable) return null;

  final txDao      = TransactionsDao(db);
  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd   = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  final transactions = await txDao.getTransactionsByPeriod(monthStart, monthEnd);

  final snapshotService = CycleSnapshotService(db);
  final history = await snapshotService.buildHistory(limit: 6);

  try {
    final raw = ZoltEngine.analytics(analyticsInput: {
      'transactions': transactions.map((t) => {
        'id':          t.id.toString(),
        'date': {'year': t.date.year, 'month': t.date.month, 'day': t.date.day},
        'amount':        t.amount,
        'tx_type':       t.type == TransactionType.expense ? 'Expense' : t.type == TransactionType.income ? 'Income' : 'TransferOut',
        'category':      t.categoryId?.toString(),
        'account_id':    t.accountId.toString(),
        'description':   t.description,
        'sms_confidence': null,
      }).toList(),
      'cycle_start': {'year': monthStart.year, 'month': monthStart.month, 'day': monthStart.day},
      'cycle_end':   {'year': monthEnd.year,   'month': monthEnd.month,   'day': monthEnd.day},
      'history': history,
    });
    return eng.AnalyticsResult.fromJson(raw);
  } catch (_) {
    return null;
  }
}

/// Expose les inputs bruts du moteur pour les fonctionnalités avancées (Simulateur, Credit Score)
@riverpod
Future<Map<String, dynamic>> engineRawInput(EngineRawInputRef ref) async {
  final db           = ref.watch(databaseProvider);
  final settings     = await db.select(db.settings).getSingle();
  final accounts     = await AccountsDao(db).getActiveAccounts();
  final charges      = await RecurringChargesDao(db).getActiveCharges();

  final cycleManager = CycleManagerService(cycle: settings.financialCycle);
  final transactions = await TransactionsDao(db).getTransactionsByPeriod(
    cycleManager.getStartOfCycle(), 
    cycleManager.getEndOfCycle()
  );

  final input = buildEngineInput(
    accounts:     accounts,
    charges:      charges,
    transactions: transactions,
    settings:     settings,
  );
  
  final history = await CycleSnapshotService(db).buildHistory(limit: 12);
  
  return {
    'input': input,
    'history': history,
  };
}

// ─────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────

/// Dispatch les notifications décidées par le moteur Rust.
void _dispatchNotifications(List<eng.NotificationTrigger> triggers) {
  if (triggers.isEmpty) return;
  final notifService = NotificationService();
  for (final t in triggers) {
    notifService.dispatchEngineNotification(t).catchError((_) {});
  }
}

/// Wraps un [ZoltEngineOutputV2] en [SessionState] avec valeurs par défaut
/// (utilisé quand zolt_session n'est pas disponible).
eng.SessionState _wrapV2AsSession(
  eng.ZoltEngineOutputV2 output,
  CycleManagerService cycleManager,
) {
  final daysRemaining = cycleManager.getDaysRemainingInCycle();
  final totalDays     = cycleManager.getTotalDaysInCycle();
  final currentDay    = (totalDays - daysRemaining).clamp(1, totalDays);
  final pct           = totalDays > 0 ? currentDay / totalDays : 0.0;

  return eng.SessionState(
    engine: output,
    health: const eng.HealthScore(
      score: 0, grade: 'Fair', budget: 0, savings: 0,
      stability: 0, prediction: 0, trend: 0, message: '',
    ),
    cycle: eng.CycleDetectionResult(
      status:     'Active',
      currentDay: currentDay,
      totalDays:  totalDays,
      pctElapsed: pct,
    ),
    chargeTracking:  const [],
    triage:          const [],
    integrity: const eng.IntegrityReport(
      isValid: true, errors: [], warnings: [], autoFixed: [], dataConfidence: 100,
    ),
    computedAtEpoch: DateTime.now().millisecondsSinceEpoch ~/ 1000,
  );
}

// ─────────────────────────────────────────────────────────────
// Fallback Dart
// ─────────────────────────────────────────────────────────────

Future<eng.ZoltEngineOutputV2> _dartFallback({
  required List<Account> accounts,
  required List<RecurringCharge> charges,
  required List<Transaction> transactions,
  required UserSettings settings,
  required CycleManagerService cycleManager,
}) async {
  final totalBalance  = accounts.fold<double>(0, (s, a) => s + a.currentBalance);
  final savingsGoal   = settings.savingsGoal;
  final daysRemaining = cycleManager.getDaysRemainingInCycle();

  final daysPerWeek = settings.transportDaysPerWeek ?? 5;
  final transportReserve = settings.transportMode == TransportMode.daily
      ? (settings.dailyTransportCost ?? 0.0) * daysPerWeek * (daysRemaining / 7.0)
      : 0.0;

  final now   = DateTime.now();
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

  final baseDailyBudget = daysRemaining > 0 ? freeMass / daysRemaining : 0.0;
  final dailyBudget     = baseDailyBudget - dailyChargeReserve;
  final remainingToday  = dailyBudget - spentToday;

  return eng.ZoltEngineOutputV2(
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
    profile: const eng.BehavioralProfile(
      rhythm: 'Linear', volatilityScore: 0,
      savingsAchievement: 1, cyclesObserved: 0, hiddenChargesTotal: 0,
    ),
    prediction:       null,
    messages:         const [],
    suggestions:      const [],
    anomalies:        const [],
    incomePrediction: null,
    notifications:    const [],
  );
}
