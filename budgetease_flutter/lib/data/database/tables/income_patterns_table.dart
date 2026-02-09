import 'package:drift/drift.dart';

/// Table pour stocker les patterns d'analyse de revenus
class IncomePatterns extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Statistiques d'analyse
  RealColumn get estimatedWeeklyIncome => real()();
  RealColumn get minimumObserved => real()();
  RealColumn get maximumObserved => real()();
  RealColumn get averageObserved => real()();
  RealColumn get variance => real()();
  
  // Métadonnées
  BoolColumn get isRegular => boolean()();
  IntColumn get transactionCount => integer()();
  IntColumn get analysisWindowDays => integer().withDefault(const Constant(90))();
  
  // Fréquence détectée
  TextColumn get frequency => text()(); // daily, weekly, biweekly, monthly, irregular, unknown
  DateTimeColumn get nextPredictedDate => dateTime().nullable()();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
