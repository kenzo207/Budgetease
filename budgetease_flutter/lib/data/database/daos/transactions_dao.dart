import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';
import '../tables/categories_table.dart';
import '../tables/accounts_table.dart';

part 'transactions_dao.g.dart';

/// DAO pour la gestion des transactions
@DriftAccessor(tables: [Transactions, Categories, Accounts])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  /// Récupérer toutes les transactions
  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();
  }

  /// Récupérer les transactions d'une période
  Future<List<Transaction>> getTransactionsByPeriod(DateTime start, DateTime end) {
    return (select(transactions)
          ..where((t) => t.date.isBiggerOrEqualValue(start) & t.date.isSmallerOrEqualValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Récupérer les transactions par type
  Future<List<Transaction>> getTransactionsByType(TransactionType type) {
    return (select(transactions)
          ..where((t) => t.type.equals(type.index))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Récupérer les transactions par compte
  Future<List<Transaction>> getTransactionsByAccount(int accountId) {
    return (select(transactions)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Créer une nouvelle transaction
  Future<int> insertTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Mettre à jour une transaction
  Future<bool> updateTransaction(Transaction transaction) {
    return update(transactions).replace(transaction);
  }

  /// Supprimer une transaction
  Future<int> deleteTransaction(int transactionId) {
    return (delete(transactions)..where((t) => t.id.equals(transactionId))).go();
  }

  /// Calculer le total des dépenses pour une période (montant + frais)
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    final expenses = await (select(transactions)
          ..where((t) =>
              t.type.equals(TransactionType.expense.index) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .get();
    
    return expenses.fold<double>(0.0, (sum, t) => sum + t.amount + (t.feeAmount ?? 0));
  }

  /// Calculer le total des revenus pour une période
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    final income = await (select(transactions)
          ..where((t) =>
              t.type.equals(TransactionType.income.index) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .get();
    
    return income.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  /// Récupérer les dépenses exceptionnelles
  Future<List<Transaction>> getExceptionalExpenses() {
    return (select(transactions)
          ..where((t) => t.isException.equals(true))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Récupérer les revenus temporaires actifs
  Future<List<Transaction>> getActiveTemporaryIncomes() {
    return (select(transactions)
          ..where((t) =>
              t.type.equals(TransactionType.income.index) &
              t.scopeType.equals('temporary') &
              t.scopeDuration.isBiggerThanValue(0)))
        .get();
  }
}
