import 'package:drift/drift.dart';
import 'accounts_table.dart';
import 'categories_table.dart';

/// Types de transactions
enum TransactionType {
  expense,   // Dépense
  income,    // Revenu
  transfer,  // Virement
}

/// Table des transactions
@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  IntColumn get type => intEnum<TransactionType>()();
  DateTimeColumn get date => dateTime()();
  
  // Relations
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get toAccountId => integer().nullable().references(Accounts, #id)();
  
  // Champs spécifiques
  RealColumn get feeAmount => real().nullable()();
  BoolColumn get isException => boolean().withDefault(const Constant(false))();
  IntColumn get scopeDuration => integer().nullable()(); // Pour revenus temporaires
  TextColumn get scopeType => text().nullable()(); // 'global', 'temporary', 'savings'
  
  TextColumn get description => text().nullable()();
  TextColumn get source => text().nullable()(); // Pour les revenus
  
  DateTimeColumn get createdAt => dateTime()();
}
