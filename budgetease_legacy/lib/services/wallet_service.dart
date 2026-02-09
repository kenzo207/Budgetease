import 'package:drift/drift.dart';
import 'package:budgetease_flutter/database/app_database.dart';
import 'package:budgetease_flutter/database/wallets_table.dart';
import 'package:budgetease_flutter/database/transactions_table.dart';
import 'package:budgetease_flutter/utils/money.dart';

/// Service for managing multiple wallets (Cash, MoMo, etc.)
class WalletService {
  final AppDatabase database;

  WalletService(this.database);

  // ========== Wallet CRUD ==========

  /// Get all wallets
  Future<List<WalletData>> getAllWallets() async {
    return await database.select(database.wallets).get();
  }

  /// Get active wallets only
  Future<List<WalletData>> getActiveWallets() async {
    return await (database.select(database.wallets)
          ..where((w) => w.isActive.equals(true)))
        .get();
  }

  /// Get wallet by ID
  Future<WalletData?> getWalletById(int id) async {
    return await (database.select(database.wallets)
          ..where((w) => w.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get wallet by type
  Future<WalletData?> getWalletByType(WalletType type) async {
    return await (database.select(database.wallets)
          ..where((w) => w.type.equals(type.index)))
        .getSingleOrNull();
  }

  /// Create or update wallet
  Future<int> saveWallet(WalletsCompanion wallet) async {
    return await database.into(database.wallets).insert(
          wallet,
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Delete wallet (soft delete - mark as inactive)
  Future<void> deactivateWallet(int walletId) async {
    await (database.update(database.wallets)
          ..where((w) => w.id.equals(walletId)))
        .write(const WalletsCompanion(isActive: Value(false)));
  }

  // ========== Balance Management ==========

  /// Get total balance across all active wallets
  Future<Money> getTotalBalance(String currency) async {
    final wallets = await getActiveWallets();

    if (wallets.isEmpty) {
      return Money.zero(currency);
    }

    final amounts = wallets.map((w) => Money(w.balance, currency)).toList();
    return amounts.sum();
  }

  /// Get balance of specific wallet
  Future<Money> getWalletBalance(WalletType type, String currency) async {
    final wallet = await getWalletByType(type);
    if (wallet == null) return Money.zero(currency);

    return Money(wallet.balance, currency);
  }

  /// Update wallet balance directly (for manual adjustments)
  Future<void> updateBalance(int walletId, double newBalance) async {
    await (database.update(database.wallets)
          ..where((w) => w.id.equals(walletId)))
        .write(WalletsCompanion(balance: Value(newBalance)));
  }

  // ========== Transfers ==========

  /// Transfer money between wallets
  Future<TransactionData> transferBetweenWallets({
    required WalletType fromWallet,
    required WalletType toWallet,
    required Money amount,
    String? note,
  }) async {
    // Validate different wallets
    if (fromWallet == toWallet) {
      throw ArgumentError('Cannot transfer to the same wallet');
    }

    // Validate amount
    if (amount.isNegative || amount.isZero) {
      throw ArgumentError('Transfer amount must be positive');
    }

    late TransactionData transfer;

    await database.transaction(() async {
      // Get wallets
      final from = await getWalletByType(fromWallet);
      final to = await getWalletByType(toWallet);

      if (from == null || to == null) {
        throw StateError('Wallet not found');
      }

      // Check sufficient balance
      if (from.balance < amount.amount) {
        throw StateError(
          'Insufficient balance in ${from.name}. '
          'Available: ${from.balance}, Required: ${amount.amount}',
        );
      }

      // Update balances
      await updateBalance(from.id, from.balance - amount.amount);
      await updateBalance(to.id, to.balance + amount.amount);

      // Create transfer transaction
      final transactionId = await database.into(database.transactions).insert(
            TransactionsCompanion.insert(
              type: TransactionType.transfer,
              date: DateTime.now(),
              amount: amount.amount,
              category: 'Transfer',
              sourceWallet: fromWallet,
              destinationWallet: Value(toWallet),
              note: Value(note ?? 'Transfer from ${from.name} to ${to.name}'),
              createdAt: DateTime.now(),
            ),
          );

      // Retrieve the created transaction
      final result = await (database.select(database.transactions)
            ..where((t) => t.id.equals(transactionId)))
          .getSingle();
      transfer = result;
    });

    print('✅ Transfer completed: $amount from $fromWallet to $toWallet');
    return transfer;
  }

  /// Get transfer history
  Future<List<TransactionData>> getTransferHistory({int limit = 50}) async {
    return await (database.select(database.transactions)
          ..where((t) => t.type.equals(TransactionType.transfer.index))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .get();
  }

  // ========== Statistics ==========

  /// Get wallet with highest balance
  Future<WalletData?> getRichestWallet() async {
    final wallets = await getActiveWallets();
    if (wallets.isEmpty) return null;

    wallets.sort((a, b) => b.balance.compareTo(a.balance));
    return wallets.first;
  }

  /// Get distribution of funds across wallets
  Future<Map<String, double>> getBalanceDistribution() async {
    final wallets = await getActiveWallets();
    final total = await getTotalBalance('FCFA');

    final distribution = <String, double>{};

    for (var wallet in wallets) {
      final percentage = total.isZero
          ? 0.0
          : (wallet.balance / total.amount) * 100;
      distribution[wallet.name] = percentage;
    }

    return distribution;
  }

  // ========== Initialization ==========

  /// Initialize default wallets if none exist
  Future<void> initializeDefaultWallets() async {
    await database.initializeDefaultWallets();
  }

  /// Add custom wallet
  Future<int> addCustomWallet({
    required String name,
    required String icon,
    required String color,
    WalletType type = WalletType.other,
    double initialBalance = 0.0,
  }) async {
    return await database.into(database.wallets).insert(
          WalletsCompanion.insert(
            name: name,
            type: type,
            balance: Value(initialBalance),
            icon: icon,
            color: color,
            createdAt: DateTime.now(),
          ),
        );
  }
}
