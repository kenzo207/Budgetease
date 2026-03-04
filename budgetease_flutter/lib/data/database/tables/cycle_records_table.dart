import 'package:drift/drift.dart';

/// Snapshot d'un cycle financier terminé — alimenté le Zolt Engine (history).
///
/// Chaque ligne représente un cycle clôturé (mois, semaine, etc.).
/// Les listes (daily_expenses, category_totals) sont stockées en JSON TEXT.
@DataClassName('CycleRecord')
class CycleRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Dates de début / fin du cycle
  DateTimeColumn get cycleStart => dateTime()();
  DateTimeColumn get cycleEnd   => dateTime()();

  /// Soldes
  RealColumn get openingBalance => real()();
  RealColumn get closingBalance => real()();

  /// Flux
  RealColumn get totalIncome   => real()();
  RealColumn get totalExpenses => real()();

  /// Épargne
  RealColumn get savingsGoal     => real()();
  RealColumn get savingsAchieved => real()();

  /// Dépenses journalières : JSON array de doubles  e.g. "[120.0, 300.0, 0.0]"
  TextColumn get dailyExpensesJson => text().withDefault(const Constant('[]'))();

  /// Totaux par catégorie : JSON array de [String, double]  e.g. [["1", 500.0]]
  TextColumn get categoryTotalsJson => text().withDefault(const Constant('[]'))();

  /// Horodatage de création du snapshot
  DateTimeColumn get createdAt => dateTime()();
}
