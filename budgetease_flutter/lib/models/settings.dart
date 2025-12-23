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

  Settings({
    this.currency = 'FCFA',
    this.notificationEnabled = false,
    this.notificationTime = '20:00',
    this.onboardingCompleted = false,
    this.favoriteCategories = const [],
  });
}
