import 'package:drift/drift.dart';

/// Catégories de revenus fixes
enum IncomeCategory {
  pocket_money, // Argent de poche
  salary,       // Salaire
  freelance,    // Missions / Freelance
  business,     // Recettes (Commerce)
  allowance,    // Pension / Allocation
  other,        // Autre
}

/// Fréquences de paiement
enum IncomeFrequency {
  daily_x_times, // Journalier (X fois par semaine)
  weekly,        // Hebdomadaire
  monthly,       // Mensuel
}

/// Table des revenus réguliers
@DataClassName('RecurringIncome')
class RecurringIncomes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get type => intEnum<IncomeCategory>()();
  RealColumn get amount => real()();
  IntColumn get frequency => intEnum<IncomeFrequency>()();
  
  // Utilisé si frequency == IncomeFrequency.daily_x_times (1 à 7)
  IntColumn get daysPerWeek => integer().nullable()();
  
  // Utilisé pour l'affichage du widget d'attente sur le Dashboard
  DateTimeColumn get nextDepositDate => dateTime()();
  
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}
