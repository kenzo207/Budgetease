import 'dart:math';
import '../models/transaction.dart';
import '../models/income_pattern.dart';
import 'database_service.dart';

class IncomeAnalyzer {
  /// Analyse le pattern de revenus sur les 14 derniers jours
  static IncomePattern analyzeIncomePattern() {
    final now = DateTime.now();
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    final incomes = DatabaseService.transactions.values
        .where((t) => t.type == 'income' && t.date.isAfter(twoWeeksAgo))
        .toList();

    if (incomes.isEmpty) {
      // Pas de revenus récents : mode prudent
      return IncomePattern(
        estimatedWeeklyIncome: 0,
        minimumObserved: 0,
        averageObserved: 0,
        observationDays: 14,
        lastUpdated: now,
        isRegular: false,
      );
    }

    final total = incomes.fold(0.0, (sum, t) => sum + t.amount);
    final average = total / 2; // Moyenne sur 2 semaines
    final minimum = incomes.map((t) => t.amount).reduce(min);

    // Détection régularité : écart-type faible
    final variance = _calculateVariance(incomes.map((t) => t.amount).toList());
    final isRegular = variance < (average * 0.3); // Écart < 30%

    // Estimation prudente : utiliser le minimum si irrégulier
    final estimate = isRegular ? average : minimum;

    return IncomePattern(
      estimatedWeeklyIncome: estimate,
      minimumObserved: minimum,
      averageObserved: average,
      observationDays: 14,
      lastUpdated: now,
      isRegular: isRegular,
    );
  }

  /// Récupère ou crée le pattern stocké
  static IncomePattern getOrCreatePattern() {
    final box = DatabaseService.incomePatterns;
    
    if (box.isEmpty) {
      final pattern = analyzeIncomePattern();
      box.add(pattern);
      return pattern;
    }

    final pattern = box.values.first;
    
    // Mettre à jour si plus de 24h
    if (DateTime.now().difference(pattern.lastUpdated).inHours > 24) {
      final updated = analyzeIncomePattern();
      pattern.estimatedWeeklyIncome = updated.estimatedWeeklyIncome;
      pattern.minimumObserved = updated.minimumObserved;
      pattern.averageObserved = updated.averageObserved;
      pattern.observationDays = updated.observationDays;
      pattern.lastUpdated = updated.lastUpdated;
      pattern.isRegular = updated.isRegular;
      pattern.save();
    }

    return pattern;
  }

  /// Calcule la variance d'une liste de montants
  static double _calculateVariance(List<double> amounts) {
    if (amounts.isEmpty) return 0;
    
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;
    final squaredDiffs = amounts.map((x) => pow(x - mean, 2));
    
    return squaredDiffs.reduce((a, b) => a + b) / amounts.length;
  }

  /// Estime le prochain revenu probable et sa date
  static Map<String, dynamic> estimateNextIncome() {
    final pattern = getOrCreatePattern();
    
    if (pattern.estimatedWeeklyIncome == 0) {
      return {
        'amount': 0.0,
        'daysUntil': 7,
        'confidence': 'low',
      };
    }

    // Si régulier : prochaine semaine
    // Si irrégulier : estimation prudente sur 2 semaines
    final daysUntil = pattern.isRegular ? 7 : 14;
    
    return {
      'amount': pattern.estimatedWeeklyIncome,
      'daysUntil': daysUntil,
      'confidence': pattern.isRegular ? 'high' : 'medium',
    };
  }
}
