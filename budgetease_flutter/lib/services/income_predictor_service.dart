import 'package:isar/isar.dart';
import 'package:budgetease_flutter/models_isar/transaction_isar.dart';
import 'package:budgetease_flutter/utils/money.dart';

/// Service for analyzing income patterns and predicting future income
class IncomePredictorService {
  final Isar isar;

  IncomePredictorService(this.isar);

  // ========== Income Pattern Analysis ==========

  /// Analyze income pattern over last N days
  Future<IncomePattern> analyzeIncomePattern({
    int analysisWindowDays = 90,
    String currency = 'FCFA',
  }) async {
    final now = DateTime.now();
    final windowStart = now.subtract(Duration(days: analysisWindowDays));

    // Get all income transactions in window
    final incomes = await isar.transactionIsars
        .filter()
        .typeEqualTo(TransactionType.income)
        .and()
        .dateGreaterThan(windowStart)
        .sortByDate()
        .findAll();

    if (incomes.isEmpty) {
      return IncomePattern(
        estimatedWeeklyIncome: Money.zero(currency),
        minimumObserved: Money.zero(currency),
        maximumObserved: Money.zero(currency),
        averageObserved: Money.zero(currency),
        isRegular: false,
        transactionCount: 0,
        analysisWindowDays: analysisWindowDays,
      );
    }

    // Group incomes by week
    final weeklyTotals = _groupByWeek(incomes);

    // Calculate statistics
    final weeklyAmounts = weeklyTotals.values.toList();
    final average = _calculateAverage(weeklyAmounts);
    final min = _calculateMin(weeklyAmounts);
    final max = _calculateMax(weeklyAmounts);
    final variance = _calculateVariance(weeklyAmounts, average);

    // Determine if income is regular (variance < 20% of average)
    final isRegular = average > 0 && variance < (average * 0.2);

    // Calculate weighted average (recent weeks have more weight)
    final weightedAverage = _calculateWeightedAverage(weeklyTotals);

    return IncomePattern(
      estimatedWeeklyIncome: Money(weightedAverage, currency),
      minimumObserved: Money(min, currency),
      maximumObserved: Money(max, currency),
      averageObserved: Money(average, currency),
      isRegular: isRegular,
      transactionCount: incomes.length,
      analysisWindowDays: analysisWindowDays,
    );
  }

  /// Predict monthly income based on pattern
  Future<Money> predictMonthlyIncome(String currency) async {
    final pattern = await analyzeIncomePattern(currency: currency);

    // Convert weekly to monthly (4.33 weeks per month)
    return pattern.estimatedWeeklyIncome * 4.33;
  }

  /// Predict income for current month if no income recorded yet
  Future<Money> getEstimatedMonthlyIncome(String currency) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    // Check if any income recorded this month
    final currentMonthIncome = await isar.transactionIsars
        .filter()
        .typeEqualTo(TransactionType.income)
        .and()
        .dateGreaterThan(monthStart)
        .findAll();

    if (currentMonthIncome.isNotEmpty) {
      // Use actual income
      final total = currentMonthIncome
          .map((t) => t.amount)
          .reduce((a, b) => a + b);
      return Money(total, currency);
    }

