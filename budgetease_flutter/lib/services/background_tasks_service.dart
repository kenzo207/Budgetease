import 'package:workmanager/workmanager.dart';
import 'package:isar/isar.dart';
import 'package:budgetease_flutter/services/daily_snapshots_service.dart';
import 'package:budgetease_flutter/services/daily_cap_calculator.dart';
import 'package:budgetease_flutter/services/shield_service.dart';
import 'package:budgetease_flutter/services/wallet_service.dart';
import 'package:budgetease_flutter/services/security_manager.dart';
import 'package:budgetease_flutter/models_isar/transaction_isar.dart';
import 'package:budgetease_flutter/models_isar/wallet_isar.dart';
import 'package:budgetease_flutter/models_isar/shield_item_isar.dart';
import 'package:budgetease_flutter/models_isar/daily_snapshot_isar.dart';
import 'package:budgetease_flutter/models_isar/settings_isar.dart';

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
    print('🌙 Executing midnight tasks...');

    try {
      // Open Isar
      final isar = await SecurityManager.openSecureIsar(
        schemes: [
          TransactionIsarSchema,
          WalletIsarSchema,
          ShieldItemIsarSchema,
          DailySnapshotIsarSchema,
          SettingsIsarSchema,
        ],
      );

      // Initialize services
      final walletService = WalletService(isar);
      final shieldService = ShieldService(isar);
      final dailyCapCalculator = DailyCapCalculator(
        isar,
        shieldService,
        walletService,
      );
      final snapshotsService = DailySnapshotsService(
        isar,
        dailyCapCalculator,
      );

      // Get settings for currency
      final settings = await isar.settingsIsars.where().findFirst();
      final currency = settings?.currency ?? 'FCFA';

      // 1. Recalculate yesterday's spent
      await snapshotsService.recalculateTodaySpent(currency);

      // 2. Process carry-over (returns result if user has savings)
      final carryoverResult = await snapshotsService.processDailyCarryover(currency);

      if (carryoverResult != null && carryoverResult.savedAmount > 0) {
        // User has savings! Should show dialog when app opens
        // For now, just auto-boost tomorrow (can be made configurable)
        await snapshotsService.applyCarryoverChoice(
          savedAmount: carryoverResult.savedAmount,
          choice: CarryoverChoice.boostTomorrow,
          currency: currency,
        );
      }

      print('✅ Daily tasks completed successfully');

      await isar.close();
    } catch (e) {
      print('❌ Daily tasks failed: $e');
    }
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
