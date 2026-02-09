import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/pending_transactions_table.dart';
import '../../data/database/tables/accounts_table.dart';

/// Service de parsing des SMS Mobile Money
/// 
/// NOTE: Fonctionnalité temporairement désactivée
/// Les packages SMS (telephony, flutter_sms) sont incompatibles avec Gradle 8.0+
/// 
/// Pour activer le parsing SMS, il faudra :
/// 1. Utiliser un plugin natif personnalisé
/// 2. Ou attendre une mise à jour des packages
/// 
/// En attendant, les transactions doivent être créées manuellement via l'UI
class SmsParserService {
  final AppDatabase _database;

  SmsParserService({required AppDatabase database}) : _database = database;

  /// Initialiser les permissions SMS (désactivé)
  Future<bool> initializeSmsListener() async {
    // Fonctionnalité désactivée
    return false;
  }

  /// Récupérer les transactions en attente
  Future<List<PendingTransaction>> getPendingTransactions() async {
    return await (_database.select(_database.pendingTransactions)
          ..where((t) => t.isProcessed.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Marquer une transaction en attente comme traitée
  Future<void> markAsProcessed(int pendingId) async {
    await (_database.update(_database.pendingTransactions)
          ..where((t) => t.id.equals(pendingId)))
        .write(const PendingTransactionsCompanion(isProcessed: Value(true)));
  }

  /// Supprimer les anciennes transactions en attente (> 7 jours)
  Future<void> cleanOldPendingTransactions() async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    await (_database.delete(_database.pendingTransactions)
          ..where((t) => t.createdAt.isSmallerThanValue(sevenDaysAgo)))
        .go();
  }
}
