import 'package:drift/drift.dart';

/// Transaction types for budget tracking
enum TransactionType {
  expense,
  income,
  transfer,
}

/// Wallet types available in the app
enum WalletType {
  cash,
  momoMtn,
  momoMoov,
  momoOrange,
  bankCard,
  other,
}

/// Transactions table - stores all financial transactions
@DataClassName('TransactionData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  /// Type of transaction (expense, income, transfer)
  IntColumn get type => intEnum<TransactionType>()();
  
  /// Date of the transaction
  DateTimeColumn get date => dateTime()();
  
  /// Amount in FCFA
  RealColumn get amount => real()();
  
  /// Category (Alimentation, Transport, etc.)
  TextColumn get category => text()();
  
  /// Source wallet
  IntColumn get sourceWallet => intEnum<WalletType>()();
  
  /// Destination wallet (for transfers)
  IntColumn get destinationWallet => intEnum<WalletType>().withDefault(const Constant(5))();
  
  /// Optional note
  TextColumn get note => text().nullable()();
  
  /// Is this related to shield items?
  BoolColumn get isShieldRelated => boolean().withDefault(const Constant(false))();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
  
  /// Income frequency if applicable
  TextColumn get incomeFrequency => text().nullable()();
  
  /// Shadow savings amount (auto-saved)
  RealColumn get shadowSavings => real().withDefault(const Constant(0.0))();
}
