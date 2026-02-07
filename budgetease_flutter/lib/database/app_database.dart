import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Import tables
import 'transactions_table.dart';
import 'wallets_table.dart';
import 'shield_items_table.dart';
import 'daily_snapshots_table.dart';
import 'settings_table.dart';

part 'app_database.g.dart';

/// Main database class for BudgetEase
@DriftDatabase(tables: [
  Transactions,
  Wallets,
  ShieldItems,
  DailySnapshots,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  /// Create default wallets on first launch
  Future<void> initializeDefaultWallets() async {
    final existing = await select(wallets).get();
    
    if (existing.isNotEmpty) {
      return;
    }

    await batch((batch) {
      batch.insertAll(wallets, [
        WalletsCompanion.insert(
          name: 'Cash',
          type: WalletType.cash,
          icon: '💵',
          color: '#4CAF50',
          createdAt: DateTime.now(),
        ),
        WalletsCompanion.insert(
          name: 'MTN MoMo',
          type: WalletType.momoMtn,
          icon: '📱',
          color: '#FFD700',
          createdAt: DateTime.now(),
        ),
        WalletsCompanion.insert(
          name: 'Orange Money',
          type: WalletType.momoOrange,
          icon: '🍊',
          color: '#FF6600',
          createdAt: DateTime.now(),
        ),
      ]);
    });

    print('✅ Default wallets created');
  }
}

/// Database connection helper
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'budgetease.db'));
    
    return NativeDatabase(file);
  });
}
