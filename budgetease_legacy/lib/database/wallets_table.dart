import 'package:drift/drift.dart';
import 'transactions_table.dart'; // For WalletType enum

/// Wallets table - stores multi-wallet system
@DataClassName('WalletData')
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  /// Wallet display name (Cash, MTN MoMo, etc.)
  TextColumn get name => text()();
  
  /// Wallet type enum
  IntColumn get type => intEnum<WalletType>()();
  
  /// Current balance in FCFA
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  
  /// Icon emoji for display
  TextColumn get icon => text()();
  
  /// Color hex code
  TextColumn get color => text()();
  
  /// Is wallet active?
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime()();
}
