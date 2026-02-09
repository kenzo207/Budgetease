import 'package:drift/drift.dart';

/// Daily Snapshots table - tracks daily budget state
@DataClassName('DailySnapshotData')
class DailySnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  /// The date this snapshot applies to
  DateTimeColumn get date => dateTime()();
  
  /// Calculated daily cap for this day
  RealColumn get dailyCap => real()();
  
  /// Total spent on this day
  RealColumn get totalSpent => real().withDefault(const Constant(0.0))();
  
  /// Remaining from daily cap
  RealColumn get remaining => real()();
  
  /// Carry over from previous day
  RealColumn get carryOver => real().withDefault(const Constant(0.0))();
  
  /// Was previous day's money carried over?
  BoolColumn get wasCarriedOver => boolean().withDefault(const Constant(false))();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
}