    // No income yet, use prediction
    return await predictMonthlyIncome(currency);
  }

  // ========== Income Frequency Detection ==========

  /// Detect how often user receives income
  Future<IncomeFrequency> detectIncomeFrequency() async {
    final now = DateTime.now();
    final last90Days = now.subtract(const Duration(days: 90));

    final incomes = await isar.transactionIsars
        .filter()
        .typeEqualTo(TransactionType.income)
        .and()
        .dateGreaterThan(last90Days)
        .sortByDate()
        .findAll();

    if (incomes.length < 2) {
      return IncomeFrequency.unknown;
    }

    // Calculate average days between income transactions
    final intervals = <int>[];
    for (int i = 1; i < incomes.length; i++) {
      final days = incomes[i].date.difference(incomes[i - 1].date).inDays;
      intervals.add(days);
    }

    final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;

    // Classify frequency
    if (avgInterval <= 2) {
      return IncomeFrequency.daily;
    } else if (avgInterval <= 9) {
      return IncomeFrequency.weekly;
    } else if (avgInterval <= 16) {
      return IncomeFrequency.biweekly;
    } else if (avgInterval <= 35) {
      return IncomeFrequency.monthly;
    } else {
      return IncomeFrequency.irregular;
    }
  }

  // ========== Next Income Prediction ==========

  /// Predict when next income is likely to arrive
  Future<DateTime?> predictNextIncomeDate() async {
    final frequency = await detectIncomeFrequency();
    
    if (frequency == IncomeFrequency.unknown || 
        frequency == IncomeFrequency.irregular) {
      return null;
    }

    // Get last income date
    final lastIncome = await isar.transactionIsars
        .filter()
        .typeEqualTo(TransactionType.income)
        .sortByDateDesc()
        .findFirst();

    if (lastIncome == null) return null;

    final lastDate = lastIncome.date;

    // Calculate next date based on frequency
    switch (frequency) {
      case IncomeFrequency.daily:
        return lastDate.add(const Duration(days: 1));
      case IncomeFrequency.weekly:
        return lastDate.add(const Duration(days: 7));
      case IncomeFrequency.biweekly:
        return lastDate.add(const Duration(days: 14));
      case IncomeFrequency.monthly:
        return DateTime(lastDate.year, lastDate.month + 1, lastDate.day);
      default:
        return null;
    }
  }

  /// Get days until next expected income
  Future<int?> getDaysUntilNextIncome() async {
    final nextDate = await predictNextIncomeDate();
    
    if (nextDate == null) return null;

    final remaining = nextDate.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  // ========== Private Helpers ==========

  /// Group transactions by week number
  Map<int, double> _groupByWeek(List<TransactionIsar> transactions) {
    final weeklyTotals = <int, double>{};

    for (var tx in transactions) {
      final weekNumber = _getWeekNumber(tx.date);
      weeklyTotals[weekNumber] = (weeklyTotals[weekNumber] ?? 0) + tx.amount;
    }

    return weeklyTotals;
  }

  /// Get week number from date
  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(startOfYear).inDays;
    return (daysDifference / 7).floor();
  }

  /// Calculate average
  double _calculateAverage(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculate min
  double _calculateMin(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a < b ? a : b);
  }

  /// Calculate max
  double _calculateMax(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  /// Calculate variance
  double _calculateVariance(List<double> values, double mean) {
    if (values.isEmpty) return 0;
    
    final squaredDiffs = values.map((v) => (v - mean) * (v - mean));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  /// Calculate weighted average (recent weeks = higher weight)
  double _calculateWeightedAverage(Map<int, double> weeklyTotals) {
    if (weeklyTotals.isEmpty) return 0;

    final weeks = weeklyTotals.keys.toList()..sort();
    
    double weightedSum = 0;
    double weightTotal = 0;

    for (int i = 0; i < weeks.length; i++) {
      final week = weeks[i];
      final weight = (i + 1).toDouble(); // Linear weight increase
      weightedSum += weeklyTotals[week]! * weight;
      weightTotal += weight;
    }

    return weightTotal > 0 ? weightedSum / weightTotal : 0;
  }
}

// ========== Models ==========

/// Income pattern analysis result
class IncomePattern {
  final Money estimatedWeeklyIncome;
  final Money minimumObserved;
  final Money maximumObserved;
  final Money averageObserved;
  final bool isRegular;
  final int transactionCount;
  final int analysisWindowDays;

  IncomePattern({
    required this.estimatedWeeklyIncome,
    required this.minimumObserved,
    required this.maximumObserved,
    required this.averageObserved,
    required this.isRegular,
    required this.transactionCount,
    required this.analysisWindowDays,
  });

  /// Get confidence level (0.0 - 1.0)
  double get confidence {
    if (transactionCount < 3) return 0.0;
    if (transactionCount < 8) return 0.5;
    if (isRegular) return 0.9;
    return 0.7;
  }

  /// Get status message
  String get statusMessage {
    if (transactionCount < 3) {
      return 'Not enough data. Record more income to get accurate predictions.';
    } else if (isRegular) {
      return 'Regular income detected. Predictions are reliable.';
    } else {
      return 'Irregular income detected. Using conservative estimates.';
    }
  }
}

/// Income frequency classification
enum IncomeFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  irregular,
  unknown,
}
