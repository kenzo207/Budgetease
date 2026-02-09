import 'package:hive/hive.dart';

part 'fixed_charge.g.dart';

@HiveType(typeId: 4)
class FixedCharge extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String frequency; // 'daily', 'weekly', 'monthly', 'yearly'

  @HiveField(4)
  DateTime nextDueDate;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  String? categoryId;

  FixedCharge({
    required this.id,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.nextDueDate,
    this.isActive = true,
    this.categoryId,
  });
}
