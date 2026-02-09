import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/daos/accounts_dao.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_provider.dart';

part 'transactions_provider.g.dart';

/// Provider des transactions
@riverpod
class TransactionsProvider extends _$TransactionsProvider {
  @override
  Future<List<Transaction>> build() async {
    final database = AppDatabase();
    final dao = TransactionsDao(database);
    return await dao.getAllTransactions();
  }

  /// Créer une nouvelle transaction
  Future<void> createTransaction({
    required double amount,
    required TransactionType type,
    required int categoryId,
    required int accountId,
    required DateTime date,
    int? toAccountId,
    double? feeAmount,
    bool isException = false,
    int? scopeDuration,
    String? scopeType,
    String? description,
  }) async {
    final database = AppDatabase();
    final dao = TransactionsDao(database);

    final transaction = TransactionsCompanion.insert(
      amount: amount,
      type: type,
      categoryId: Value(categoryId),
      accountId: accountId,
      toAccountId: Value(toAccountId),
      date: date,
      feeAmount: Value(feeAmount),
      isException: Value(isException),
      scopeDuration: Value(scopeDuration),
      scopeType: Value(scopeType),
      description: Value(description),
      createdAt: DateTime.now(),
    );

    await dao.insertTransaction(transaction);

    // Mettre à jour les soldes des comptes
    await _updateAccountBalances(
      type: type,
      amount: amount,
      accountId: accountId,
      toAccountId: toAccountId,
      feeAmount: feeAmount,
    );

    // Rafraîchir les providers
    ref.invalidateSelf();
    ref.invalidate(accountsProviderProvider);
    ref.invalidate(budgetProviderProvider);
  }

  Future<void> _updateAccountBalances({
    required TransactionType type,
    required double amount,
    required int accountId,
    int? toAccountId,
    double? feeAmount,
  }) async {
    final database = AppDatabase();
    final accountsDao = AccountsDao(database);

    switch (type) {
      case TransactionType.expense:
        final account = await accountsDao.getAccountById(accountId);
        if (account != null) {
          await accountsDao.updateAccountBalance(
            accountId,
            account.currentBalance - amount,
          );
        }
        break;

      case TransactionType.income:
        final account = await accountsDao.getAccountById(accountId);
        if (account != null) {
          await accountsDao.updateAccountBalance(
            accountId,
            account.currentBalance + amount,
          );
        }
        break;

      case TransactionType.transfer:
        final sourceAccount = await accountsDao.getAccountById(accountId);
        if (sourceAccount != null) {
          await accountsDao.updateAccountBalance(
            accountId,
            sourceAccount.currentBalance - amount - (feeAmount ?? 0),
          );
        }

        if (toAccountId != null) {
          final destAccount = await accountsDao.getAccountById(toAccountId);
          if (destAccount != null) {
            await accountsDao.updateAccountBalance(
              toAccountId,
              destAccount.currentBalance + amount,
            );
          }
        }
        break;
    }
  }
}
