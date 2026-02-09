import 'dart:convert';
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/transactions_table.dart';

/// Service pour détecter et gérer les insights (Ghost Money, etc.)
class InsightsService {
  final AppDatabase _database;

  // Seuils de détection
  static const double microExpenseThreshold = 500.0;
  static const int minTransactionCount = 5;
  static const double minImpactPercentage = 5.0;

  InsightsService({required AppDatabase database}) : _database = database;

  /// Détecter le Ghost Money (micro-dépenses répétées)
  Future<GhostMoneyInsight?> detectGhostMoney() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Micro-dépenses de la semaine
    final microExpenses = await (_database.select(_database.transactions)
          ..where((t) =>
              t.type.equals(TransactionType.expense.index) &
              t.amount.isSmallerOrEqualValue(microExpenseThreshold) &
              t.date.isBiggerThanValue(weekAgo)))
        .get();

    if (microExpenses.length < minTransactionCount) return null;

    final total = microExpenses.fold<double>(0.0, (sum, t) => sum + t.amount);
    final categories = microExpenses.map((t) => t.category).toSet().toList();

    // Calculer impact vs budget disponible
    final availableBudget = await _getAvailableBudget();
    if (availableBudget <= 0) return null;

    final impact = (total / availableBudget) * 100;

    if (impact < minImpactPercentage) return null;

    return GhostMoneyInsight(
      totalAmount: total,
      transactionCount: microExpenses.length,
      categories: categories,
      percentageOfAvailable: impact,
      detectedAt: now,
    );
  }

  /// Créer ou récupérer insight Ghost Money
  Future<Insight?> getOrCreateGhostMoneyInsight() async {
    // Nettoyer anciens insights
    await _cleanExpiredInsights();

    // Vérifier si insight récent existe
    final existing = await (_database.select(_database.insights)
          ..where((i) =>
              i.type.equals('ghost_money') &
              i.isDismissed.equals(false) &
              i.expiresAt.isBiggerThanValue(DateTime.now())))
        .getSingleOrNull();

    if (existing != null) return existing;

    // Détecter nouveau pattern
    final ghostMoney = await detectGhostMoney();
    if (ghostMoney == null) return null;

    // Créer insight
    final insightId = await _database.into(_database.insights).insert(
      InsightsCompanion.insert(
        type: 'ghost_money',
        totalAmount: ghostMoney.totalAmount,
        transactionCount: ghostMoney.transactionCount,
        categoryNames: jsonEncode(ghostMoney.categories),
        percentageOfAvailable: ghostMoney.percentageOfAvailable,
        detectedAt: ghostMoney.detectedAt,
        expiresAt: ghostMoney.detectedAt.add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      ),
    );

    return await (_database.select(_database.insights)
          ..where((i) => i.id.equals(insightId)))
        .getSingleOrNull();
  }

  /// Obtenir tous les insights actifs
  Future<List<Insight>> getActiveInsights() async {
    await _cleanExpiredInsights();
    
    return await (_database.select(_database.insights)
          ..where((i) =>
              i.isDismissed.equals(false) &
              i.expiresAt.isBiggerThanValue(DateTime.now())))
        .get();
  }

  /// Supprimer (dismiss) un insight
  Future<void> dismissInsight(int insightId) async {
    await (_database.update(_database.insights)
          ..where((i) => i.id.equals(insightId)))
        .write(const InsightsCompanion(isDismissed: Value(true)));
  }

  /// Nettoyer insights expirés
  Future<void> _cleanExpiredInsights() async {
    await (_database.delete(_database.insights)
          ..where((i) => i.expiresAt.isSmallerThanValue(DateTime.now())))
        .go();
  }

  /// Calculer budget disponible
  Future<double> _getAvailableBudget() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Revenus du mois
    final incomes = await (_database.select(_database.transactions)
          ..where((t) =>
              t.type.equals(TransactionType.income.index) &
              t.date.isBiggerThanValue(monthStart)))
        .get();

    // Dépenses du mois
    final expenses = await (_database.select(_database.transactions)
          ..where((t) =>
              t.type.equals(TransactionType.expense.index) &
              t.date.isBiggerThanValue(monthStart)))
        .get();

    final totalIncome = incomes.fold<double>(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = expenses.fold<double>(0.0, (sum, t) => sum + t.amount);

    return totalIncome - totalExpenses;
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

  /// Message formaté
  String get message {
    return '$transactionCount micro-dépenses = ${totalAmount.toStringAsFixed(0)} FCFA '
        '(${percentageOfAvailable.toStringAsFixed(1)}% de ton budget)';
  }

  /// Catégories formatées
  String get categoriesText {
    if (categories.isEmpty) return 'Aucune catégorie';
    if (categories.length == 1) return categories.first;
    if (categories.length == 2) return '${categories[0]} et ${categories[1]}';
    return '${categories[0]}, ${categories[1]} et ${categories.length - 2} autres';
  }
}
