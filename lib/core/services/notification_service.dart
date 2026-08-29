import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../models/alms_booking_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );

      // Request Android 13+ notification permissions
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Calculates the previous-day reminder time (default 6:00 PM the day before)
  DateTime getPreviousDayReminderTime(DateTime almsDate, {int hour = 18, int minute = 0}) {
    final previousDay = almsDate.subtract(const Duration(days: 1));
    return DateTime(previousDay.year, previousDay.month, previousDay.day, hour, minute);
  }

  /// Schedules notification for the previous day
  Future<bool> schedulePreviousDayReminder({
    required AlmsBookingModel booking,
    required String templeName,
    required bool isSinhala,
  }) async {
    try {
      await initialize();

      final reminderTime = getPreviousDayReminderTime(booking.date);
      final notificationId = booking.id.hashCode.abs() % 100000;

      final isMorning = booking.almsType == AlmsType.morning;
      final slotTitle = isSinhala
          ? (isMorning ? 'හීල් දානය' : 'දිවා දානය')
          : (isMorning ? 'Morning Alms (Heel Dāna)' : 'Lunch Alms (Diwa Dāna)');

      final title = isSinhala
          ? 'මතක්කිරීම: හෙට දින $slotTitle ඔබගේ වාරයයි'
          : 'Reminder: Tomorrow is your $slotTitle turn';

      final targetTimeStr = isMorning ? (isSinhala ? 'පෙ.ව. 6:00' : '6:00 AM') : (isSinhala ? 'පෙ.ව. 11:00' : '11:00 AM');
      final body = isSinhala
          ? '$templeName විහාරස්ථානයේ සංඝරත්නය ${booking.monksCount} නමක් උදෙසා හෙට $slotTitle පිළියෙළ කිරීමට කාරුණික වන්න. $targetTimeStr ට පෙර රැගෙන එන්න.'
          : 'Tomorrow is your turn to provide $slotTitle for ${booking.monksCount} monks at $templeName. Please arrive by $targetTimeStr.';

      // If scheduled time is already past, trigger an immediate notification for test/demonstration
      final now = DateTime.now();
      if (reminderTime.isBefore(now)) {
        await showInstantNotification(
          id: notificationId,
          title: title,
          body: body,
          payload: booking.id,
        );
        return true;
      }

      final tz.TZDateTime scheduledTZ =
          tz.TZDateTime.from(reminderTime, tz.local);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'alms_reminders_channel',
        'Alms Reminders',
        channelDescription:
            'Reminders sent 1 day prior for scheduled temple alms',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledTZ,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: booking.id,
      );

      debugPrint('Scheduled reminder for ${booking.id} at $scheduledTZ');
      return true;
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      return false;
    }
  }

  /// Sends an instant test notification
  Future<void> showInstantNotification({
    int id = 1,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await initialize();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'alms_reminders_channel',
        'Alms Reminders',
        channelDescription:
            'Reminders sent 1 day prior for scheduled temple alms',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  Future<void> cancelReminder(String bookingId) async {
    final notificationId = bookingId.hashCode.abs() % 100000;
    await _notificationsPlugin.cancel(notificationId);
  }
}
