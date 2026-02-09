import 'package:drift/drift.dart';

/// Types de comptes supportés
enum AccountType {
  cash,        // Espèces
  mobileMoney, // Mobile Money (MTN, Moov, Orange, Wave)
  bank,        // Compte bancaire
  savings,     // Épargne
}

/// Table des comptes (wallets)
@DataClassName('Account')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get type => intEnum<AccountType>()();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  TextColumn get icon => text()();
  TextColumn get color => text()();
  TextColumn get operator => text().nullable()(); // Pour Mobile Money
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
