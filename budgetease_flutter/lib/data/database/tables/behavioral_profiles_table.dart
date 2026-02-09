import 'package:drift/drift.dart';

/// Table pour stocker le profil comportemental de l'utilisateur
class BehavioralProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Métriques comportementales
  RealColumn get spendingFrequency => real()(); // transactions par jour
  TextColumn get hourlyPattern => text()(); // JSON {hour: count}
  IntColumn get overrunCount => integer()(); // Nombre de dépassements du Daily Cap
  RealColumn get averageOverrun => real()(); // Montant moyen des dépassements
  
  // Niveau de conseil recommandé
  TextColumn get advisoryLevel => text()(); // 'minimal', 'standard', 'frequent'
  
  // Timestamps
  DateTimeColumn get lastUpdated => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}
