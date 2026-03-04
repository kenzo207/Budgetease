import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/sms_parser_service.dart';
import '../../domain/services/notification_service.dart';
import '../../data/database/app_database.dart';
import 'database_provider.dart';

part 'sms_parser_provider.g.dart';

/// Provider du service de parsing SMS
@riverpod
SmsParserService smsParserService(SmsParserServiceRef ref) {
  final database = ref.watch(databaseProvider);
  return SmsParserService(database: database);
}

/// Provider des transactions en attente
@riverpod
class PendingTransactions extends _$PendingTransactions {
  @override
  Future<List<PendingTransaction>> build() async {
    final service = ref.read(smsParserServiceProvider);
    return await service.getPendingTransactions();
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Scanner les SMS et mettre à jour la liste
  /// Envoie une notification si de nouvelles transactions sont trouvées
  Future<int> scan({bool notify = false}) async {
    final service = ref.read(smsParserServiceProvider);
    final count = await service.scanAndParseSms();

    if (count > 0 && notify) {
      final notifService = NotificationService();
      await notifService.showNewSmsTransactions(count);
    }

    ref.invalidateSelf();
    return count;
  }

  /// Approuver une transaction avec catégorie, compte et choix budget
  Future<void> approve({
    required int pendingId,
    required int categoryId,
    required int accountId,
    required bool countsInBudget,
  }) async {
    final service = ref.read(smsParserServiceProvider);
    await service.approveTransaction(
      pendingId: pendingId,
      categoryId: categoryId,
      accountId: accountId,
      countsInBudget: countsInBudget,
    );
    ref.invalidateSelf();
  }

  /// Rejeter une transaction
  Future<void> reject(int pendingId) async {
    final service = ref.read(smsParserServiceProvider);
    await service.rejectTransaction(pendingId);
    ref.invalidateSelf();
  }

  /// Nettoyer les anciennes transactions
  Future<void> cleanOld() async {
    final service = ref.read(smsParserServiceProvider);
    await service.cleanOldPendingTransactions();
    ref.invalidateSelf();
  }
}

/// Provider du nombre de transactions en attente
@riverpod
Future<int> pendingTransactionsCount(PendingTransactionsCountRef ref) async {
  final pending = await ref.watch(pendingTransactionsProvider.future);
  return pending.length;
}
