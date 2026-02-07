import 'package:drift/drift.dart';

/// Shield item types
enum ShieldType {
  fixedCharge, // Recurring bills
  debt,        // Debts to pay off
  sos,         // Emergency fund
}

/// Recurrence frequency for shield items
enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
  oneTime,
}

/// Shield Items table - fixed charges, debts, SOS fund
@DataClassName('ShieldItemData')
class ShieldItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  /// Type of shield item
  IntColumn get type => intEnum<ShieldType>()();
  
  /// Display name
  TextColumn get name => text()();
  
  /// Amount in FCFA
  RealColumn get amount => real()();
  
  /// How often does this recur?
  IntColumn get frequency => intEnum<RecurrenceFrequency>()();
  
  /// Next due date
  DateTimeColumn get dueDate => dateTime()();
  
  /// Has been paid this period?
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  
  /// Is this shield item active?
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
}
