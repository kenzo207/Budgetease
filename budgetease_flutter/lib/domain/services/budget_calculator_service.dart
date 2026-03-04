import '../../data/database/daos/accounts_dao.dart';
import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/daos/recurring_charges_dao.dart';
import 'cycle_manager_service.dart';
import 'transport_manager_service.dart';

/// Service de calcul du budget quotidien
/// 
/// ═══════════════════════════════════════════════════════
/// ALGORITHME ZOLT v4.1 — Réserve journalière dynamique
/// ═══════════════════════════════════════════════════════
///
/// Budget journalier effectif :
///
///   B_j = (Solde - Épargne - Transport_reserve) / Jours_restants
///       - Σ (charge_i.amount / max(1, jours_avant_due_i))
///
/// La réserve par charge s'ADAPTE dynamiquement :
///   - À J-30 → loyer 150k = 5 000/j (doux)
///   - À J-10  → loyer 150k = 15 000/j (attention)
///   - À J-3   → loyer 150k = 50 000/j (signal fort)
///
/// Résultat : pression naturelle à épargner tôt.
/// ═══════════════════════════════════════════════════════
class BudgetCalculatorService {
  final AccountsDao accountsDao;
  final TransactionsDao transactionsDao;
  final RecurringChargesDao chargesDao;
  final CycleManagerService cycleManager;
  final TransportManagerService transportManager;
  final double savingsGoal;

  BudgetCalculatorService({
    required this.accountsDao,
    required this.transactionsDao,
    required this.chargesDao,
    required this.cycleManager,
    required this.transportManager,
    required this.savingsGoal,
  });

  /// Budget journalier disponible (peut être négatif = en dette)
  Future<double> calculateDailyBudget() async {
    // 1. Solde total sur tous les comptes actifs
    final totalBalance = await accountsDao.getTotalBalance();

    // 2. Réserve transport (fixe sur le cycle)
    final transportReserve = transportManager.calculateTransportReserve();

    // 3. Argent vraiment libre pour vivre (hors charges, épargne, transport)
    final freeBalance = totalBalance - savingsGoal - transportReserve;

    // 4. Jours restants dans le cycle courant (min 1)
    final daysRemaining = cycleManager.getDaysRemainingInCycle();

    // 5. Budget journalier de base avant réserves charges
    final baseDailyBudget = freeBalance / daysRemaining;

    // 6. Réserve journalière dynamique Σ (amount / days_until_due)
    final dailyChargeReserve = await chargesDao.getDailyReserveTotal();

    // 7. Budget final = base moins réserve charges
    return baseDailyBudget - dailyChargeReserve;
  }

  /// Dépenses uniquement du jour courant
  Future<double> getTodayExpenses() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await transactionsDao.getTotalExpenses(startOfDay, endOfDay);
  }

  /// Budget restant pour aujourd'hui
  Future<double> getRemainingBudgetToday() async {
    final dailyBudget = await calculateDailyBudget();
    final todayExpenses = await getTodayExpenses();
    return dailyBudget - todayExpenses;
  }

  /// Pourcentage du budget journalier utilisé
  Future<double> getBudgetUsagePercentage() async {
    final dailyBudget = await calculateDailyBudget();
    if (dailyBudget.abs() < 0.01) return 0.0;
    final todayExpenses = await getTodayExpenses();
    return (todayExpenses / dailyBudget) * 100;
  }

  /// Vrai si le budget est dépassé
  Future<bool> isBudgetExceeded() async {
    final remaining = await getRemainingBudgetToday();
    return remaining < 0;
  }
}
