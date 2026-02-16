import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/accounts_table.dart';

part 'accounts_dao.g.dart';

/// DAO pour la gestion des comptes
@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  /// Récupérer tous les comptes
  Future<List<Account>> getAllAccounts() => select(accounts).get();

  /// Récupérer les comptes actifs uniquement
  Future<List<Account>> getActiveAccounts() {
    return (select(accounts)..where((a) => a.isActive.equals(true))).get();
  }

  /// Récupérer un compte par ID
  Future<Account?> getAccountById(int id) {
    return (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  /// Créer un nouveau compte
  Future<int> insertAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  /// Mettre à jour un compte
  Future<bool> updateAccount(Account account) {
    return update(accounts).replace(account);
  }

  /// Mettre à jour le solde d'un compte
  Future<void> updateAccountBalance(int accountId, double newBalance) {
    return (update(accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(
        currentBalance: Value(newBalance),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Désactiver un compte (soft delete)
  Future<void> deactivateAccount(int accountId) {
    return (update(accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Calculer le solde total de tous les comptes actifs
  Future<double> getTotalBalance() async {
    final activeAccounts = await getActiveAccounts();
    return activeAccounts.fold<double>(0.0, (sum, account) => sum + account.currentBalance);
  }

  /// Récupérer les comptes par type
  Future<List<Account>> getAccountsByType(AccountType type) {
    return (select(accounts)
          ..where((a) => a.type.equals(type.index) & a.isActive.equals(true)))
        .get();
  }
}
