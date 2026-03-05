import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/database/app_database.dart';
import '../../data/database/daos/categories_dao.dart';
import '../../data/database/tables/categories_table.dart';
import '../../data/database/tables/pending_transactions_table.dart';
import '../../data/database/tables/accounts_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../engine/zolt_engine.dart';


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
  // SCAN & AUTO-TRAITEMENT
  // ═══════════════════════════════════════════════════════

  /// Demander la permission et scanner les SMS.
  ///
  /// TOUTES les transactions détectées sont automatiquement validées et
  /// intégrées — aucune confirmation utilisateur requise.
  ///
  /// Règle solde : le solde du compte est mis à jour UNE SEULE FOIS à la fin
  /// du scan, avec le `balanceAfter` extrait du SMS le plus RÉCENT qui en
  /// contient un.  Les autres SMS servent uniquement à l'historique / analyse.
  ///
  /// Retourne un [SmsProcessingResult] avec le nombre de transactions traitées.
  Future<SmsProcessingResult> scanAndParseSms() async {
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      throw Exception('Permission SMS refusée');
    }

    final prefs = await SharedPreferences.getInstance();
    final lastScanMs = prefs.getInt(_lastScanTimestampKey) ?? 0;
    final lastScanDate = DateTime.fromMillisecondsSinceEpoch(lastScanMs);

    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 500,
    );

    // Trier par date croissante pour que le dernier SMS soit bien le plus récent.
    final sorted = messages
        .where((m) => m.body != null && m.sender != null)
        .toList()
      ..sort((a, b) =>
          (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0)));

    int autoApproved = 0;
    DateTime latestSmsDate = lastScanDate;

    // accountId → (balanceAfter, smsDate) du SMS le plus récent avec un solde.
    final Map<int, ({double balance, DateTime date})> latestBalances = {};

    for (final message in sorted) {
      final msgDate = message.date ?? DateTime.now();
      if (!msgDate.isAfter(lastScanDate)) continue;

      final parsed = parseMessage(message.sender!, message.body!, msgDate);
      if (parsed == null) continue;

      final exists = await _isDuplicate(parsed, message.body!);
      if (exists) continue;

      final accountId = await _findMomoAccountId(parsed.operator);
      if (accountId == null) continue;  // Compte inconnu → ignorer

      String? categorySlug;
      if (ZoltEngine.isAvailable) {
        try {
          final cls = ZoltEngine.classify(
            amount: parsed.amount,
            description: null,
            counterpart: parsed.counterpart,
            smsText: message.body!,
          );
          categorySlug = cls['category'] as String?;
        } catch (e) {
          debugPrint('[SmsParser] zolt_classify error: $e');
        }
      }

      final categoryId = await _resolveCategoryId(parsed, categorySlug);

      // Créer la transaction SANS toucher au solde.
      await _autoApproveTransaction(
        parsed: parsed,
        smsDate: msgDate,
        accountId: accountId,
        categoryId: categoryId,
        skipBalanceUpdate: true,
      );
      autoApproved++;

      // Mémoriser le solde du SMS le plus récent (tri croissant → on écrase).
      if (parsed.balanceAfter != null) {
        latestBalances[accountId] = (balance: parsed.balanceAfter!, date: msgDate);
      }

      if (msgDate.isAfter(latestSmsDate)) latestSmsDate = msgDate;
    }

    // ── Mise à jour UNIQUE du solde par compte ──────────────────
    for (final entry in latestBalances.entries) {
      await _updateAccountBalance(entry.key, entry.value.balance);
    }

    final scanTime = latestSmsDate.isAfter(lastScanDate)
        ? latestSmsDate
        : DateTime.now();
    await prefs.setInt(_lastScanTimestampKey, scanTime.millisecondsSinceEpoch);

    return SmsProcessingResult(autoApproved: autoApproved, pendingAdded: 0);
  }

  /// Commit direct d'une transaction sans validation utilisateur.
  ///
  /// [skipBalanceUpdate] : si `true`, ne met PAS à jour le solde du compte.
  /// Le solde est géré globalement par [scanAndParseSms] (règle du dernier SMS).
  Future<void> _autoApproveTransaction({
    required ParsedMomoSms parsed,
    required DateTime smsDate,
    required int accountId,
    required int? categoryId,
    bool skipBalanceUpdate = false,
  }) async {
    final isIncome = parsed.type == MomoTransactionType.transferIn ||
        parsed.type == MomoTransactionType.deposit;

    await _database.into(_database.transactions).insert(
      TransactionsCompanion(
        amount: Value(parsed.amount),
        type: Value(isIncome ? TransactionType.income : TransactionType.expense),
        date: Value(parsed.transactionDate ?? smsDate),
        categoryId: Value(categoryId),
        accountId: Value(accountId),
        feeAmount: Value(parsed.fee > 0 ? parsed.fee : null),
        description: Value(parsed.description),
        source: Value(isIncome ? parsed.operator : null),
        isException: const Value(false),
        createdAt: Value(DateTime.now()),
      ),
    );

    if (!skipBalanceUpdate) {
      final account = await (_database.select(_database.accounts)
              ..where((a) => a.id.equals(accountId)))
          .getSingleOrNull();
      if (account != null) {
        final double newBalance = parsed.balanceAfter ??
            (isIncome
                ? account.currentBalance + parsed.amount
                : account.currentBalance - parsed.amount - parsed.fee);
        await _updateAccountBalance(accountId, newBalance);
      }
    }
  }

  /// Insère un SMS dans la file d'attente pour révision manuelle.
  Future<void> _insertPending(
    ParsedMomoSms parsed,
    String rawSms,
    DateTime smsDate, {
    required int? accountId,
  }) async {
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
        rawSms: Value(rawSms),
        smsDate: Value(smsDate),
        isProcessed: const Value(false),
        countsInBudget: const Value(true),
        suggestedAccountId: Value(accountId),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  /// Résout l'ID de catégorie depuis le slug Rust (ex: "loyer", "nourriture").
  Future<int?> _resolveCategoryId(ParsedMomoSms parsed, String? slug) async {
    final isIncome = parsed.type == MomoTransactionType.transferIn ||
        parsed.type == MomoTransactionType.deposit;
    final targetType = isIncome ? CategoryType.income : CategoryType.expense;

    final allCats =
        await CategoriesDao(_database).getCategoriesByType(targetType);
    if (allCats.isEmpty) return null;

    // 1. Match par slug Rust dans le nom de catégorie
    if (slug != null && slug.isNotEmpty) {
      final slugWords = slug.split('_'); // "recharge_telecom" → ["recharge","telecom"]
      for (final word in slugWords) {
        final match = allCats
            .where((c) => c.name.toLowerCase().contains(word.toLowerCase()))
            .firstOrNull;
        if (match != null) return match.id;
      }
    }

    // 2. Match par mots-clés MoMo type
    final keywords = switch (parsed.type) {
      MomoTransactionType.transferIn => ['salaire', 'revenu', 'transfert'],
      MomoTransactionType.transferOut => ['transfert', 'envoi'],
      MomoTransactionType.withdrawal => ['retrait', 'espèces'],
      MomoTransactionType.payment => ['paiement', 'achat', 'courses'],
      MomoTransactionType.deposit => ['dépôt', 'salaire', 'revenu'],
      MomoTransactionType.unknown => <String>[],
    };
    for (final keyword in keywords) {
      final match = allCats
          .where((c) => c.name.toLowerCase().contains(keyword))
          .firstOrNull;
      if (match != null) return match.id;
    }

    // 3. Catégorie par défaut du bon type
    return allCats.where((c) => c.isDefault).firstOrNull?.id ?? allCats.first.id;
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
    // Bug #7 fix: normaliser le SMS brut (collapse whitespace) avant comparaison
    // pour éviter les faux doublons si le texte varie légèrement en espaces.
    final normalizedRaw = rawSms.trim().replaceAll(RegExp(r'\s+'), ' ');
    final allPending = await _database.select(_database.pendingTransactions).get();
    return allPending.any((t) =>
        t.rawSms.trim().replaceAll(RegExp(r'\s+'), ' ') == normalizedRaw);
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
    if (senderUpper.contains('MTN') || senderUpper.contains('MOMO')) {
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

    // ── Détection du type via le moteur Rust (zolt_classify) ─────
    MomoTransactionType type = MomoTransactionType.unknown;
    if (ZoltEngine.isAvailable) {
      try {
        final classified = ZoltEngine.classify(
          amount: amount,
          description: null,
          counterpart: null,
          smsText: body,
        );
        final txType = classified['tx_type'] as String? ?? '';
        switch (txType) {
          case 'Income':
          case 'TransferIn':
          case 'Deposit':
            type = txType == 'Deposit'
                ? MomoTransactionType.deposit
                : MomoTransactionType.transferIn;
          case 'Expense':
          case 'TransferOut':
            type = MomoTransactionType.transferOut;
          case 'Withdrawal':
            type = MomoTransactionType.withdrawal;
          default:
            type = MomoTransactionType.unknown;
        }
      } catch (e) {
        debugPrint('zolt_classify failed, falling back to Dart keywords: $e');
        type = _detectTypeFallback(body);
      }
    } else {
      // ── Fallback Dart (mots-clés) — Bug #6 fix ───────────────
      type = _detectTypeFallback(body);
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

  /// Fallback Dart : détection du type SMS par mots-clés (Bug #6 fix).
  /// Utilisé uniquement si le moteur Rust n'est pas disponible.
  MomoTransactionType _detectTypeFallback(String body) {
    final b = body.toLowerCase();
    if (b.contains('reçu') || b.contains('recu') ||
        b.contains('vous avez re') || b.contains('crédité')) {
      return MomoTransactionType.transferIn;
    } else if (b.contains('envoy') || b.contains('transfert') ||
        b.contains('vous avez envoy') || b.contains('débité')) {
      return MomoTransactionType.transferOut;
    } else if (b.contains('retrait')) {
      return MomoTransactionType.withdrawal;
    } else if (b.contains('paiement') || b.contains('achat') || b.contains('marchand')) {
      return MomoTransactionType.payment;
    } else if (b.contains('depôt') || b.contains('depot')) {
      return MomoTransactionType.deposit;
    }
    return MomoTransactionType.unknown;
  }

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
  /// Bug #2 fix: toutes les opérations sont dans une transaction DB atomique.
  /// Si une étape échoue, rien n'est persisté (pas de double transaction possible).
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

    await _database.transaction(() async {
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
          // Si on a le solde post-transaction depuis le SMS, l'utiliser directement
          newBalance = pending.balanceAfter!;
        } else {
          // Sinon, calculer manuellement
          newBalance = isIncome
              ? account.currentBalance + pending.amount
              : account.currentBalance - pending.amount - pending.fee;
        }
        await _updateAccountBalance(accountId, newBalance);
      }

      // Marquer comme traitée (dans la même transaction atomique)
      await (_database.update(_database.pendingTransactions)
            ..where((t) => t.id.equals(pendingId)))
          .write(const PendingTransactionsCompanion(isProcessed: Value(true)));
    });
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

/// Résultat d'un scan SMS, contenant le décompte des traitements.
class SmsProcessingResult {
  /// Nombre de transactions auto-approuvées directement.
  final int autoApproved;

  /// Toujours 0 — plus de file d'attente manuelle.
  final int pendingAdded;

  const SmsProcessingResult({
    required this.autoApproved,
    this.pendingAdded = 0,
  });

  /// Total des transactions détectées dans ce scan.
  int get total => autoApproved;

  /// Vrai si au moins une transaction a été traitée.
  bool get hasActivity => autoApproved > 0;
}

