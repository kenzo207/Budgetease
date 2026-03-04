import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/accounts_dao.dart';
import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/daos/recurring_charges_dao.dart';
import '../../domain/services/budget_calculator_service.dart';
import '../../domain/services/cycle_manager_service.dart';
import '../../domain/services/transport_manager_service.dart';
import 'database_provider.dart';

part 'budget_provider.g.dart';

/// Provider du budget quotidien
@riverpod
class BudgetProvider extends _$BudgetProvider {
  @override
  Future<double> build() async {
    final database = ref.watch(databaseProvider);

    // 1. Récupérer les paramètres globaux
    final settings = await database.select(database.settings).getSingle();

    // 2. Initialiser les services
    final cycleManager = CycleManagerService(cycle: settings.financialCycle);

    final transportManager = TransportManagerService(
      mode: settings.transportMode,
      dailyCost: settings.dailyTransportCost,
      daysPerWeek: settings.transportDaysPerWeek,
      cycleManager: cycleManager,
    );

    // 3. Initialiser le calculateur de budget
    final matchator = BudgetCalculatorService(
      accountsDao: AccountsDao(database),
      transactionsDao: TransactionsDao(database),
      chargesDao: RecurringChargesDao(database),
      cycleManager: cycleManager,
      transportManager: transportManager,
      savingsGoal: settings.savingsGoal ?? 0.0,
    );

    // 4. Calculer le budget
    return await matchator.calculateDailyBudget();
  }
}
