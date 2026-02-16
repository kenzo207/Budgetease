import '../../data/database/daos/accounts_dao.dart';
import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/daos/recurring_charges_dao.dart';
import 'cycle_manager_service.dart';
import 'transport_manager_service.dart';

/// Service de calcul du budget quotidien
/// Implémente l'algorithme central de BudgetEase v4.0
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

  /// Calculer le budget quotidien disponible
  /// 
  /// Formule :
  /// Daily Cap = (Solde Total - Charges Fixes Non Payées - Épargne - Réserve Transport) / Jours Restants
  Future<double> calculateDailyBudget() async {
    // 1. Récupérer le solde total de tous les comptes actifs
    final totalBalance = await accountsDao.getTotalBalance();

    // 2. Calculer les charges fixes non payées
    final unpaidCharges = await chargesDao.getTotalUnpaidAmount();

    // 3. Calculer la réserve transport
    final transportReserve = transportManager.calculateTransportReserve();

    // 4. Calculer l'argent disponible pour vivre
    final availableForLiving = totalBalance - unpaidCharges - savingsGoal - transportReserve;

    // 5. Obtenir les jours restants dans le cycle
    final daysRemaining = cycleManager.getDaysRemainingInCycle();

    // 6. Si aucun jour restant ou solde négatif, retourner 0
    if (daysRemaining == 0 || availableForLiving <= 0) {
      return 0.0;
    }

    // 7. Diviser par les jours restants
    return availableForLiving / daysRemaining;
  }

  /// Calculer le montant dépensé aujourd'hui
  Future<double> getTodayExpenses() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await transactionsDao.getTotalExpenses(startOfDay, endOfDay);
  }

  /// Calculer le budget quotidien restant pour aujourd'hui
  Future<double> getRemainingBudgetToday() async {
    final dailyBudget = await calculateDailyBudget();
    final todayExpenses = await getTodayExpenses();
    return dailyBudget - todayExpenses;
  }

  /// Calculer le pourcentage du budget quotidien utilisé
  Future<double> getBudgetUsagePercentage() async {
    final dailyBudget = await calculateDailyBudget();
    if (dailyBudget == 0) return 0.0;

    final todayExpenses = await getTodayExpenses();
    return (todayExpenses / dailyBudget) * 100;
  }

  /// Vérifier si le budget quotidien est dépassé
  Future<bool> isBudgetExceeded() async {
    final remaining = await getRemainingBudgetToday();
    return remaining < 0;
  }
}
