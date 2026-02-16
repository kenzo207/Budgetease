import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/services/notification_service.dart';

part 'notification_provider.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) {
  return NotificationService();
}

@riverpod
class NotificationSettings extends _$NotificationSettings {
  static const _keyDaily = 'notifications_daily_reminders';
  static const _keyBudget = 'notifications_budget_alerts';

  @override
  Future<Map<String, bool>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'daily': prefs.getBool(_keyDaily) ?? false,
      'budget': prefs.getBool(_keyBudget) ?? true,
    };
  }

  Future<void> toggleDailyReminders(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDaily, enabled);
    
    state = AsyncData({...state.value ?? {}, 'daily': enabled});

    final service = ref.read(notificationServiceProvider);
    if (enabled) {
      final granted = await service.requestPermissions();
      if (granted) {
        await service.scheduleDailyReminder();
      } else {
        // Revert if permission denied
        await prefs.setBool(_keyDaily, false);
        state = AsyncData({...state.value ?? {}, 'daily': false});
      }
    } else {
      await service.cancelDailyReminder();
    }
  }

  Future<void> toggleBudgetAlerts(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBudget, enabled);
    state = AsyncData({...state.value ?? {}, 'budget': enabled});
  }
}
