import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recurring_charges_table.dart';

part 'recurring_charges_dao.g.dart';

/// DAO pour la gestion des charges fixes
@DriftAccessor(tables: [RecurringCharges])
class RecurringChargesDao extends DatabaseAccessor<AppDatabase> with _$RecurringChargesDaoMixin {
  RecurringChargesDao(super.db);

  /// Récupérer toutes les charges fixes
  Future<List<RecurringCharge>> getAllCharges() => select(recurringCharges).get();

  /// Récupérer les charges actives
  Future<List<RecurringCharge>> getActiveCharges() {
    return (select(recurringCharges)..where((c) => c.isActive.equals(true))).get();
  }

  /// Récupérer les charges non payées
  Future<List<RecurringCharge>> getUnpaidCharges() {
    return (select(recurringCharges)
          ..where((c) => c.isActive.equals(true) & c.isPaid.equals(false)))
        .get();
  }

  /// Récupérer une charge par ID
  Future<RecurringCharge?> getChargeById(int id) {
    return (select(recurringCharges)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// Créer une nouvelle charge
  Future<int> insertCharge(RecurringChargesCompanion charge) {
    return into(recurringCharges).insert(charge);
  }

  /// Mettre à jour une charge
  Future<bool> updateCharge(RecurringCharge charge) {
    return update(recurringCharges).replace(charge);
  }

  /// Marquer une charge comme payée
  Future<void> markAsPaid(int chargeId) {
    return (update(recurringCharges)..where((c) => c.id.equals(chargeId))).write(
      const RecurringChargesCompanion(isPaid: Value(true)),
    );
  }

  /// Réinitialiser le statut de paiement de toutes les charges
  Future<void> resetAllPaidStatus() {
    return update(recurringCharges).write(
      const RecurringChargesCompanion(isPaid: Value(false)),
    );
  }

  /// Calculer le montant total des charges non payées
  Future<double> getTotalUnpaidAmount() async {
    final unpaid = await getUnpaidCharges();
    return unpaid.fold<double>(0.0, (sum, charge) => sum + charge.amount);
  }

  /// Désactiver une charge (soft delete)
  Future<void> deactivateCharge(int chargeId) {
    return (update(recurringCharges)..where((c) => c.id.equals(chargeId))).write(
      const RecurringChargesCompanion(isActive: Value(false)),
    );
  }

  /// Récupérer les charges arrivant à échéance bientôt
  Future<List<RecurringCharge>> getDueSoonCharges(int daysAhead) {
    final now = DateTime.now();
    final deadline = now.add(Duration(days: daysAhead));
    
    return (select(recurringCharges)
          ..where((c) =>
              c.isActive.equals(true) &
              c.isPaid.equals(false) &
              c.dueDate.isBiggerOrEqualValue(now) &
              c.dueDate.isSmallerOrEqualValue(deadline)))
        .get();
  }
}
