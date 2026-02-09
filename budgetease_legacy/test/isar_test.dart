import 'package:flutter_test/flutter_test.dart';
import 'package:budgetease_flutter/services/security_manager.dart';
import 'package:budgetease_flutter/models_isar/transaction_isar.dart';
import 'package:budgetease_flutter/models_isar/wallet_isar.dart';
import 'package:budgetease_flutter/models_isar/shield_item_isar.dart';
import 'package:budgetease_flutter/models_isar/daily_snapshot_isar.dart';
import 'package:isar/isar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Isar Schema Tests', () {
    late Isar isar;

    setUp(() async {
      // Initialize encryption
      await SecurityManager.initializeEncryption();

      // Open Isar with all schemas
      isar = await SecurityManager.openSecureIsar(
        schemes: [
          TransactionIsarSchema,
          WalletIsarSchema,
          ShieldItemIsarSchema,
          DailySnapshotIsarSchema,
        ],
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('Create and read Transaction', () async {
      final transaction = TransactionIsar(
        type: TransactionType.expense,
        date: DateTime.now(),
        amount: 2500.0,
        category: 'Alimentation',
        sourceWallet: WalletType.cash,
        isShieldRelated: false,
        createdAt: DateTime.now(),
      );

      // Write
      await isar.writeTxn(() async {
        await isar.transactionIsars.put(transaction);
      });

      // Read
      final retrieved = await isar.transactionIsars.get(transaction.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.amount, 2500.0);
      expect(retrieved.category, 'Alimentation');
      expect(retrieved.type, TransactionType.expense);
    });

    test('Create and read Wallet', () async {
      final wallet = WalletIsar(
        name: 'Cash',
        type: WalletType.cash,
        balance: 25000.0,
        icon: '💵',
        color: '#4CAF50',
        createdAt: DateTime.now(),
      );

      await isar.writeTxn(() async {
        await isar.walletIsars.put(wallet);
      });

      final retrieved = await isar.walletIsars.get(wallet.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Cash');
      expect(retrieved.balance, 25000.0);
    });

    test('Create and read ShieldItem', () async {
      final shield = ShieldItemIsar(
        title: 'Loyer',
        type: ShieldType.fixedCharge,
        amount: 50000.0,
        frequency: RecurringFrequency.monthly,
        nextDueDate: DateTime.now().add(Duration(days: 15)),
        createdAt: DateTime.now(),
      );

      await isar.writeTxn(() async {
        await isar.shieldItemIsars.put(shield);
      });

      final retrieved = await isar.shieldItemIsars.get(shield.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Loyer');
      expect(retrieved.amount, 50000.0);
      expect(retrieved.type, ShieldType.fixedCharge);
    });

    test('Create and read DailySnapshot', () async {
      final snapshot = DailySnapshotIsar(
        date: DateTime.now(),
        dailyCapAllocated: 3500.0,
        spent: 2000.0,
        carriedOver: 500.0,
        createdAt: DateTime.now(),
      );

      await isar.writeTxn(() async {
        await isar.dailySnapshotIsars.put(snapshot);
      });

      final retrieved = await isar.dailySnapshotIsars.get(snapshot.id);

      expect(retrieved, isNotNull);
      expect(retrieved!.dailyCapAllocated, 3500.0);
      expect(retrieved.spent, 2000.0);
      expect(retrieved.remaining, 1500.0);
      expect(retrieved.saved, 1500.0);
    });

    test('Transaction transfer type', () async {
      final transfer = TransactionIsar(
        type: TransactionType.transfer,
        date: DateTime.now(),
        amount: 10000.0,
        category: 'Transfer',
        sourceWallet: WalletType.momoMtn,
        destinationWallet: WalletType.cash,
        isShieldRelated: false,
        createdAt: DateTime.now(),
      );

      expect(transfer.isTransfer, true);

      final nonTransfer = TransactionIsar(
        type: TransactionType.expense,
        date: DateTime.now(),
        amount: 1000.0,
        category: 'Food',
        sourceWallet: WalletType.cash,
        isShieldRelated: false,
        createdAt: DateTime.now(),
      );

      expect(nonTransfer.isTransfer, false);
    });
  });
}
