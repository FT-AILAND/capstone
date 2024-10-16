import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones(); // test

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Request SCHEDULE_EXACT_ALARM permission on Android 12 and above
  Future<void> requestExactAlarmPermission() async {
    if (Platform.isAndroid && (await _isAndroid12OrAbove())) {
      final status = await Permission.scheduleExactAlarm.request();
      if (status.isDenied) {
        print("Exact alarm permission denied");
      }
    }
  }

  Future<bool> _isAndroid12OrAbove() async {
    return Platform.isAndroid && (await Permission.scheduleExactAlarm.isDenied);
  }

  Future<void> scheduleDailyNotification(DateTime scheduledTime) async {
    tz.TZDateTime _nextInstanceOfTime(DateTime scheduledTime) {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      print("Next instance of time: $scheduledDate");

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        print(
            "Scheduled time was in the past, rescheduling for next day: $scheduledDate");
      }

      return scheduledDate;
    }

    const int notificationId = 0;

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'daily_channel', // Unique channel ID
      'Daily Notification Channel', // Channel name
      channelDescription:
          'This channel is used for daily scheduled notifications',
      importance: Importance.high, // High importance
    );
    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await requestExactAlarmPermission(); // Request exact alarm permission on Android 12+

    print("Scheduling notification at: $scheduledTime");

    print('Scheduled notification time: $scheduledTime');
    await flutterLocalNotificationsPlugin
        .zonedSchedule(
      notificationId,
      'AIT',
      '운동 시간입니다! 운동을 시작하세요!',

      _nextInstanceOfTime(scheduledTime),
      notificationDetails,
      androidAllowWhileIdle: true, // Make sure this is set
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    )
        .then((_) {
      print("Notification scheduled successfully");
    }).catchError((error) {
      print("Failed to schedule notification: $error");
    });
  }

  Future<PermissionStatus> requestNotificationPermissions() async {
    return await Permission.notification.request();
  }

  Future<void> scheduleImmediateNotification() async {
    const int notificationId = 1;

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notification Channel',
      channelDescription: 'This channel is used for test notifications',
      importance: Importance.high,
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    final DateTime now = DateTime.now();
    final tz.TZDateTime scheduledTime =
        tz.TZDateTime.from(now.add(Duration(seconds: 5)), tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      'Test Notification',
      'This is a test notification!',
      scheduledTime,
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
