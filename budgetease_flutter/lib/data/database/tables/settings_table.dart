import 'package:drift/drift.dart';

/// Cycles financiers de l'utilisateur
enum FinancialCycle {
  monthly,    // Mensuel (Salariés)
  weekly,     // Hebdomadaire (Commerçants)
  daily,      // Journalier (Travailleurs journaliers)
  irregular,  // Irrégulier (Freelance)
}

/// Modes de transport
enum TransportMode {
  fixed,      // Abonnement/Fixe
  daily,      // Quotidien
  none,       // Pas de transport
}

/// Table des paramètres utilisateur
@DataClassName('UserSettings')
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Configuration utilisateur
  TextColumn get userName => text()();
  TextColumn get currency => text().withDefault(const Constant('FCFA'))();
  IntColumn get financialCycle => intEnum<FinancialCycle>()();
  
  // Transport
  IntColumn get transportMode => intEnum<TransportMode>()();
  RealColumn get dailyTransportCost => real().nullable()();
  IntColumn get transportDaysPerWeek => integer().nullable()();
  RealColumn get fixedTransportAmount => real().nullable()();
  
  // Sécurité
  BoolColumn get biometricEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get pinEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get discreteModeEnabled => boolean().withDefault(const Constant(false))();
  
  // Permissions
  BoolColumn get smsParsingEnabled => boolean().withDefault(const Constant(false))();
  
  // Épargne
  RealColumn get savingsGoal => real().withDefault(const Constant(0.0))();
  
  // Onboarding
  BoolColumn get onboardingCompleted => boolean().withDefault(const Constant(false))();
  
  // Theme
  TextColumn get borderColor => text().withDefault(const Constant('#4CAF50')).nullable()();
  
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
