import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  String currency; // 'FCFA', 'NGN', 'GHS', 'USD', 'EUR'

  @HiveField(1)
  bool notificationEnabled;

  @HiveField(2)
  String notificationTime; // HH:mm

  @HiveField(3)
  bool onboardingCompleted;

  @HiveField(4)
  List<String> favoriteCategories;

  @HiveField(5)
  String budgetPeriod; // 'daily', 'weekly', 'monthly'

  @HiveField(6, defaultValue: 0.0)
  double sosAmount; // 0.0 means inactive

  Settings({
    this.currency = 'FCFA',
    this.notificationEnabled = false,
    this.notificationTime = '20:00',
    this.onboardingCompleted = false,
    this.favoriteCategories = const [],
    this.budgetPeriod = 'monthly',
    this.sosAmount = 0.0,
  });

  bool get isSosActive => sosAmount > 0;
}
