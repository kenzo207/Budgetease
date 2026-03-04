import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/recurring_charges_table.dart';

part 'recurring_charges_dao.g.dart';

/// DAO pour la gestion des charges fixes
@DriftAccessor(tables: [RecurringCharges])
class RecurringChargesDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringChargesDaoMixin {
  RecurringChargesDao(super.db);

  /// Toutes les charges
  Future<List<RecurringCharge>> getAllCharges() =>
      select(recurringCharges).get();

  /// Charges actives
  Future<List<RecurringCharge>> getActiveCharges() {
    return (select(recurringCharges)
          ..where((c) => c.isActive.equals(true))
          ..orderBy([(c) => OrderingTerm.asc(c.dueDate)]))
        .get();
  }

  /// Charges actives non payées
  Future<List<RecurringCharge>> getUnpaidCharges() {
    return (select(recurringCharges)
          ..where((c) => c.isActive.equals(true) & c.isPaid.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.dueDate)]))
        .get();
  }

  /// Charge la plus urgente non payée (pour le widget HomeScreen)
  Future<RecurringCharge?> getMostUrgentCharge() async {
    final charges = await getUnpaidCharges();
    if (charges.isEmpty) return null;
    return charges.first; // trié par dueDate asc
  }

  /// Charge par ID
  Future<RecurringCharge?> getChargeById(int id) {
    return (select(recurringCharges)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Créer une charge
  Future<int> insertCharge(RecurringChargesCompanion charge) =>
      into(recurringCharges).insert(charge);

  /// Mettre à jour une charge
  Future<bool> updateCharge(RecurringCharge charge) =>
      update(recurringCharges).replace(charge);

  /// Marquer une charge comme payée
  Future<void> markAsPaid(int chargeId) {
    return (update(recurringCharges)..where((c) => c.id.equals(chargeId)))
        .write(const RecurringChargesCompanion(isPaid: Value(true)));
  }

  /// Réinitialiser les statuts payés (début de nouveau cycle)
  Future<void> resetAllPaidStatus() {
    return update(recurringCharges)
        .write(const RecurringChargesCompanion(isPaid: Value(false)));
  }

  /// Désactivation douce
  Future<void> deactivateCharge(int chargeId) {
    return (update(recurringCharges)..where((c) => c.id.equals(chargeId)))
        .write(const RecurringChargesCompanion(isActive: Value(false)));
  }

  /// Supprimer définitivement
  Future<void> deleteCharge(int chargeId) {
    return (delete(recurringCharges)..where((c) => c.id.equals(chargeId)))
        .go();
  }

  /// ═══════════════════════════════════════════════════════
  /// ALGORITHME : Réserve journalière dynamique par charge
  /// ═══════════════════════════════════════════════════════
  ///
  /// Pour chaque charge active non payée :
  ///   jours = max(1, dueDate.difference(today).inDays)
  ///   réserve_j += amount / jours
  ///
  /// Résultat : montant à "bloquer" chaque jour pour couvrir
  /// toutes les charges à venir avant leur échéance.
  Future<double> getDailyReserveTotal() async {
    final charges = await getUnpaidCharges();
    final today = DateTime.now();
    double reserve = 0;

    for (final charge in charges) {
      final daysUntilDue =
          charge.dueDate.difference(today).inDays;
      final safeDays = daysUntilDue > 0 ? daysUntilDue : 1;
      reserve += charge.amount / safeDays;
    }

    return reserve;
  }

  /// Réserve journalière pour UNE charge spécifique
  static double dailyReserveFor(RecurringCharge charge) {
    final today = DateTime.now();
    final days = charge.dueDate.difference(today).inDays;
    final safeDays = days > 0 ? days : 1;
    return charge.amount / safeDays;
  }

  /// Montant total des charges non payées (pour rétrocompat)
  Future<double> getTotalUnpaidAmount() async {
    final unpaid = await getUnpaidCharges();
    return unpaid.fold<double>(0.0, (sum, c) => sum + c.amount);
  }

  /// Charges à échéance dans N jours
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
