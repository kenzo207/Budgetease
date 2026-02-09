import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

/// Service de gestion des notifications BudgetEase
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialiser le service de notifications
  Future<void> initialize() async {
    if (_initialized) return;

    // Init timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Abidjan')); // Fuseau horaire Abidjan

    // Configuration Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration globale
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer les canaux de notification
    await _createNotificationChannels();

    _initialized = true;
    print('✅ NotificationService initialized');
  }

  /// Créer les canaux de notification Android
  Future<void> _createNotificationChannels() async {
    // Canal Daily Cap
    const dailyCapChannel = AndroidNotificationChannel(
      'daily_cap',
      'Daily Cap Notifications',
      description: 'Notifications quotidiennes du daily cap',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Canal Alerts
    const alertsChannel = AndroidNotificationChannel(
      'budget_alerts',
      'Budget Alerts',
      description: 'Alertes de dépassement budget',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    // Canal Shield
    const shieldChannel = AndroidNotificationChannel(
      'shield_reminders',
      'Shield Reminders',
      description: 'Rappels Shield items',
      importance: Importance.high,
      playSound: true,
    );

    // Canal Summary
    const summaryChannel = AndroidNotificationChannel(
      'daily_summary',
      'Daily Summary',
      description: 'Résumé quotidien',
      importance: Importance.defaultImportance,
      playSound: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(dailyCapChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alertsChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(shieldChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(summaryChannel);

    print('✅ Notification channels created');
  }

  /// Demander la permission de notifications (Android 13+)
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Callback quand notification tappée
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
  }

  /// Afficher notification Daily Cap (8:00 AM)
  Future<void> scheduleDailyCapNotification({
    required double dailyCap,
    required double shieldAmount,
  }) async {
    await _notifications.zonedSchedule(
      0, // ID
      '🌅 Bonjour ! Ton Daily Cap',
      '${dailyCap.toStringAsFixed(0)} FCFA disponibles\nShield protégé : ${shieldAmount.toStringAsFixed(0)} FCFA',
      _nextInstanceOf8AM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_cap',
          'Daily Cap Notifications',
          channelDescription: 'Notifications quotidiennes du daily cap',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('✅ Daily Cap notification scheduled for 8:00 AM');
  }

  /// Afficher alerte dépassement budget
  Future<void> showOverspendingAlert({
    required double overspent,
    required double remaining,
  }) async {
    await _notifications.show(
      1, // ID
      '⚠️ Attention ! Budget dépassé',
      'Tu as dépassé ton Daily Cap de ${overspent.toStringAsFixed(0)} FCFA\nRemaining : ${remaining.toStringAsFixed(0)} FCFA',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          channelDescription: 'Alertes de dépassement budget',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );

    print('✅ Overspending alert shown');
  }

  /// Programmer rappel Shield (7 jours avant)
  Future<void> scheduleShieldReminder({
    required String itemName,
    required double amount,
    required DateTime dueDate,
  }) async {
    final reminderDate = dueDate.subtract(const Duration(days: 7));
    
    if (reminderDate.isBefore(DateTime.now())) {
      return; // Ne pas créer de rappel si déjà passé
    }

    await _notifications.zonedSchedule(
      itemName.hashCode, // ID unique basé sur le nom
      '🛡️ Shield Alert',
      '"$itemName" dû dans 7 jours\nMontant : ${amount.toStringAsFixed(0)} FCFA',
      tz.TZDateTime.from(reminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'shield_reminders',
          'Shield Reminders',
          channelDescription: 'Rappels Shield items',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('✅ Shield reminder scheduled for $itemName');
  }

  /// Afficher résumé quotidien (22:00)
  Future<void> scheduleDailySummary({
    required double spent,
    required double dailyCap,
    required double saved,
  }) async {
    final progress = ((spent / dailyCap) * 100).toStringAsFixed(0);

    await _notifications.zonedSchedule(
      2, // ID
      '📊 Résumé du jour',
      '✅ Dépensé : ${spent.toStringAsFixed(0)} / ${dailyCap.toStringAsFixed(0)} FCFA ($progress%)\n💰 Économisé : ${saved.toStringAsFixed(0)} FCFA',
      _nextInstanceOf10PM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          channelDescription: 'Résumé quotidien',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('✅ Daily summary scheduled for 10:00 PM');
  }

  /// Annuler toutes les notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('✅ All notifications cancelled');
  }

  /// Annuler notification spécifique
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Helper: Prochaine occurrence de 8:00 AM
  tz.TZDateTime _nextInstanceOf8AM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// Helper: Prochaine occurrence de 22:00
  tz.TZDateTime _nextInstanceOf10PM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  /// Test notification
  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'Test BudgetEase',
      'Les notifications fonctionnent ! 🎉',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_cap',
          'Daily Cap Notifications',
          channelDescription: 'Test notification',
          importance: Importance.max,
          priority: Priority.max,
        ),
      ),
    );
  }
}
