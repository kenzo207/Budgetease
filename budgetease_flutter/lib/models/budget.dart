import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String month; // YYYY-MM

  @HiveField(4)
  DateTime createdAt;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.createdAt,
  });
}
