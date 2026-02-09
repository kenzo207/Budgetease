
import 'package:budgetease_flutter/services/daily_snapshots_service.dart';
import 'package:budgetease_flutter/services/daily_cap_calculator.dart';
import 'package:budgetease_flutter/services/shield_service.dart';
import 'package:budgetease_flutter/services/wallet_service.dart';
import 'package:budgetease_flutter/services/security_manager.dart';

/// Service for managing background tasks (midnight carry-over, snapshot creation)
class BackgroundTasksService {
  static const String _dailyTaskName = 'daily_carryover_task';
  static const String _midnightTaskTag = 'midnight_snapshot';

  /// Initialize background tasks
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    print('✅ Background tasks initialized');
  }

  /// Schedule daily midnight task
  static Future<void> scheduleDailyMidnightTask() async {
    await Workmanager().registerPeriodicTask(
      _dailyTaskName,
      _midnightTaskTag,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateDelayUntilMidnight(),
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    print('✅ Daily midnight task scheduled');
  }

  /// Cancel all background tasks
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    print('🗑️ All background tasks cancelled');
  }

  /// Calculate delay until next midnight
  static Duration _calculateDelayUntilMidnight() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  /// Execute daily tasks manually (for testing)
  static Future<void> executeDailyTasksManually() async {
    await _performDailyTasks();
  }

  /// Perform daily tasks (snapshot creation, carry-over check)
  static Future<void> _performDailyTasks() async {
    print('🌙 Executing midnight tasks... (DISABLED FOR MVP)');
    
    // Logic temporarily disabled during migration to Drift/Hive
    // TODO: Re-implement using Drift/Hive when services are ready
    
    /*
    try {
      // Open Database
      // final database = AppDatabase();
      
      // Initialize services
      // final walletService = WalletService(database);
      // final shieldService = ShieldService(database);
      // final dailyCapCalculator = DailyCapCalculator(
      //   database,
      //   shieldService,
      //   walletService,
      // );
      // final snapshotsService = DailySnapshotsService(
      //   database,
      // );

      // Logic would go here...
      
      print('✅ Daily tasks completed successfully');
    } catch (e) {
      print('❌ Daily tasks failed: $e');
    }
    */
  }
}

/// Callback dispatcher for workmanager (must be top-level function)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔔 Background task triggered: $task');

    try {
      await BackgroundTasksService._performDailyTasks();
      return Future.value(true);
    } catch (e) {
      print('❌ Background task failed: $e');
      return Future.value(false);
    }
  });
}
