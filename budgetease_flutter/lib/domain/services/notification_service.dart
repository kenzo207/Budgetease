import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      // On some platforms/versions, getLocalTimezone returns a String, on others (Linux?) a TimezoneInfo object?
      // Based on error: "The argument type 'TimezoneInfo' can't be assigned to the parameter type 'String'".
      // So it returns TimezoneInfo. I will try .id or .name.
      // Let's assume .id based on IANA standard usage. Or just cast to dynamic and access property if uncertain?
      // Better: try .id. If compile fails, I'll know.
      // Actually, standard flutter_timezone returns String. This might be a linux-specific return type?
      // Let's try to treat it as dynamic to avoid compile error if property exists, or just try .id.
      // But wait, the previous build error proved it IS TimezoneInfo.
      // I'll try .id.
      tz.setLocalLocation(tz.getLocation((timeZoneInfo as dynamic).id));
    } catch (e) {
      print('Failed to get local timezone: $e');
      // Fallback to UTC
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel budgetAlertsChannel = AndroidNotificationChannel(
      'budget_alerts',
      'Alertes Budget',
      description: 'Notifications critiques pour le dépassement de budget',
      importance: Importance.high,
      playSound: true,
    );

    const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
      'reminders',
      'Rappels',
      description: 'Rappels quotidiens et charges récurrentes',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(budgetAlertsChannel);
      await androidImplementation.createNotificationChannel(remindersChannel);
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? result = await androidImplementation?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  // --- Zolt Style Notifications ---

  /// Afficher une alerte de budget critique
  Future<void> showBudgetAlert({
    required String categoryName,
    required double spentPercentage,
    required double remainingAmount,
    required String currency,
  }) async {
    final bool isOverBudget = spentPercentage >= 1.0;
    
    final String title = isOverBudget 
        ? 'Alerte Budget : $categoryName' 
        : 'Attention Budget : $categoryName';
    
    // Create visual progress bar (ASCII)
    const int barLength = 10;
    final int filledLength = (spentPercentage * barLength).round().clamp(0, barLength);
    final String progressBar = '■' * filledLength + '□' * (barLength - filledLength);
    
    String body;
    if (isOverBudget) {
      body = 'Budget dépassé !\n$progressBar\nVous avez dépassé votre limite de ${_formatMoney(remainingAmount.abs(), currency)}.';
    } else {
      body = 'Consommation actuelle\n$progressBar\nVous êtes à ${(spentPercentage * 100).toInt()}% du budget.\nReste : ${_formatMoney(remainingAmount, currency)}';
    }

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond, // Unique ID based on time
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Alertes Budget',
          channelDescription: 'Notifications critiques pour le dépassement de budget',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: isOverBudget ? 'Budget Dépassé' : 'Attention Budget',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Programmer le check-in quotidien
  Future<void> scheduleDailyReminder() async {
    // Annuler l'ancien d'abord
    await cancelDailyReminder();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999, // ID fixe pour le rappel quotidien
      'Check-in Quotidien',
      'Avez-vous dépensé de l\'argent aujourd\'hui ?\nGardez vos comptes à jour en un clic !',
      _nextInstanceOf8PM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Rappels',
          channelDescription: 'Rappels quotidiens',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Répéter chaque jour à la même heure
    );
  }

  Future<void> cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(999);
  }

  tz.TZDateTime _nextInstanceOf8PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 20); // 20h00
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  String _formatMoney(double amount, String currency) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k $currency'; // 15.0k FCFA
    }
    return '${amount.toStringAsFixed(0)} $currency';
  }
}
