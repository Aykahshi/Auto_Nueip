import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gl_nueip/bloc/clock/clock_cubit.dart';
import 'package:gl_nueip/bloc/lang/lang_cubit.dart';
import 'package:gl_nueip/bloc/remind/remind_cubit.dart';
import 'package:gl_nueip/core/services/nueip_service.dart';
import 'package:gl_nueip/core/utils/enum.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Taipei'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {},
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  static void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    final NueipService service = locator<NueipService>();
    if (payload == 'CLOCK_IN') {
      service.clockIn();
    } else if (payload == 'CLOCK_OUT') {
      service.clockOut();
    }
  }

  Future<bool> checkNotificationPermission() async {
    if (Platform.isIOS) {
      return await _requestIOSPermissions();
    } else if (Platform.isAndroid) {
      return await _requestAndroidPermissions();
    }
    return false;
  }

  Future<bool> _requestIOSPermissions() async {
    return await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
        false;
  }

  Future<bool> _requestAndroidPermissions() async {
    final notificationStatus = await Permission.notification.request();
    final bool notificationPermissionGranted = notificationStatus.isGranted;

    final alarmStatus = await Permission.scheduleExactAlarm.request();
    final bool exactAlarmPermissionGranted = alarmStatus.isGranted;

    final bool? exactAlarmsGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    return notificationPermissionGranted &&
        exactAlarmPermissionGranted &&
        (exactAlarmsGranted ?? false);
  }

  Future<void> checkNotificationsEnabled() async {
    final RemindCubit reminder = locator<RemindCubit>();
    if (reminder.state.isEnabled) {
      await _scheduleNotifications();
    } else {
      await _cancelAllNotifications();
    }
  }

  Future<void> _scheduleNotifications() async {
    for (int weekday = 1; weekday <= 5; weekday++) {
      await _buildNotification(
        method: 'in',
        weekday: weekday,
        id: weekday,
        hour: 9,
      );
      await _buildNotification(
        method: 'out',
        weekday: weekday,
        id: weekday + 10,
        hour: 18,
      );
    }
  }

  Future<void> checkClockedOrNot() async {
    final int todayWeekday = DateTime.now().weekday;

    if (todayWeekday <= 5) {
      final bool clockIn = locator<ClockCubit>().state.isClockedIn;
      final bool clockOut = locator<ClockCubit>().state.isClockedOut;

      if (clockIn) {
        await flutterLocalNotificationsPlugin.cancel(todayWeekday);
      } else if (clockOut) {
        await flutterLocalNotificationsPlugin.cancel(todayWeekday + 10);
      }
    }
  }

  Future<void> _buildNotification({
    required String method,
    required int weekday,
    required int id,
    required int hour,
  }) async {
    final language = locator<LangCubit>().state.language;
    final title = language == Language.enUS
        ? method == 'in'
            ? 'Clock In Reminder'
            : 'Clock Out Reminder'
        : method == 'in'
            ? '上班打卡提醒'
            : '下班打卡提醒';
    final body = language == Language.enUS
        ? method == 'in'
            ? 'Remember to clock in today!'
            : 'Remember to clock out today!'
        : method == 'in'
            ? '今天上班記得打卡！'
            : '今天下班記得打卡！';

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'clock_in_out_channel',
      'Clock In/Out Notifications',
      channelDescription: 'Notifications for clock in and out reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeekday(weekday, hour),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: 'CLOCK_${method.toUpperCase()}',
    );
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, 50);
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> _cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
