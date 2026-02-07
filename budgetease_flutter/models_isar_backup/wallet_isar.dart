import 'package:isar/isar.dart';

part 'wallet_isar.g.dart';

@collection
class WalletIsar {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name; // "Cash", "MTN MoMo", "Orange Money"

  @enumerated
  late WalletType type;

  late double balance;

  late String icon; // Emoji

  late String color; // Hex color

  late bool isActive;

  late DateTime createdAt;

  WalletIsar({
    this.id = Isar.autoIncrement,
    required this.name,
    required this.type,
    this.balance = 0.0,
    required this.icon,
    required this.color,
    this.isActive = true,
    required this.createdAt,
  });
}

// Reuse enum from transaction_isar
enum WalletType {
  cash,
  momoMtn,
  momoMoov,
  momoOrange,
  bankCard,
  other,
}
