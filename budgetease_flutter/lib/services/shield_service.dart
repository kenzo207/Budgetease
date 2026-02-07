import 'package:drift/drift.dart';
import 'package:budgetease_flutter/database/app_database.dart';
import 'package:budgetease_flutter/database/shield_items_table.dart';

/// Service for managing Shield items (fixed charges, debts, SOS)
class ShieldService {
  final AppDatabase database;

  ShieldService(this.database);

  // ========== CRUD Operations ==========

  /// Get all shield items
  Future<List<ShieldItemData>> getAllShieldItems() async {
    return await database.select(database.shieldItems).get();
  }

  /// Get active shield items only
  Future<List<ShieldItemData>> getActiveShieldItems() async {
    return await (database.select(database.shieldItems)
          ..where((s) => s.isActive.equals(true)))
        .get();
  }

  /// Get shield items by type
  Future<List<ShieldItemData>> getShieldItemsByType(ShieldType type) async {
    return await (database.select(database.shieldItems)
          ..where((s) => s.type.equals(type.index) & s.isActive.equals(true)))
        .get();
  }

  /// Get shield item by ID
  Future<ShieldItemData?> getShieldItemById(int id) async {
    return await (database.select(database.shieldItems)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// Create or update shield item
  Future<int> saveShieldItem(ShieldItemsCompanion item) async {
    return await database.into(database.shieldItems).insert(
          item,
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Delete shield item (soft delete)
  Future<void> deactivateShieldItem(int itemId) async {
    await (database.update(database.shieldItems)
          ..where((s) => s.id.equals(itemId)))
        .write(const ShieldItemsCompanion(isActive: Value(false)));
  }

  /// Mark shield item as paid for this period
  Future<void> markAsPaid(int itemId) async {
    await (database.update(database.shieldItems)
          ..where((s) => s.id.equals(itemId)))
        .write(const ShieldItemsCompanion(isPaid: Value(true)));
  }

  /// Reset all shield items to unpaid (for new period)
  Future<void> resetAllPaidStatus() async {
    await database.update(database.shieldItems).write(
          const ShieldItemsCompanion(isPaid: Value(false)),
        );
  }

  // ========== Calculations ==========

  /// Calculate total monthly shield amount
  Future<double> calculateMonthlyShieldTotal() async {
    final items = await getActiveShieldItems();
    double total = 0.0;

    for (var item in items) {
      total += _convertToMonthly(item.amount, item.frequency);
    }

    return total;
  }

  /// Calculate daily shield allocation
  Future<double> calculateDailyShieldAllocation() async {
    final monthly = await calculateMonthlyShieldTotal();
    return monthly / 30; // Average days per month
  }

  /// Get unpaid shield items
  Future<List<ShieldItemData>> getUnpaidItems() async {
    return await (database.select(database.shieldItems)
          ..where((s) => s.isActive.equals(true) & s.isPaid.equals(false)))
        .get();
  }

  /// Get total unpaid amount
  Future<double> getUnpaidAmount() async {
    final unpaid = await getUnpaidItems();
    return unpaid.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  // ========== Helpers ==========

  /// Convert any frequency to monthly amount
  double _convertToMonthly(double amount, RecurrenceFrequency frequency) {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return amount * 30;
      case RecurrenceFrequency.weekly:
        return amount * 4;
      case RecurrenceFrequency.monthly:
        return amount;
      case RecurrenceFrequency.yearly:
        return amount / 12;
      case RecurrenceFrequency.oneTime:
        return 0.0; // One-time items don't count in recurring
    }
  }

  /// Check if any items are due soon (within 7 days)
  Future<List<ShieldItemData>> getDueSoonItems() async {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    final allItems = await getActiveShieldItems();
    return allItems.where((item) {
      return item.dueDate.isAfter(now) && item.dueDate.isBefore(weekFromNow);
    }).toList();
  }
}
