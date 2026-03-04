import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/accounts_dao.dart';
import 'database_provider.dart';

part 'accounts_provider.g.dart';

/// Provider des comptes
@riverpod
class AccountsProvider extends _$AccountsProvider {
  @override
  Future<List<Account>> build() async {
    final database = ref.watch(databaseProvider);
    final dao = AccountsDao(database);
    return await dao.getActiveAccounts();
  }
}
