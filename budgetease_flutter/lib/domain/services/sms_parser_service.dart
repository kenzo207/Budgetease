import 'package:drift/drift.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/pending_transactions_table.dart';
import '../../data/database/tables/accounts_table.dart';
import '../../data/database/tables/transactions_table.dart';

/// Résultat du parsing d'un SMS MoMo
class ParsedMomoSms {
  final MomoTransactionType type;
  final double amount;
  final double fee;
  final double? balanceAfter;
  final String? counterpart;
  final String? counterpartPhone;
  final String? momoRef;
  final DateTime? transactionDate;
  final String operator;

  const ParsedMomoSms({
    required this.type,
    required this.amount,
    this.fee = 0,
    this.balanceAfter,
    this.counterpart,
    this.counterpartPhone,
    this.momoRef,
    this.transactionDate,
    required this.operator,
  });

  /// Est-ce une dépense ?
  bool get isExpense =>
      type == MomoTransactionType.transferOut ||
      type == MomoTransactionType.withdrawal ||
      type == MomoTransactionType.payment;

  /// Montant total (montant + frais pour les dépenses)
  double get totalAmount => isExpense ? amount + fee : amount;

  /// Description lisible
  String get description {
    switch (type) {
      case MomoTransactionType.transferOut:
        return 'Transfert envoyé${counterpart != null ? ' à $counterpart' : ''}';
      case MomoTransactionType.transferIn:
        return 'Transfert reçu${counterpart != null ? ' de $counterpart' : ''}';
      case MomoTransactionType.withdrawal:
        return 'Retrait${counterpart != null ? ' via $counterpart' : ''}';
      case MomoTransactionType.payment:
        return 'Paiement${counterpart != null ? ' à $counterpart' : ''}';
      case MomoTransactionType.deposit:
        return 'Dépôt${counterpart != null ? ' de $counterpart' : ''}';
      case MomoTransactionType.unknown:
        return 'Transaction Mobile Money';
    }
  }
}

/// Service de parsing des SMS Mobile Money
class SmsParserService {
  final AppDatabase _database;
  final SmsQuery _query = SmsQuery();

  static const String _lastScanTimestampKey = 'sms_last_scan_timestamp';

  SmsParserService({required AppDatabase database}) : _database = database;

  // ═══════════════════════════════════════════════════════
  // SCAN & PERSISTENCE
  // ═══════════════════════════════════════════════════════

  /// Demander la permission et scanner les SMS (seuls les nouveaux)
  Future<int> scanAndParseSms() async {
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      throw Exception('Permission SMS refusée');
    }

