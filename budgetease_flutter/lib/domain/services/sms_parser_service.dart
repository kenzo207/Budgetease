import 'package:drift/drift.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/database/app_database.dart';

/// Service de parsing des SMS Mobile Money
class SmsParserService {
  final AppDatabase _database;
  final SmsQuery _query = SmsQuery();

  SmsParserService({required AppDatabase database}) : _database = database;

  /// Demander la permission et récupérer les SMS
  Future<int> scanAndParseSms() async {
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      throw Exception('Permission SMS refusée');
    }

    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 100, // On limite aux 100 derniers pour l'instant
    );

    int newTransactions = 0;

    for (final message in messages) {
      if (message.body == null || message.sender == null) continue;

      final parsed = _parseMessage(message.sender!, message.body!, message.date ?? DateTime.now());
      if (parsed != null) {
        // Vérifier si la transaction existe déjà
        final exists = await (_database.select(_database.pendingTransactions)
              ..where((t) => t.rawSms.equals(parsed.rawSms.value) & t.smsDate.equals(parsed.smsDate.value)))
            .getSingleOrNull();

        if (exists == null) {
          await _database.into(_database.pendingTransactions).insert(parsed);
          newTransactions++;
        }
      }
    }

    return newTransactions;
  }

  PendingTransactionsCompanion? _parseMessage(String sender, String body, DateTime date) {
    // Normaliser l'expéditeur
    final senderUpper = sender.toUpperCase();
    
    // Wave
    if (senderUpper.contains('WAVE')) {
      return _parseWave(body, date);
    }
    // Orange Money
    else if (senderUpper.contains('ORANGE') || senderUpper.contains('OM')) {
      return _parseOrange(body, date);
    }
    // MTN MoMo
    else if (senderUpper.contains('MTN') || senderUpper.contains('MOMO')) {
      return _parseMtn(body, date);
    }
    // Moov Money
    else if (senderUpper.contains('MOOV')) {
      return _parseMoov(body, date);
    }

    return null;
  }

  PendingTransactionsCompanion? _parseWave(String body, DateTime date) {
    // Ex: Transfert de 5000F à...
    // Ex: Vous avez reçu 10000F de...
    final amountRegex = RegExp(r'(\d+(?:\.\d+)?)\s*F');
    final match = amountRegex.firstMatch(body);

    if (match != null) {
      final amount = double.tryParse(match.group(1)!) ?? 0.0;
      return PendingTransactionsCompanion(
        amount: Value(amount),
        operator: const Value('Wave'),
        rawSms: Value(body),
        smsDate: Value(date),
        createdAt: Value(DateTime.now()),
        isProcessed: const Value(false),
      );
    }
    return null;
  }

  PendingTransactionsCompanion? _parseOrange(String body, DateTime date) {
    // Ex: Vous avez recu 15000 FCFA de...
    final amountRegex = RegExp(r'(\d+(?:\s?\d+)*)\s?F?CFA');
    final match = amountRegex.firstMatch(body);

    if (match != null) {
      final cleanAmount = match.group(1)!.replaceAll(' ', '');
      final amount = double.tryParse(cleanAmount) ?? 0.0;
      
      return PendingTransactionsCompanion(
        amount: Value(amount),
        operator: const Value('Orange Money'),
        rawSms: Value(body),
        smsDate: Value(date),
        createdAt: Value(DateTime.now()),
        isProcessed: const Value(false),
      );
    }
    return null;
  }
  
  PendingTransactionsCompanion? _parseMtn(String body, DateTime date) {
    // Ex: Transfert effectué pour 2000 FCFA...
    final amountRegex = RegExp(r'(\d+(?:\s?\d+)*)\s?F?CFA');
    final match = amountRegex.firstMatch(body);

    if (match != null) {
      final cleanAmount = match.group(1)!.replaceAll(' ', '');
      final amount = double.tryParse(cleanAmount) ?? 0.0;
      
      return PendingTransactionsCompanion(
        amount: Value(amount),
        operator: const Value('MTN MoMo'),
        rawSms: Value(body),
        smsDate: Value(date),
        createdAt: Value(DateTime.now()),
        isProcessed: const Value(false),
      );
    }
    return null;
  }

  PendingTransactionsCompanion? _parseMoov(String body, DateTime date) {
    final amountRegex = RegExp(r'(\d+(?:\s?\d+)*)\s?F?CFA');
    final match = amountRegex.firstMatch(body);

    if (match != null) {
      final cleanAmount = match.group(1)!.replaceAll(' ', '');
      final amount = double.tryParse(cleanAmount) ?? 0.0;
      
      return PendingTransactionsCompanion(
        amount: Value(amount),
        operator: const Value('Moov Money'),
        rawSms: Value(body),
        smsDate: Value(date),
        createdAt: Value(DateTime.now()),
        isProcessed: const Value(false),
      );
    }
    return null;
  }

  /// Récupérer les transactions en attente
  Future<List<PendingTransaction>> getPendingTransactions() async {
    return await (_database.select(_database.pendingTransactions)
          ..where((t) => t.isProcessed.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.smsDate)]))
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
