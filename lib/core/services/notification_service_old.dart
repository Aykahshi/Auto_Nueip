import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:gl_nueip/bloc/clock/clock_cubit.dart';
import 'package:gl_nueip/bloc/lang/lang_cubit.dart';
import 'package:gl_nueip/bloc/remind/remind_cubit.dart';
import 'package:gl_nueip/core/services/nueip_service.dart';
import 'package:gl_nueip/core/utils/enum.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static Future<void> init() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/res_app_icon',
      [
        NotificationChannel(
          channelKey: 'clock_in_out_channel',
          channelName: 'Clock In/Out Notifications',
          channelDescription: 'Notifications for clock in and out reminders',
          channelShowBadge: true,
          playSound: true,
          onlyAlertOnce: true,
          enableVibration: true,
          importance: NotificationImportance.High,
          defaultColor: const Color(0xFF333333),
          ledColor: Colors.white,
        )
      ],
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  Future<bool> checkNotificationPermission() async {
    bool isNotificationAllowed =
        await AwesomeNotifications().isNotificationAllowed();
    bool isScheduleExactAlarmAllowed = await requestAlarmPermission();

    if (!isNotificationAllowed) {
      isNotificationAllowed =
          await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    return isNotificationAllowed && isScheduleExactAlarmAllowed;
  }

  Future<bool> requestAlarmPermission() async {
    bool isScheduleExactAlarmAllowed =
        await Permission.scheduleExactAlarm.isGranted;

    if (Platform.isAndroid) {
      if (!isScheduleExactAlarmAllowed) {
        isScheduleExactAlarmAllowed =
            await Permission.scheduleExactAlarm.request().isGranted;
      }
      return isScheduleExactAlarmAllowed;
    }
    return true;
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
        await AwesomeNotifications().cancel(todayWeekday);
      } else if (clockOut) {
        await AwesomeNotifications().cancel(todayWeekday + 10);
      }
    }
  }

  Future<void> _buildNotification({
    required String method,
    required int weekday,
    required int id,
    required int hour,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'clock_in_out_channel',
        title: locator<LangCubit>().state.language == Language.enUS
            ? method == 'in'
                ? 'Clock In Reminder'
                : 'Clock Out Reminder'
            : method == 'in'
                ? '上班打卡提醒'
                : '下班打卡提醒',
        body: locator<LangCubit>().state.language == Language.enUS
            ? method == 'in'
                ? 'Remember to clock in today!'
                : 'Remember to clock out today!'
            : method == 'in'
                ? '今天上班記得打卡！'
                : '今天下班記得打卡！',
        notificationLayout: NotificationLayout.Default,
        autoDismissible: true,
        wakeUpScreen: true,
      ),
      schedule: NotificationCalendar(
        weekday: weekday,
        hour: hour,
        minute: 50,
        second: 0,
        millisecond: 0,
        timeZone: 'Asia/Taipei',
        repeats: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'CLOCK_${method.toUpperCase()}',
          label: locator<LangCubit>().state.language == Language.enUS
              ? method == 'in'
                  ? 'Clock In'
                  : 'Clock Out'
              : method == 'in'
                  ? '上班打卡'
                  : '下班打卡',
        ),
      ],
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final NueipService service = locator<NueipService>();
    if (receivedAction.buttonKeyPressed == 'CLOCK_IN') {
      service.clockIn();
    } else if (receivedAction.buttonKeyPressed == 'CLOCK_OUT') {
      service.clockOut();
    }
  }

  static Future<void> _cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
