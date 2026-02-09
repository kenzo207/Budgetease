import 'package:drift/drift.dart';
import 'accounts_table.dart';

/// Table des transactions en attente (détectées par SMS)
@DataClassName('PendingTransaction')
class PendingTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get operator => text()(); // MTN, Moov, Orange, Wave
  TextColumn get rawSms => text()();
  DateTimeColumn get smsDate => dateTime()();
  TextColumn get transactionId => text().nullable()(); // ID de la transaction Mobile Money
  BoolColumn get isProcessed => boolean().withDefault(const Constant(false))();
  IntColumn get suggestedAccountId => integer().nullable().references(Accounts, #id)();
  DateTimeColumn get createdAt => dateTime()();
}
