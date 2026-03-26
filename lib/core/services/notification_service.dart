import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;

    // Request notification permission on Android 13+
    _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleDebtReminder({
    required int debtId,
    required String personName,
    required bool isLent,
    required DateTime dueDate,
  }) async {
    if (!_initialized) return;

    final now = DateTime.now();
    if (dueDate.isBefore(now)) return;

    final title = 'Rappel dette';
    final body = isLent
        ? '$personName devait vous rembourser aujourd\'hui'
        : 'Vous devez rembourser $personName aujourd\'hui';

    final scheduledDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      9, // 9h du matin
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      _notificationId(debtId),
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'debt_reminders',
          'Rappels de dettes',
          channelDescription: 'Notifications pour les échéances de dettes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  static Future<void> cancelDebtReminder(int debtId) async {
    if (!_initialized) return;
    await _plugin.cancel(_notificationId(debtId));
  }

  // ───────── Daily Transaction Reminder ─────────

  static const int _dailyReminderId = 99999;

  /// Call on app start after loading transactions.
  /// If the user already has a transaction today, push the reminder to tomorrow.
  /// Otherwise, schedule it for today at 20:00.
  static Future<void> scheduleDailyReminder({
    required bool hasTransactionToday,
  }) async {
    if (!_initialized) return;

    await _plugin.cancel(_dailyReminderId);

    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime target;

    if (hasTransactionToday) {
      target = _nextDayAt(now, 20);
    } else {
      final todayAt20 = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
      target = todayAt20.isAfter(now) ? todayAt20 : _nextDayAt(now, 20);
    }

    await _scheduleDaily(target);
  }

  /// Call every time a transaction is recorded to push the reminder to tomorrow.
  static Future<void> onTransactionRecorded() async {
    if (!_initialized) return;

    await _plugin.cancel(_dailyReminderId);
    final now = tz.TZDateTime.now(tz.local);
    await _scheduleDaily(_nextDayAt(now, 20));
  }

  static tz.TZDateTime _nextDayAt(tz.TZDateTime from, int hour) {
    return tz.TZDateTime(tz.local, from.year, from.month, from.day + 1, hour);
  }

  static Future<void> _scheduleDaily(tz.TZDateTime target) async {
    await _plugin.zonedSchedule(
      _dailyReminderId,
      'N\'oubliez pas vos dépenses !',
      'Vous n\'avez pas encore saisi de transaction aujourd\'hui. '
          'Prenez 30 secondes pour enregistrer vos dépenses.',
      target,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Rappel quotidien',
          channelDescription: 'Rappel pour saisir vos transactions du jour',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static int _notificationId(int debtId) => 10000 + debtId;
}
