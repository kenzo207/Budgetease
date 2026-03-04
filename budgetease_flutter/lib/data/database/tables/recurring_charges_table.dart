import 'package:drift/drift.dart';

/// Types de charges fixes
enum ChargeType {
  rent,        // Loyer
  electricity, // Électricité
  water,       // Eau
  internet,    // Internet
  school,      // Scolarité
  transport,   // Transport fixe
  other,       // Autre
}

/// Cycles de paiement
enum ChargeCycle {
  monthly,     // Mensuel
  weekly,      // Hebdomadaire
  daily,       // Quotidien
}

/// Table des charges fixes récurrentes
@DataClassName('RecurringCharge')
class RecurringCharges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get type => intEnum<ChargeType>()();
  RealColumn get amount => real()();
  /// Montant déjà payé pour cette charge (paiement partiel possible)
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get dueDate => dateTime()();
  IntColumn get cycle => intEnum<ChargeCycle>()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}
