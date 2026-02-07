import 'package:hive/hive.dart';
import 'package:isar/isar.dart';
import 'package:budgetease_flutter/models/transaction.dart' as hive_models;
import 'package:budgetease_flutter/models/settings.dart' as hive_models;
import 'package:budgetease_flutter/models/fixed_charge.dart' as hive_models;
import 'package:budgetease_flutter/models_isar/transaction_isar.dart';
import 'package:budgetease_flutter/models_isar/wallet_isar.dart';
import 'package:budgetease_flutter/models_isar/shield_item_isar.dart';
import 'package:budgetease_flutter/models_isar/settings_isar.dart';
import 'package:budgetease_flutter/services/security_manager.dart';

/// Migrates data from Hive to Isar with encryption
class HiveToIsarMigrator {
  final Isar isar;
  
  HiveToIsarMigrator(this.isar);

  /// Main migration method
  Future<MigrationResult> migrate() async {
    print('🔄 Starting Hive → Isar migration...');

    final result = MigrationResult();

    try {
      // 1. Migrate Settings
      result.settingsMigrated = await _migrateSettings();

      // 2. Create default wallets
      result.walletsCreated = await _createDefaultWallets();

      // 3. Migrate Transactions
      result.transactionsMigrated = await _migrateTransactions();

      // 4. Migrate Fixed Charges → Shield Items
      result.shieldItemsMigrated = await _migrateFixedCharges();

      print('✅ Migration completed successfully!');
      print('   Settings: ${result.settingsMigrated}');
      print('   Wallets: ${result.walletsCreated}');
      print('   Transactions: ${result.transactionsMigrated}');
      print('   Shield Items: ${result.shieldItemsMigrated}');

      result.success = true;
    } catch (e) {
      print('❌ Migration failed: $e');
      result.success = false;
      result.error = e.toString();
    }

    return result;
  }

  /// Migrate settings from Hive to Isar
  Future<int> _migrateSettings() async {
    final settingsBox = await Hive.openBox<hive_models.Settings>('settings');

    if (settingsBox.isEmpty) {
      print('ℹ️ No settings to migrate');
      return 0;
    }

    final oldSettings = settingsBox.getAt(0);
    if (oldSettings == null) return 0;

    final newSettings = SettingsIsar(
      currency: oldSettings.currency,
      notificationEnabled: oldSettings.notificationEnabled,
      notificationTime: oldSettings.notificationTime,
      onboardingCompleted: oldSettings.onboardingCompleted,
      favoriteCategories: oldSettings.favoriteCategories,
      budgetPeriod: oldSettings.budgetPeriod,
      sosAmount: oldSettings.sosAmount,
      updatedAt: DateTime.now(),
    );

    await isar.writeTxn(() async {
      await isar.settingsIsars.put(newSettings);
    });

    print('✓ Settings migrated');
    return 1;
  }

  /// Create default wallets
  Future<int> _createDefaultWallets() async {
    final wallets = [
      WalletIsar(
        name: 'Cash',
        type: WalletType.cash,
        balance: 0.0,
        icon: '💵',
        color: '#4CAF50',
        createdAt: DateTime.now(),
      ),
      WalletIsar(
        name: 'MTN MoMo',
        type: WalletType.momoMtn,
        balance: 0.0,
        icon: '📱',
        color: '#FFD700',
        createdAt: DateTime.now(),
      ),
      WalletIsar(
        name: 'Orange Money',
        type: WalletType.momoOrange,
        balance: 0.0,
        icon: '🍊',
        color: '#FF6600',
        createdAt: DateTime.now(),
      ),
    ];

    await isar.writeTxn(() async {
      await isar.walletIsars.putAll(wallets);
    });

    print('✓ Default wallets created');
    return wallets.length;
  }

  /// Migrate transactions from Hive to Isar
  Future<int> _migrateTransactions() async {
    final transactionsBox = await Hive.openBox<hive_models.Transaction>('transactions');

    if (transactionsBox.isEmpty) {
      print('ℹ️ No transactions to migrate');
      return 0;
    }

    final newTransactions = <TransactionIsar>[];

    for (var oldTx in transactionsBox.values) {
      final newTx = TransactionIsar(
        type: _mapTransactionType(oldTx.type),
        date: oldTx.date,
        amount: oldTx.amount,
        category: oldTx.category,
        sourceWallet: _mapPaymentMethod(oldTx.paymentMethod),
        note: oldTx.note,
        isShieldRelated: false,
        createdAt: oldTx.createdAt,
        incomeFrequency: oldTx.incomeFrequency,
        shadowSavings: oldTx.shadowSavings,
      );

      newTransactions.add(newTx);
    }

    await isar.writeTxn(() async {
      await isar.transactionIsars.putAll(newTransactions);
    });

    print('✓ ${newTransactions.length} transactions migrated');
    return newTransactions.length;
  }

  /// Migrate fixed charges to shield items
  Future<int> _migrateFixedCharges() async {
    final fixedChargesBox = await Hive.openBox<hive_models.FixedCharge>('fixedCharges');

    if (fixedChargesBox.isEmpty) {
      print('ℹ️ No fixed charges to migrate');
      return 0;
    }

    final shieldItems = <ShieldItemIsar>[];

    for (var charge in fixedChargesBox.values) {
      final shield = ShieldItemIsar(
        title: charge.title,
        type: ShieldType.fixedCharge,
        amount: charge.amount,
        frequency: _mapFrequency(charge.frequency),
        nextDueDate: charge.nextDueDate,
        isActive: charge.isActive,
        createdAt: DateTime.now(),
      );

      shieldItems.add(shield);
    }

    await isar.writeTxn(() async {
      await isar.shieldItemIsars.putAll(shieldItems);
    });

    print('✓ ${shieldItems.length} fixed charges → shield items migrated');
    return shieldItems.length;
  }

  /// Map old transaction type to new enum
  TransactionType _mapTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'expense':
        return TransactionType.expense;
      case 'income':
        return TransactionType.income;
      default:
        return TransactionType.expense;
    }
  }

  /// Map old payment method to new wallet type
  WalletType _mapPaymentMethod(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('momo') || lower.contains('mobile')) {
      return WalletType.momoMtn; // Default to MTN
    } else if (lower.contains('cash')) {
      return WalletType.cash;
    } else if (lower.contains('carte') || lower.contains('card')) {
      return WalletType.bankCard;
    }
    return WalletType.cash; // Default
  }

  /// Map frequency string to enum
  RecurringFrequency _mapFrequency(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return RecurringFrequency.daily;
      case 'weekly':
        return RecurringFrequency.weekly;
      case 'monthly':
        return RecurringFrequency.monthly;
      case 'yearly':
        return RecurringFrequency.yearly;
      default:
        return RecurringFrequency.monthly;
    }
  }

  /// Close Hive after successful migration
  static Future<void> closeHive() async {
    await Hive.close();
    print('🗑️ Hive closed (data preserved for rollback)');
  }
}

/// Migration result tracker
class MigrationResult {
  bool success = false;
  String? error;
  int settingsMigrated = 0;
  int walletsCreated = 0;
  int transactionsMigrated = 0;
  int shieldItemsMigrated = 0;

  int get totalItemsMigrated =>
      settingsMigrated + walletsCreated + transactionsMigrated + shieldItemsMigrated;

  @override
  String toString() {
    if (!success) return 'Migration failed: $error';

    return '''
Migration successful ✅
- Settings: $settingsMigrated
- Wallets: $walletsCreated
- Transactions: $transactionsMigrated
- Shield Items: $shieldItemsMigrated
Total: $totalItemsMigrated items migrated
    ''';
  }
}
