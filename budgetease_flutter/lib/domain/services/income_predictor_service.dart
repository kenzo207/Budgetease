import 'dart:math' as math;
import 'package:drift/drift.dart';
import '../../data/database/app_database.dart';
import '../../data/database/tables/transactions_table.dart';

/// Service pour analyser les patterns de revenus et prédire les revenus futurs
class IncomePredictorService {
  final AppDatabase _database;

  IncomePredictorService({required AppDatabase database}) : _database = database;

  /// Analyser les patterns de revenus (90 derniers jours par défaut)
  Future<IncomeAnalysis> analyzeIncomePattern({int windowDays = 90}) async {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(days: windowDays));

    // Récupérer tous les revenus de la période
    final incomes = await (_database.select(_database.transactions)
          ..where((t) => 
              t.type.equals(TransactionType.income.index) &
              t.date.isBiggerThanValue(windowStart))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();

    if (incomes.isEmpty) {
      return IncomeAnalysis(
        estimatedWeeklyIncome: 0.0,
        minimumObserved: 0.0,
        maximumObserved: 0.0,
        averageObserved: 0.0,
        variance: 0.0,
        isRegular: false,
        transactionCount: 0,
        frequency: 'unknown',
      );
    }

    // Grouper par semaine
    final weeklyTotals = _groupByWeek(incomes);
    final weeklyAmounts = weeklyTotals.values.toList();

    // Calculs statistiques
    final average = _calculateAverage(weeklyAmounts);
    final min = _calculateMin(weeklyAmounts);
    final max = _calculateMax(weeklyAmounts);
    final variance = _calculateVariance(weeklyAmounts, average);
    final weightedAvg = _calculateWeightedAverage(weeklyTotals);

    // Déterminer régularité (écart-type < 20% de la moyenne)
    final stdDev = math.sqrt(variance);
    final isRegular = average > 0 && stdDev < (average * 0.2);

    // Détecter fréquence
    final frequency = _detectFrequency(incomes);

    return IncomeAnalysis(
      estimatedWeeklyIncome: weightedAvg,
      minimumObserved: min,
      maximumObserved: max,
      averageObserved: average,
      variance: variance,
      isRegular: isRegular,
      transactionCount: incomes.length,
      frequency: frequency,
    );
  }

  /// Prédire le revenu mensuel (basé sur le nombre de jours du mois en cours)
  Future<double> predictMonthlyIncome() async {
    final pattern = await analyzeIncomePattern();
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final weeksInMonth = daysInMonth / 7.0;
    return pattern.estimatedWeeklyIncome * weeksInMonth;
  }

  /// Obtenir le revenu estimé du mois (réel ou prédit)
  Future<double> getEstimatedMonthlyIncome() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Vérifier si revenus enregistrés ce mois
    final currentMonthIncomes = await (_database.select(_database.transactions)
          ..where((t) => 
              t.type.equals(TransactionType.income.index) &
              t.date.isBiggerThanValue(monthStart)))
        .get();

    if (currentMonthIncomes.isNotEmpty) {
      // Utiliser revenus réels
      return currentMonthIncomes.fold<double>(
        0.0, 
        (sum, t) => sum + t.amount
      );
    }

