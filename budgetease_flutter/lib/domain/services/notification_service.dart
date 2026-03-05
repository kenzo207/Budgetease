import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';
import '../../engine/engine_output.dart' as eng;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ═══════════════════════════════════════════════════════
  // INITIALISATION
  // ═══════════════════════════════════════════════════════

  Future<void> initialize() async {
    if (_initialized) return;

    // Init timezone database
    tz.initializeTimeZones();
    try {
      // flutter_timezone 4.x returns a String directly (IANA timezone name)
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback pour l'Afrique de l'Ouest (cible principale)
      try {
        tz.setLocalLocation(tz.getLocation('Africa/Porto-Novo'));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    }

    // Configuration Android — utiliser l'icône monochrome du launcher
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Le payload peut contenir une route ou un ID de transaction
    // Pour l'instant on ne fait rien, l'app s'ouvre au tap
  }

  Future<void> _createNotificationChannels() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation == null) return;

    // Canal alertes budget (haute priorité)
    const budgetAlertsChannel = AndroidNotificationChannel(
      'budget_alerts',
      'Alertes Budget',
      description: 'Alertes de dépassement de budget',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Canal rappels quotidiens
    const remindersChannel = AndroidNotificationChannel(
      'reminders',
      'Rappels',
      description: 'Rappels quotidiens et check-in',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    // Canal SMS / transactions détectées
    const smsChannel = AndroidNotificationChannel(
      'sms_transactions',
      'Transactions SMS',
      description: 'Nouvelles transactions Mobile Money détectées',
      importance: Importance.high,
      playSound: true,
    );

    // Canal charges récurrentes
    const recurringChannel = AndroidNotificationChannel(
      'recurring_charges',
      'Charges Récurrentes',
      description: 'Rappels de charges récurrentes à venir',
      importance: Importance.high,
      playSound: true,
    );

    await androidImplementation.createNotificationChannel(budgetAlertsChannel);
    await androidImplementation.createNotificationChannel(remindersChannel);
    await androidImplementation.createNotificationChannel(smsChannel);
    await androidImplementation.createNotificationChannel(recurringChannel);
  }

  // ═══════════════════════════════════════════════════════
  // PERMISSIONS
  // ═══════════════════════════════════════════════════════

  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? result =
          await androidImplementation?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════
  // ALERTES BUDGET
  // ═══════════════════════════════════════════════════════

  /// Notification immédiate quand un budget est proche ou dépassé
  Future<void> showBudgetAlert({
    required String categoryName,
    required double spentPercentage,
    required double remainingAmount,
    required String currency,
  }) async {
    final bool isOverBudget = spentPercentage >= 1.0;

    final String title = isOverBudget
        ? '⚠️ Budget dépassé : $categoryName'
        : '⚡ Attention : $categoryName';

    // Barre de progression ASCII
    const int barLength = 10;
    final int filledLength =
        (spentPercentage * barLength).round().clamp(0, barLength);
    final String progressBar =
        '■' * filledLength + '□' * (barLength - filledLength);

    String body;
    if (isOverBudget) {
      body =
          '$progressBar\nBudget dépassé de ${_formatMoney(remainingAmount.abs(), currency)} !';
    } else {
      body =
          '$progressBar ${(spentPercentage * 100).toInt()}%\nReste : ${_formatMoney(remainingAmount, currency)}';
    }

    await flutterLocalNotificationsPlugin.show(
      'budget_$categoryName'.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Alertes Budget',
          channelDescription: 'Alertes de dépassement de budget',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText:
                isOverBudget ? 'Budget Dépassé' : 'Attention Budget',
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

  // ═══════════════════════════════════════════════════════
  // CHECK-IN QUOTIDIEN (programmé à 20h)
  // ═══════════════════════════════════════════════════════

  /// Programmer le rappel quotidien à 20h
  Future<void> scheduleDailyReminder() async {
    await cancelDailyReminder();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      '📝 Check-in du soir',
      'Avez-vous noté vos dépenses aujourd\'hui ?\nUn petit geste pour garder le contrôle !',
      _nextInstanceOfTime(20, 0),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Rappels',
          channelDescription: 'Rappels quotidiens',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancel(999);
  }

  // ═══════════════════════════════════════════════════════
  // NOTIFICATIONS SMS / TRANSACTIONS
  // ═══════════════════════════════════════════════════════

  /// Notification quand de nouvelles transactions SMS sont détectées
  Future<void> showNewSmsTransactions(int count) async {
    if (count <= 0) return;

    await flutterLocalNotificationsPlugin.show(
      1000,
      '📱 $count nouvelle${count > 1 ? 's' : ''} transaction${count > 1 ? 's' : ''} MoMo',
      'Des transactions Mobile Money ont été détectées. Appuyez pour les valider.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sms_transactions',
          'Transactions SMS',
          channelDescription: 'Nouvelles transactions Mobile Money détectées',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'pending_transactions',
    );
  }

  // ═══════════════════════════════════════════════════════
  // DISPATCH ENGINE NOTIFICATIONS (v1.3)
  // ═══════════════════════════════════════════════════════

  /// Exécute une [NotificationTrigger] décidée par le moteur Rust.
  ///
  /// Le moteur décide QUOI et QUAND. Flutter exécute juste.
  /// La déduplication est garantie par le `dedup_key` (hashCode stable).
  Future<void> dispatchEngineNotification(eng.NotificationTrigger trigger) async {
    final notifId = trigger.dedupKey.hashCode.abs() % 100000;
    final channelId = _channelId(trigger.channel);
    final channelName = _channelName(trigger.channel);
    final importance = trigger.isHigh ? Importance.high : Importance.defaultImportance;
    final priority   = trigger.isHigh ? Priority.high   : Priority.defaultPriority;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority:   priority,
        enableVibration: trigger.isHigh,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: trigger.isHigh,
        presentSound: trigger.isHigh,
      ),
    );

    if (trigger.delaySecs > 0) {
      final scheduledDate = tz.TZDateTime.now(tz.local)
          .add(Duration(seconds: trigger.delaySecs));
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notifId,
        trigger.title,
        trigger.body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await flutterLocalNotificationsPlugin.show(
        notifId,
        trigger.title,
        trigger.body,
        details,
      );
    }
  }

  String _channelId(String channel) {
    switch (channel) {
      case 'BudgetAlerts':     return 'budget_alerts';
      case 'RecurringCharges': return 'recurring_charges';
      case 'SmsParsing':       return 'sms_transactions';
      default:                 return 'reminders';
    }
  }

  String _channelName(String channel) {
    switch (channel) {
      case 'BudgetAlerts':     return 'Alertes Budget';
      case 'RecurringCharges': return 'Charges Récurrentes';
      case 'SmsParsing':       return 'Transactions SMS';
      default:                 return 'Rappels';
    }
  }

  // ═══════════════════════════════════════════════════════
  // NOTIFICATIONS CHARGES RÉCURRENTES
  // ═══════════════════════════════════════════════════════

  /// Notification 1 jour avant une charge récurrente
  Future<void> showRecurringChargeReminder({
    required String chargeName,
    required double amount,
    required String currency,
    required DateTime dueDate,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      'recurring_$chargeName'.hashCode,
      '🔔 Charge récurrente demain',
      '$chargeName — ${_formatMoney(amount, currency)}\nPrévue le ${dueDate.day}/${dueDate.month}/${dueDate.year}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_charges',
          'Charges Récurrentes',
          channelDescription: 'Rappels de charges récurrentes à venir',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Programmer une notification pour une charge récurrente
  Future<void> scheduleRecurringChargeNotification({
    required int chargeId,
    required String chargeName,
    required double amount,
    required String currency,
    required DateTime dueDate,
  }) async {
    // Programmer pour la veille à 9h
    final reminderDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - 1,
      9,
      0,
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    final tzDate = tz.TZDateTime.from(reminderDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      2000 + chargeId,
      '🔔 Charge récurrente demain',
      '$chargeName — ${_formatMoney(amount, currency)}',
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_charges',
          'Charges Récurrentes',
          channelDescription: 'Rappels de charges récurrentes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Annuler la notification d'une charge récurrente
  Future<void> cancelRecurringChargeNotification(int chargeId) async {
    await flutterLocalNotificationsPlugin.cancel(2000 + chargeId);
  }

  // ═══════════════════════════════════════════════════════
  // NOTIFICATION TEST
  // ═══════════════════════════════════════════════════════

  /// Envoyer une notification de test (utile pour le debug)
  Future<void> showTestNotification() async {
    await flutterLocalNotificationsPlugin.show(
      9999,
      '✅ Zolt — Notifications actives',
      'Les notifications fonctionnent correctement !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders',
          'Rappels',
          channelDescription: 'Test notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  // ANNULER TOUT
  // ═══════════════════════════════════════════════════════

  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // ═══════════════════════════════════════════════════════
  // UTILITAIRES
  // ═══════════════════════════════════════════════════════

  /// Prochaine occurrence d'une heure donnée
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  String _formatMoney(double amount, String currency) {
    final abs = amount.abs();
    final sign = amount < 0 ? '-' : '';
    if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(1)}M $currency';
    }
    if (abs >= 1000) {
      return '$sign${(abs / 1000).toStringAsFixed(1)}K $currency';
    }
    return '$sign${abs.toStringAsFixed(0)} $currency';
  }
}
