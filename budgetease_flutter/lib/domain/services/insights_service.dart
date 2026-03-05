import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../engine/engine_output.dart';
import '../../presentation/providers/engine_provider.dart';

/// Service d'insights — détecte les patterns anormaux depuis le moteur Rust.
///
/// Le calcul "Ghost Money" est délégué à [AnalyticsResult.byCategory]
/// retourné par [engineAnalyticsProvider] (zolt_analytics).
/// Aucun calcul n'est effectué côté Dart.
class InsightsService {
  final AppDatabase _database;
  final Ref _ref;

  /// Seuil : une catégorie représente du "ghost money" si elle dépasse
  /// [ghostMoneyPctThreshold] % du total des dépenses et a au moins
  /// [minTxCount] transactions (micro-dépenses répétées).
  static const double ghostMoneyPctThreshold = 5.0;
  static const int    minTxCount             = 5;
  static const double maxAmountPerTx         = 500.0; // FCFA

  InsightsService({required AppDatabase database, required Ref ref})
      : _database = database,
        _ref = ref;

  /// Détecter le Ghost Money depuis les stats Rust du mois courant.
  Future<GhostMoneyInsight?> detectGhostMoney() async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month);

    AnalyticsResult? analytics;
    try {
      analytics = await _ref.read(engineAnalyticsProvider(month).future);
    } catch (_) {
      return null;
    }
    if (analytics == null) return null;

    // Identifier les catégories "ghost money" :
    // petits montants moyens par transaction + forte répétition + part significative
    final ghosts = analytics.byCategory.where((cat) =>
        cat.txCount >= minTxCount &&
        cat.avgPerTx <= maxAmountPerTx &&
        cat.pctOfBudget * 100 >= ghostMoneyPctThreshold,
    ).toList();

    if (ghosts.isEmpty) return null;

    final totalGhost = ghosts.fold<double>(0, (s, c) => s + c.total);
    final categories = ghosts.map((c) => c.category).toList();
    final impact = analytics.totalExpenses > 0
        ? (totalGhost / analytics.totalExpenses * 100)
        : 0.0;

    return GhostMoneyInsight(
      totalAmount:            totalGhost,
      transactionCount:       ghosts.fold<int>(0, (s, c) => s + c.txCount),
      categories:             categories,
      percentageOfAvailable:  impact,
      detectedAt:             now,
    );
  }

  /// Créer ou récupérer l'insight Ghost Money (cache DB 7 jours).
  Future<Insight?> getOrCreateGhostMoneyInsight() async {
    await _cleanExpiredInsights();

    final existing = await (_database.select(_database.insights)
          ..where((i) =>
              i.type.equals('ghost_money') &
              i.isDismissed.equals(false) &
              i.expiresAt.isBiggerThanValue(DateTime.now())))
        .getSingleOrNull();

    if (existing != null) return existing;

    final ghostMoney = await detectGhostMoney();
    if (ghostMoney == null) return null;

    final insightId = await _database.into(_database.insights).insert(
      InsightsCompanion.insert(
        type:                   'ghost_money',
        totalAmount:            ghostMoney.totalAmount,
        transactionCount:       ghostMoney.transactionCount,
        categoryNames:          jsonEncode(ghostMoney.categories),
        percentageOfAvailable:  ghostMoney.percentageOfAvailable,
        detectedAt:             ghostMoney.detectedAt,
        expiresAt:              ghostMoney.detectedAt.add(const Duration(days: 7)),
        createdAt:              DateTime.now(),
      ),
    );

    return await (_database.select(_database.insights)
          ..where((i) => i.id.equals(insightId)))
        .getSingleOrNull();
  }

  /// Obtenir tous les insights actifs.
  Future<List<Insight>> getActiveInsights() async {
    await _cleanExpiredInsights();
    return await (_database.select(_database.insights)
          ..where((i) =>
              i.isDismissed.equals(false) &
              i.expiresAt.isBiggerThanValue(DateTime.now())))
        .get();
  }

  /// Supprimer (dismiss) un insight.
  Future<void> dismissInsight(int insightId) async {
    await (_database.update(_database.insights)
          ..where((i) => i.id.equals(insightId)))
        .write(const InsightsCompanion(isDismissed: Value(true)));
  }

  Future<void> _cleanExpiredInsights() async {
    await (_database.delete(_database.insights)
          ..where((i) => i.expiresAt.isSmallerThanValue(DateTime.now())))
        .go();
  }
}

/// Modèle Ghost Money Insight
class GhostMoneyInsight {
  final double totalAmount;
  final int transactionCount;
  final List<String> categories;
  final double percentageOfAvailable;
  final DateTime detectedAt;

  GhostMoneyInsight({
    required this.totalAmount,
    required this.transactionCount,
    required this.categories,
    required this.percentageOfAvailable,
    required this.detectedAt,
  });

  String getMessage(String currency) {
    return '$transactionCount micro-dépenses = ${totalAmount.toStringAsFixed(0)} $currency '
        '(${percentageOfAvailable.toStringAsFixed(1)}% de tes dépenses)';
  }

  String get message => getMessage('FCFA');

  String get categoriesText {
    if (categories.isEmpty) return 'Aucune catégorie';
    if (categories.length == 1) return categories.first;
    if (categories.length == 2) return '${categories[0]} et ${categories[1]}';
    return '${categories[0]}, ${categories[1]} et ${categories.length - 2} autres';
  }
}