    // Récupérer le timestamp du dernier scan
    final prefs = await SharedPreferences.getInstance();
    final lastScanMs = prefs.getInt(_lastScanTimestampKey) ?? 0;
    final lastScanDate = DateTime.fromMillisecondsSinceEpoch(lastScanMs);

    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 200,
    );

    int newTransactions = 0;
    DateTime latestSmsDate = lastScanDate;

    for (final message in messages) {
      if (message.body == null || message.sender == null) continue;
      final msgDate = message.date ?? DateTime.now();

      // Ne traiter que les SMS plus récents que le dernier scan
      if (msgDate.isAfter(lastScanDate)) {
        final parsed = parseMessage(message.sender!, message.body!, msgDate);
        if (parsed != null) {
          // Vérifier doublon par momoRef (ID MoMo unique)
          final exists = await _isDuplicate(parsed, message.body!);

          if (!exists) {
            // Trouver le compte MoMo correspondant
            final accountId = await _findMomoAccountId(parsed.operator);

            await _database.into(_database.pendingTransactions).insert(
              PendingTransactionsCompanion(
                amount: Value(parsed.amount),
                operator: Value(parsed.operator),
                momoType: Value(parsed.type),
                fee: Value(parsed.fee),
                balanceAfter: Value(parsed.balanceAfter),
                counterpart: Value(parsed.counterpart),
                counterpartPhone: Value(parsed.counterpartPhone),
                momoRef: Value(parsed.momoRef),
                transactionDate: Value(parsed.transactionDate),
                rawSms: Value(message.body!),
                smsDate: Value(msgDate),
                isProcessed: const Value(false),
                countsInBudget: const Value(true),
                suggestedAccountId: Value(accountId),
                createdAt: Value(DateTime.now()),
              ),
            );
            newTransactions++;
            // NOTE: Le solde du compte n'est PAS mis à jour ici.
            // Il sera mis à jour uniquement lors de l'approbation (approveTransaction).
            // Cela évite les doubles mises à jour et les erreurs si l'utilisateur rejette.
          }

          if (msgDate.isAfter(latestSmsDate)) {
            latestSmsDate = msgDate;
          }
        }
      }
    }

    // Sauvegarder le timestamp du scan
    await prefs.setInt(
      _lastScanTimestampKey,
      latestSmsDate.millisecondsSinceEpoch,
    );

    return newTransactions;
  }

  /// Vérifier si une transaction est un doublon
  Future<bool> _isDuplicate(ParsedMomoSms parsed, String rawSms) async {
    // Si on a un ID MoMo, on vérifie par celui-ci (le plus fiable)
    if (parsed.momoRef != null && parsed.momoRef!.isNotEmpty) {
      final existing = await (_database.select(_database.pendingTransactions)
            ..where((t) => t.momoRef.equals(parsed.momoRef!)))
          .getSingleOrNull();
      return existing != null;
    }
    // Sinon, on vérifie par le SMS brut
    final existing = await (_database.select(_database.pendingTransactions)
          ..where((t) => t.rawSms.equals(rawSms)))
        .getSingleOrNull();
    return existing != null;
  }

  /// Trouver l'ID du compte Mobile Money correspondant à l'opérateur
  Future<int?> _findMomoAccountId(String operator) async {
    final momoAccounts = await (_database.select(_database.accounts)
          ..where((a) =>
              a.type.equals(AccountType.mobileMoney.index) &
              a.isActive.equals(true)))
        .get();

    // Essayer de matcher par nom d'opérateur
    final operatorLower = operator.toLowerCase();
    for (final account in momoAccounts) {
      final accountNameLower = account.name.toLowerCase();
      final accountOperatorLower = (account.operator ?? '').toLowerCase();
      if (accountNameLower.contains(operatorLower) ||
          accountOperatorLower.contains(operatorLower) ||
          operatorLower.contains(accountNameLower) ||
          operatorLower.contains(accountOperatorLower)) {
        return account.id;
      }
    }
    // Si un seul compte MoMo, l'utiliser par défaut
    if (momoAccounts.length == 1) return momoAccounts.first.id;
    return null;
  }

  /// Mettre à jour le solde du compte Mobile Money
  Future<void> _updateAccountBalance(int accountId, double newBalance) async {
    await (_database.update(_database.accounts)
          ..where((a) => a.id.equals(accountId)))
        .write(AccountsCompanion(
      currentBalance: Value(newBalance),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ═══════════════════════════════════════════════════════
  // SMS PARSING ENGINE
  // ═══════════════════════════════════════════════════════

  /// Parser un SMS — point d'entrée principal
  ParsedMomoSms? parseMessage(String sender, String body, DateTime date) {
    final senderUpper = sender.toUpperCase();

    // MTN MoMo (Bénin)
    if (senderUpper.contains('MTN') || senderUpper.contains('MOMO') || senderUpper.contains('MOMO')) {
      return _parseMtnMomoBenin(body, date);
    }
    // Wave
    if (senderUpper.contains('WAVE')) {
      return _parseGeneric(body, date, 'Wave');
    }
    // Orange Money
    if (senderUpper.contains('ORANGE') || senderUpper.contains('OM')) {
      return _parseGeneric(body, date, 'Orange Money');
    }
    // Moov Money
    if (senderUpper.contains('MOOV')) {
      return _parseGeneric(body, date, 'Moov Money');
    }

    return null;
  }

  // ═══════════════════════════════════════════════════════
  // MTN MoMo BÉNIN - Parser spécialisé
  // ═══════════════════════════════════════════════════════

  /// Parser les SMS MTN MoMo format Bénin
  /// Formats supportés:
  ///   Transfert 1000F a NOM(TEL) DATE Frais:0F Solde:17035F Ref:a ID:XXX
  ///   Transfert 18550F de NOM(TEL) DATE Ref:a Solde:19110F ID:XXX
  ///   Retrait 2000F via NOM(TEL - INFO) DATE Solde:60F Frais:125F ID:XXX
  ///   Paiement 500F a NOM DATE Frais:0F Solde:35F ID:XXX Ref:XXX
  ParsedMomoSms? _parseMtnMomoBenin(String body, DateTime fallbackDate) {
    final bodyTrimmed = body.trim();

    // ── Transfert sortant: "Transfert XXF a ..."
    final transferOutRegex = RegExp(
      r'Transfert\s+(\d+)F\s+a\s+(.+?)(?:\((\d+)\))?\s+'
      r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s*'
      r'(?:Frais:\s*(\d+)F)?\s*'
      r'(?:Solde:\s*(\d+)F)?\s*'
      r'(?:Ref:\s*(\S+))?\s*'
      r'(?:ID:\s*(\d+))?',
      caseSensitive: false,
    );

    // ── Transfert entrant: "Transfert XXF de ..."
    final transferInRegex = RegExp(
      r'Transfert\s+(\d+)F\s+de\s+(.+?)\s*(?:\((\d+)\))?\s+'
      r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s*'
      r'(?:Ref:\s*(\S+))?\s*'
      r'(?:Solde:\s*(\d+)F)?\s*'
      r'(?:ID:\s*(\d+))?',
      caseSensitive: false,
    );

    // ── Retrait: "Retrait XXF via ..."
    final retraitRegex = RegExp(
      r'Retrait\s+(\d+)F\s+via\s+(.+?)(?:\((.+?)\))?\s+'
      r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s*'
      r'(?:Solde:\s*(\d+)F)?\s*'
      r'(?:Frais:\s*(\d+)F)?\s*'
      r'(?:ID:\s*(\d+))?',
      caseSensitive: false,
    );

    // ── Paiement: "Paiement XXF a ..."
    final paiementRegex = RegExp(
      r'Paiement\s+(\d+)F\s+a\s+(.+?)\s+'
      r'(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s*'
      r'(?:Frais:\s*(\d+)F)?\s*'
      r'(?:Solde:\s*(\d+)F)?\s*'
      r'(?:ID:\s*(\d+))?\s*'
      r'(?:Ref:\s*(\S+))?',
      caseSensitive: false,
    );

    RegExpMatch? match;

    // Tenter transfert sortant
    match = transferOutRegex.firstMatch(bodyTrimmed);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!) ?? 0;
      if (amount <= 0) return _parseGeneric(bodyTrimmed, fallbackDate, 'MTN MoMo');
      return ParsedMomoSms(
        type: MomoTransactionType.transferOut,
        amount: amount,
        counterpart: _cleanName(match.group(2)),
        counterpartPhone: match.group(3),
        transactionDate: _parseDate(match.group(4)) ?? fallbackDate,
        fee: double.tryParse(match.group(5) ?? '0') ?? 0,
        balanceAfter: double.tryParse(match.group(6) ?? '') ,
        momoRef: match.group(8) ?? match.group(7),
        operator: 'MTN MoMo',
      );
    }

    // Tenter transfert entrant
    match = transferInRegex.firstMatch(bodyTrimmed);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!) ?? 0;
      if (amount <= 0) return _parseGeneric(bodyTrimmed, fallbackDate, 'MTN MoMo');
      return ParsedMomoSms(
        type: MomoTransactionType.transferIn,
        amount: amount,
        counterpart: _cleanName(match.group(2)),
        counterpartPhone: match.group(3),
        transactionDate: _parseDate(match.group(4)) ?? fallbackDate,
        momoRef: match.group(7) ?? match.group(5),
        balanceAfter: double.tryParse(match.group(6) ?? ''),
        operator: 'MTN MoMo',
      );
    }

    // Tenter retrait
    match = retraitRegex.firstMatch(bodyTrimmed);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!) ?? 0;
      if (amount <= 0) return _parseGeneric(bodyTrimmed, fallbackDate, 'MTN MoMo');
      return ParsedMomoSms(
        type: MomoTransactionType.withdrawal,
        amount: amount,
        counterpart: _cleanName(match.group(2)),
        counterpartPhone: _extractPhone(match.group(3)),
        transactionDate: _parseDate(match.group(4)) ?? fallbackDate,
        balanceAfter: double.tryParse(match.group(5) ?? ''),
        fee: double.tryParse(match.group(6) ?? '0') ?? 0,
        momoRef: match.group(7),
        operator: 'MTN MoMo',
      );
    }

    // Tenter paiement
    match = paiementRegex.firstMatch(bodyTrimmed);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!) ?? 0;
      if (amount <= 0) return _parseGeneric(bodyTrimmed, fallbackDate, 'MTN MoMo');
      return ParsedMomoSms(
        type: MomoTransactionType.payment,
        amount: amount,
        counterpart: _cleanName(match.group(2)),
        transactionDate: _parseDate(match.group(3)) ?? fallbackDate,
        fee: double.tryParse(match.group(4) ?? '0') ?? 0,
        balanceAfter: double.tryParse(match.group(5) ?? ''),
        momoRef: match.group(6),
        operator: 'MTN MoMo',
      );
    }

    // Fallback: extraire au moins le montant
    return _parseGeneric(bodyTrimmed, fallbackDate, 'MTN MoMo');
  }

  // ═══════════════════════════════════════════════════════
  // PARSER GÉNÉRIQUE (Wave, Orange, Moov, fallback)
  // ═══════════════════════════════════════════════════════

  ParsedMomoSms? _parseGeneric(String body, DateTime date, String operator) {
    // Extraire le montant (nombre suivi de F ou FCFA)
    // Supporte: 1000F, 1 000F, 1.000F, 1,000F, 10.000FCFA
    final amountRegex = RegExp(r'(\d+(?:[\s.,]\d{3})*(?:[.,]\d{1,2})?)\s*F(?:CFA)?');
    final match = amountRegex.firstMatch(body);
    if (match == null) return null;

    // Nettoyer le montant : retirer espaces et séparateurs de milliers
    String cleanAmount = match.group(1)!.replaceAll(' ', '');
    // Si le nombre contient plusieurs points/virgules, ce sont des séparateurs de milliers
    final dotCount = '.'.allMatches(cleanAmount).length;
    final commaCount = ','.allMatches(cleanAmount).length;
    if (dotCount > 1 || (dotCount == 1 && commaCount == 0 && cleanAmount.split('.').last.length == 3)) {
      // Points utilisés comme séparateurs de milliers (ex: 1.000.000 ou 10.000)
      cleanAmount = cleanAmount.replaceAll('.', '');
    } else if (commaCount > 1 || (commaCount == 1 && dotCount == 0 && cleanAmount.split(',').last.length == 3)) {
      // Virgules utilisées comme séparateurs de milliers
      cleanAmount = cleanAmount.replaceAll(',', '');
    } else {
      // Format standard : virgule = décimale
      cleanAmount = cleanAmount.replaceAll(',', '.');
    }
    final amount = double.tryParse(cleanAmount) ?? 0.0;
    if (amount <= 0) return null;

    // Déterminer le type par mots-clés
    final bodyLower = body.toLowerCase();
    MomoTransactionType type = MomoTransactionType.unknown;
    if (bodyLower.contains('reçu') || bodyLower.contains('recu') || bodyLower.contains(' de ')) {
      type = MomoTransactionType.transferIn;
    } else if (bodyLower.contains('envoy') || bodyLower.contains(' a ') || bodyLower.contains('transfert')) {
      type = MomoTransactionType.transferOut;
    } else if (bodyLower.contains('retrait')) {
      type = MomoTransactionType.withdrawal;
    } else if (bodyLower.contains('paiement') || bodyLower.contains('achat')) {
      type = MomoTransactionType.payment;
    }

    // Extraire le solde
    final soldeRegex = RegExp(r'[Ss]olde\s*:?\s*(\d+)\s*F');
    final soldeMatch = soldeRegex.firstMatch(body);
    final balance = soldeMatch != null ? double.tryParse(soldeMatch.group(1)!) : null;

    // Extraire les frais
    final fraisRegex = RegExp(r'[Ff]rais\s*:?\s*(\d+)\s*F');
    final fraisMatch = fraisRegex.firstMatch(body);
    final fee = fraisMatch != null ? double.tryParse(fraisMatch.group(1)!) ?? 0.0 : 0.0;

    return ParsedMomoSms(
      type: type,
      amount: amount,
      fee: fee,
      balanceAfter: balance,
      operator: operator,
      transactionDate: date,
    );
  }

  // ═══════════════════════════════════════════════════════
  // UTILITAIRES
  // ═══════════════════════════════════════════════════════

  /// Parser une date au format "2026-02-10 15:00:28"
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      return DateTime.parse(dateStr.trim());
    } catch (_) {
      return null;
    }
  }

  /// Nettoyer un nom de personne
  String? _cleanName(String? name) {
    if (name == null) return null;
    return name.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Extraire un numéro de téléphone depuis une string qui peut contenir autre chose
  String? _extractPhone(String? raw) {
    if (raw == null) return null;
    final phoneRegex = RegExp(r'(\d{10,13})');
    final match = phoneRegex.firstMatch(raw);
    return match?.group(1);
  }

  // ═══════════════════════════════════════════════════════
  // ACCÈS AUX DONNÉES
  // ═══════════════════════════════════════════════════════

  /// Récupérer les transactions en attente non traitées
  Future<List<PendingTransaction>> getPendingTransactions() async {
    return await (_database.select(_database.pendingTransactions)
          ..where((t) => t.isProcessed.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.smsDate)]))
        .get();
  }

  /// Valider une transaction et l'ajouter aux vraies transactions
  Future<void> approveTransaction({
    required int pendingId,
    required int categoryId,
    required int accountId,
    required bool countsInBudget,
  }) async {
    final pending = await (_database.select(_database.pendingTransactions)
          ..where((t) => t.id.equals(pendingId)))
        .getSingleOrNull();

    if (pending == null) return;

    // Déterminer le type de transaction
    final isIncome = pending.momoType == MomoTransactionType.transferIn ||
        pending.momoType == MomoTransactionType.deposit;

    // Créer la vraie transaction
    await _database.into(_database.transactions).insert(
      TransactionsCompanion(
        amount: Value(pending.amount),
        type: Value(isIncome
            ? TransactionType.income
            : TransactionType.expense),
        date: Value(pending.transactionDate ?? pending.smsDate),
        categoryId: Value(categoryId),
        accountId: Value(accountId),
        feeAmount: Value(pending.fee > 0 ? pending.fee : null),
        description: Value(_buildDescription(pending)),
        source: Value(isIncome ? pending.operator : null),
        isException: Value(!countsInBudget),
        createdAt: Value(DateTime.now()),
      ),
    );

    // Mettre à jour le solde du compte
    final account = await (_database.select(_database.accounts)
          ..where((a) => a.id.equals(accountId)))
        .getSingleOrNull();

    if (account != null) {
      double newBalance;
      if (pending.balanceAfter != null) {
        // Si on a le solde post-transaction, l'utiliser directement
        newBalance = pending.balanceAfter!;
      } else {
        // Sinon, calculer manuellement
        newBalance = isIncome
            ? account.currentBalance + pending.amount
            : account.currentBalance - pending.amount - pending.fee;
      }
      await _updateAccountBalance(accountId, newBalance);
    }

    // Marquer comme traitée
    await (_database.update(_database.pendingTransactions)
          ..where((t) => t.id.equals(pendingId)))
        .write(const PendingTransactionsCompanion(isProcessed: Value(true)));
  }

  /// Rejeter une transaction (la marquer comme traitée sans la créer)
  Future<void> rejectTransaction(int pendingId) async {
    await (_database.update(_database.pendingTransactions)
          ..where((t) => t.id.equals(pendingId)))
        .write(const PendingTransactionsCompanion(isProcessed: Value(true)));
  }

  /// Construire une description à partir du pending
  String _buildDescription(PendingTransaction pending) {
    final type = pending.momoType;
    final parts = <String>[];

    switch (type) {
      case MomoTransactionType.transferOut:
        parts.add('Transfert envoyé');
      case MomoTransactionType.transferIn:
        parts.add('Transfert reçu');
      case MomoTransactionType.withdrawal:
        parts.add('Retrait');
      case MomoTransactionType.payment:
        parts.add('Paiement');
      case MomoTransactionType.deposit:
        parts.add('Dépôt');
      case MomoTransactionType.unknown:
        parts.add('Transaction');
    }

    if (pending.counterpart != null) {
      parts.add(type == MomoTransactionType.transferIn ? 'de' : 'à');
      parts.add(pending.counterpart!);
    }

    parts.add('(${pending.operator})');

    return parts.join(' ');
  }

  /// Supprimer les anciennes transactions en attente (> 30 jours)
  Future<void> cleanOldPendingTransactions() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    await (_database.delete(_database.pendingTransactions)
          ..where((t) =>
              t.isProcessed.equals(true) &
              t.createdAt.isSmallerThanValue(thirtyDaysAgo)))
        .go();
  }
}

