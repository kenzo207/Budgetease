import 'package:hive/hive.dart';

part 'income_pattern.g.dart';

@HiveType(typeId: 6)
class IncomePattern extends HiveObject {
  @HiveField(0)
  double estimatedWeeklyIncome;

  @HiveField(1)
  double minimumObserved;

  @HiveField(2)
  double averageObserved;

  @HiveField(3)
  int observationDays;

  @HiveField(4)
  DateTime lastUpdated;

  @HiveField(5)
  bool isRegular; // true si pattern stable détecté

  IncomePattern({
    required this.estimatedWeeklyIncome,
    required this.minimumObserved,
    required this.averageObserved,
    required this.observationDays,
    required this.lastUpdated,
    required this.isRegular,
  });

  /// Obtenir l'estimation mensuelle basée sur le pattern hebdomadaire
  double get estimatedMonthlyIncome => estimatedWeeklyIncome * 4.33;

  /// Indicateur de confiance dans l'estimation (0-1)
  double get confidenceLevel {
    if (observationDays < 7) return 0.3;
    if (observationDays < 14) return 0.6;
    if (isRegular) return 0.9;
    return 0.7;
  }
}
