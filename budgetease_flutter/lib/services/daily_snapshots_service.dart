import 'package:drift/drift.dart';
import 'package:budgetease_flutter/database/app_database.dart';
import 'package:budgetease_flutter/database/daily_snapshots_table.dart';

/// Service for managing daily budget snapshots
class DailySnapshotsService {
  final AppDatabase database;

  DailySnapshotsService(this.database);

  // ========== CRUD Operations ==========

  /// Get snapshot for a specific date
  Future<DailySnapshotData?> getSnapshotForDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    return await (database.select(database.dailySnapshots)
          ..where((s) => s.date.equals(dateOnly)))
        .getSingleOrNull();
  }

  /// Get today's snapshot
  Future<DailySnapshotData?> getTodaySnapshot() async {
    return await getSnapshotForDate(DateTime.now());
  }

  /// Create or update snapshot
  Future<int> saveSnapshot(DailySnapshotsCompanion snapshot) async {
    return await database.into(database.dailySnapshots).insert(
          snapshot,
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Get snapshot history (last N days)
  Future<List<DailySnapshotData>> getSnapshotHistory({int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    return await (database.select(database.dailySnapshots)
          ..where((s) => s.date.isBiggerOrEqualValue(startDate))
          ..orderBy([(s) => OrderingTerm.desc(s.date)]))
        .get();
  }

  /// Get snapshot range
  Future<List<DailySnapshotData>> getSnapshotRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await (database.select(database.dailySnapshots)
          ..where((s) => 
              s.date.isBiggerOrEqualValue(startDate) &
              s.date.isSmallerOrEqualValue(endDate))
          ..orderBy([(s) => OrderingTerm.asc(s.date)]))
        .get();
  }

  // ========== Statistics ==========

  /// Calculate average daily spending over last N days
  Future<double> getAverageDailySpending({int days = 30}) async {
    final snapshots = await getSnapshotHistory(days: days);
    
    if (snapshots.isEmpty) return 0.0;
    
    final totalSpent = snapshots.fold<double>(
      0.0,
      (sum, snapshot) => sum + snapshot.totalSpent,
    );
    
    return totalSpent / snapshots.length;
  }

  /// Get total carry over in last N days
  Future<double> getTotalCarryOver({int days = 30}) async {
    final snapshots = await getSnapshotHistory(days: days);
    
    return snapshots.fold<double>(
      0.0,
      (sum, snapshot) => sum + snapshot.carryOver,
    );
  }

  /// Count days with carry over
  Future<int> getDaysWithCarryOver({int days = 30}) async {
    final snapshots = await getSnapshotHistory(days: days);
    
    return snapshots.where((s) => s.wasCarriedOver).length;
  }

  /// Get best day (highest remaining)
  Future<DailySnapshotData?> getBestDay({int days = 30}) async {
    final snapshots = await getSnapshotHistory(days: days);
    
    if (snapshots.isEmpty) return null;
    
    snapshots.sort((a, b) => b.remaining.compareTo(a.remaining));
    return snapshots.first;
  }

  /// Get worst day (lowest remaining or most overspent)
  Future<DailySnapshotData?> getWorstDay({int days = 30}) async {
    final snapshots = await getSnapshotHistory(days: days);
    
    if (snapshots.isEmpty) return null;
    
    snapshots.sort((a, b) => a.remaining.compareTo(b.remaining));
    return snapshots.first;
  }

  // ========== Cleanup ==========

  /// Delete snapshots older than N days
  Future<void> cleanupOldSnapshots({int keepDays = 90}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
    
    await (database.delete(database.dailySnapshots)
          ..where((s) => s.date.isSmallerThanValue(cutoffDate)))
        .go();
  }
}
