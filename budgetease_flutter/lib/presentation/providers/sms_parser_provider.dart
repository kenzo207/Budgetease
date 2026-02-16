import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/services/sms_parser_service.dart';
import '../../data/database/app_database.dart';

part 'sms_parser_provider.g.dart';

/// Provider du service de parsing SMS
@riverpod
SmsParserService smsParserService(SmsParserServiceRef ref) {
  final database = AppDatabase();
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

  /// Marquer une transaction comme traitée
  Future<void> markAsProcessed(int pendingId) async {
    final service = ref.read(smsParserServiceProvider);
    await service.markAsProcessed(pendingId);
    ref.invalidateSelf();
  }

  /// Nettoyer les anciennes transactions
  Future<void> cleanOld() async {
    final service = ref.read(smsParserServiceProvider);
    await service.cleanOldPendingTransactions();
    ref.invalidateSelf();
  }
  /// Scanner les SMS et mettre à jour la liste
  Future<int> scan() async {
    final service = ref.read(smsParserServiceProvider);
    final count = await service.scanAndParseSms();
    ref.invalidateSelf();
    return count;
  }
}

/// Provider du nombre de transactions en attente
@riverpod
Future<int> pendingTransactionsCount(PendingTransactionsCountRef ref) async {
  final pending = await ref.watch(pendingTransactionsProvider.future);
  return pending.length;
}