    // Sinon, utiliser prédiction
    return await predictMonthlyIncome();
  }

  /// Détecter la fréquence des revenus
  String _detectFrequency(List<Transaction> incomes) {
    if (incomes.length < 2) return 'unknown';

    // Calculer intervalles entre revenus
    final intervals = <int>[];
    for (int i = 1; i < incomes.length; i++) {
      final days = incomes[i].date.difference(incomes[i - 1].date).inDays;
      intervals.add(days);
    }

    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

    if (avgInterval <= 2) return 'daily';
    if (avgInterval <= 9) return 'weekly';
    if (avgInterval <= 16) return 'biweekly';
    if (avgInterval <= 35) return 'monthly';
    return 'irregular';
  }

  /// Prédire la prochaine date de revenu
  Future<DateTime?> predictNextIncomeDate() async {
    final pattern = await analyzeIncomePattern();
    
    if (pattern.frequency == 'unknown' || pattern.frequency == 'irregular') {
      return null;
    }

    // Dernier revenu
    final lastIncome = await (_database.select(_database.transactions)
          ..where((t) => t.type.equals(TransactionType.income.index))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();

    if (lastIncome == null) return null;

    final lastDate = lastIncome.date;

    switch (pattern.frequency) {
      case 'daily':
        return lastDate.add(const Duration(days: 1));
      case 'weekly':
        return lastDate.add(const Duration(days: 7));
      case 'biweekly':
        return lastDate.add(const Duration(days: 14));
      case 'monthly':
        return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
      default:
        return null;
    }
  }

  /// Obtenir jours jusqu'au prochain revenu
  Future<int?> getDaysUntilNextIncome() async {
    final nextDate = await predictNextIncomeDate();
    
    if (nextDate == null) return null;

    final remaining = nextDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // ========== Helpers Privés ==========

  /// Grouper transactions par semaine
  Map<int, double> _groupByWeek(List<Transaction> transactions) {
    final weeklyTotals = <int, double>{};
    for (var tx in transactions) {
      final weekNumber = _getWeekNumber(tx.date);
      weeklyTotals[weekNumber] = (weeklyTotals[weekNumber] ?? 0) + tx.amount;
    }
    return weeklyTotals;
  }

  /// Obtenir numéro de semaine
  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(startOfYear).inDays;
    return (daysDiff / 7).floor();
  }

  /// Calculer moyenne
  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculer minimum
  double _calculateMin(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a < b ? a : b);
  }

  /// Calculer maximum
  double _calculateMax(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  /// Calculer variance
  double _calculateVariance(List<double> values, double mean) {
    if (values.isEmpty) return 0;
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  /// Calculer moyenne pondérée (semaines récentes = poids plus élevé)
  double _calculateWeightedAverage(Map<int, double> weeklyTotals) {
    if (weeklyTotals.isEmpty) return 0;

    final weeks = weeklyTotals.keys.toList()..sort();
    double weightedSum = 0;
    double weightTotal = 0;

    for (int i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      final weight = (i + 1).toDouble(); // Poids linéaire croissant
      weightedSum += weeklyTotals[week]! * weight;
      weightTotal += weight;
    }

    return weightTotal > 0 ? weightedSum / weightTotal : 0;
  }
}

/// Modèle de r??sultat d'analyse de pattern de revenus
class IncomeAnalysis {
  final double estimatedWeeklyIncome;
  final double minimumObserved;
  final double maximumObserved;
  final double averageObserved;
  final double variance;
  final bool isRegular;
  final int transactionCount;
  final String frequency; // daily, weekly, biweekly, monthly, irregular, unknown

  IncomeAnalysis({
    required this.estimatedWeeklyIncome,
    required this.minimumObserved,
    required this.maximumObserved,
    required this.averageObserved,
    required this.variance,
    required this.isRegular,
    required this.transactionCount,
    required this.frequency,
  });

  /// Niveau de confiance (0.0 - 1.0)
  double get confidence {
    if (transactionCount < 3) return 0.0;
    if (transactionCount < 8) return 0.5;
    if (isRegular) return 0.9;
    return 0.7;
  }

  /// Message de statut
  String get statusMessage {
    if (transactionCount < 3) {
      return 'Pas assez de données. Enregistrez plus de revenus pour des prédictions précises.';
    } else if (isRegular) {
      return 'Revenus réguliers détectés. Prédictions fiables.';
    } else {
      return 'Revenus irréguliers détectés. Estimations conservatives.';
    }
  }

  /// Fréquence en texte lisible
  String get frequencyText {
    switch (frequency) {
      case 'daily':
        return 'Quotidien';
      case 'weekly':
        return 'Hebdomadaire';
      case 'biweekly':
        return 'Bi-hebdomadaire';
      case 'monthly':
        return 'Mensuel';
      case 'irregular':
        return 'Irrégulier';
      default:
        return 'Inconnu';
    }
  }
}
