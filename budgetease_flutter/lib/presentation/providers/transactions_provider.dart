import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/daos/accounts_dao.dart';
import '../providers/accounts_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/notification_provider.dart';
import 'database_provider.dart';

part 'transactions_provider.g.dart';

/// Provider des transactions
@riverpod
class TransactionsProvider extends _$TransactionsProvider {
  @override
  Future<List<Transaction>> build() async {
    final database = ref.watch(databaseProvider);
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
    // Validation: montant strictement positif
    if (amount <= 0) {
      throw ArgumentError('Le montant doit être positif: $amount');
    }

    final database = ref.read(databaseProvider);
    final dao = TransactionsDao(database);

    // Utiliser une transaction DB pour atomicité (éviter les race conditions)
    await database.transaction(() async {
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

      // Mettre à jour les soldes des comptes (dans la même transaction DB)
      await _updateAccountBalances(
        database: database,
        type: type,
        amount: amount,
        accountId: accountId,
        toAccountId: toAccountId,
        feeAmount: feeAmount,
      );
    });

    // Rafraîchir les providers
    ref.invalidateSelf();
    ref.invalidate(accountsProviderProvider);
    ref.invalidate(budgetProviderProvider);

    // Check budget for alerts
    if (type == TransactionType.expense) {
      try {
        final notificationSettings = await ref.read(notificationSettingsProvider.future);
        if (notificationSettings['budget'] == true) {
          final dailyBudget = await ref.read(budgetProviderProvider.future);
          final totalDeduction = amount + (feeAmount ?? 0);

          if (dailyBudget < 0) {
            final notificationService = ref.read(notificationServiceProvider);
            final spentRatio = dailyBudget.abs() > 0
                ? 1.0 + (totalDeduction / dailyBudget.abs())
                : 2.0;
            await notificationService.showBudgetAlert(
              categoryName: 'Budget Quotidien',
              spentPercentage: spentRatio.clamp(0.0, 3.0),
              remainingAmount: dailyBudget,
              currency: 'FCFA',
            );
          } else if (dailyBudget > 0 && totalDeduction > dailyBudget * 0.8) {
            final notificationService = ref.read(notificationServiceProvider);
            await notificationService.showBudgetAlert(
              categoryName: 'Dépense Importante',
              spentPercentage: (totalDeduction / dailyBudget).clamp(0.0, 3.0),
              remainingAmount: dailyBudget - totalDeduction,
              currency: 'FCFA',
            );
          }
        }
      } catch (_) {
        // Ne pas bloquer la transaction si la notification échoue
      }
    }
  }

  /// Mettre à jour les soldes des comptes (appelé dans une transaction DB)
  Future<void> _updateAccountBalances({
    required AppDatabase database,
    required TransactionType type,
    required double amount,
    required int accountId,
    int? toAccountId,
    double? feeAmount,
  }) async {
    final accountsDao = AccountsDao(database);

    switch (type) {
      case TransactionType.expense:
        final account = await accountsDao.getAccountById(accountId);
        if (account != null) {
          final totalDeduction = amount + (feeAmount ?? 0);
          await accountsDao.updateAccountBalance(
            accountId,
            account.currentBalance - totalDeduction,
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
