import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recurring_incomes_table.dart';

part 'recurring_incomes_dao.g.dart';

/// DAO pour la gestion des revenus réguliers programmés
@DriftAccessor(tables: [RecurringIncomes])
class RecurringIncomesDao extends DatabaseAccessor<AppDatabase> with _$RecurringIncomesDaoMixin {
  RecurringIncomesDao(super.db);

  /// Récupérer tous les revenus réguliers actifs
  Future<List<RecurringIncome>> getActiveIncomes() {
    return (select(recurringIncomes)
          ..where((i) => i.isActive.equals(true))
          ..orderBy([(i) => OrderingTerm.asc(i.nextDepositDate)]))
        .get();
  }

  /// Récupérer un revenu spécifique par ID
  Future<RecurringIncome?> getIncomeById(int id) {
    return (select(recurringIncomes)..where((i) => i.id.equals(id))).getSingleOrNull();
  }

  /// Créer un nouveau revenu régulier
  Future<int> insertIncome(RecurringIncomesCompanion income) {
    return into(recurringIncomes).insert(income);
  }

  /// Mettre à jour un revenu existant
  Future<bool> updateIncome(RecurringIncome income) {
    return update(recurringIncomes).replace(income);
  }

  /// Désactiver un revenu (Soft Delete)
  Future<int> deactivateIncome(int id) {
    return (update(recurringIncomes)..where((i) => i.id.equals(id))).write(
      const RecurringIncomesCompanion(
        isActive: Value(false),
      ),
    );
  }

  /// Récupérer les revenus dont la date prévue est dépassée (à valider)
  Future<List<RecurringIncome>> getPendingIncomes(DateTime until) {
    return (select(recurringIncomes)
          ..where((i) => 
              i.isActive.equals(true) & 
              i.nextDepositDate.isSmallerOrEqualValue(until)
          )
          ..orderBy([(i) => OrderingTerm.asc(i.nextDepositDate)]))
        .get();
  }
}
