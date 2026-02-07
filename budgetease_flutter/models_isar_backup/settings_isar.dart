import 'package:isar/isar.dart';

part 'settings_isar.g.dart';

@collection
class SettingsIsar {
  Id id = Isar.autoIncrement;

  late String currency; // 'FCFA', 'NGN', 'GHS', 'USD', 'EUR'

  late bool notificationEnabled;

  late String notificationTime; // HH:mm

  late bool onboardingCompleted;

  late List<String> favoriteCategories;

  late String budgetPeriod; // 'daily', 'weekly', 'monthly'

  late double sosAmount; // 0.0 means inactive

  final DateTime updatedAt;

  SettingsIsar({
    this.id = Isar.autoIncrement,
    this.currency = 'FCFA',
    this.notificationEnabled = false,
    this.notificationTime = '20:00',
    this.onboardingCompleted = false,
    this.favoriteCategories = const [],
    this.budgetPeriod = 'monthly',
    this.sosAmount = 0.0,
    required this.updatedAt,
  });

  bool get isSosActive => sosAmount > 0;
}
