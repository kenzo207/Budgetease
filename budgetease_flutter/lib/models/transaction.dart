import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String type; // 'expense' | 'income'

  @HiveField(2)
  double amount;

  @HiveField(3)
  String category;

  @HiveField(4)
  String paymentMethod; // 'MoMo' | 'Cash' | 'Carte'

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  String? note;

  @HiveField(7)
  DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'category': category,
        'paymentMethod': paymentMethod,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };
}
