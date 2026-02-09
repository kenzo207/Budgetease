import 'package:isar/isar.dart';
import 'package:budgetease_flutter/models_isar/wallet_isar.dart';

part 'transaction_isar.g.dart';

enum TransactionType {
  expense,
  income,
  transfer, // New for dual wallet
}

@collection
class TransactionIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late TransactionType type;

  @Index()
  late DateTime date;

  late double amount; // Will migrate to Money type later

  late String category;

  @enumerated
  late WalletType sourceWallet;

  @enumerated
  late WalletType destinationWallet; // For transfers, use WalletType.other if not a transfer

  String? note;

  late bool isShieldRelated; // true if fixed charge/debt/SOS

  late DateTime createdAt;

  // Income specific
  String? incomeFrequency; // 'daily', 'weekly', 'monthly'

  double shadowSavings; // Shadow savings amount

  TransactionIsar({
    this.id = Isar.autoIncrement,
    required this.type,
    required this.date,
    required this.amount,
    required this.category,
    required this.sourceWallet,
    this.destinationWallet = WalletType.other,
    this.note,
    required this.isShieldRelated,
    required this.createdAt,
    this.incomeFrequency,
    this.shadowSavings = 0.0,
  });

  // Helper to check if it's a transfer
  bool get isTransfer => type == TransactionType.transfer && destinationWallet != WalletType.other;

  // Helper to get display amount
  double get displayAmount => amount - shadowSavings;
}
