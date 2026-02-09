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

  @HiveField(8)
  String? incomeFrequency; // 'daily', 'weekly', 'monthly' - only for income

  @HiveField(9, defaultValue: 0.0)
  double shadowSavings; // Amount saved via rounding up

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.note,
    required this.createdAt,
    this.incomeFrequency,
    this.shadowSavings = 0.0,
  });

  // Returns the actual cost paid by user (amount - shadowSavings)
  double get realCost => amount - shadowSavings;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'category': category,
        'paymentMethod': paymentMethod,
        'date': date.toIso8601String(),
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'shadowSavings': shadowSavings,
      };
}
