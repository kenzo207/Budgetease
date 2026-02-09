import 'package:drift/drift.dart';

/// Table pour stocker les insights (Ghost Money, etc.)
class Insights extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Type d'insight
  TextColumn get type => text()(); // 'ghost_money', 'velocity_alert', 'savings_opportunity'
  
  // Données Ghost Money
  RealColumn get totalAmount => real()();
  IntColumn get transactionCount => integer()();
  TextColumn get categoryNames => text()(); // JSON array de catégories
  RealColumn get percentageOfAvailable => real()();
  
  // État
  BoolColumn get isDismissed => boolean().withDefault(const Constant(false))();
  
  // Timestamps
  DateTimeColumn get detectedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}
