import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/src/presentation/pages/task_detail_page.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../src/domain/entities/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'task_channel_high',
    'Task Notifications',
    description: 'Notifications for task reminders',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    enableLights: true,
  );

  NotificationService(this.flutterLocalNotificationsPlugin);

  Future<void> initialize() async {
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      debugPrint('Notification permission denied');
    }

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleTaskNotification(Task task) async {
    if (task.dueDate.isBefore(DateTime.now())) {
      debugPrint('Cannot schedule notification for past date');
      return;
    }
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'Task reminder',
      fullScreenIntent: true,
      actions: [
        const AndroidNotificationAction(
          'complete_action',
          'Complete',
          showsUserInterface: false,
        ),
        const AndroidNotificationAction(
          'snooze_action',
          'Snooze',
          showsUserInterface: false,
        ),
      ],
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    try {
      final scheduledDate = tz.TZDateTime.from(
        task.dueDate,
        tz.local,
      ).subtract(const Duration(seconds: 1));
      debugPrint(
          'Scheduling notification for task ${task.id} at $scheduledDate');
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!,
        'Task Due: ${task.name}',
        task.description,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id.toString(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint('Notification scheduled successfully');
    } on PlatformException catch (e) {
      debugPrint('Error scheduling notification: ${e.message}');
      if (e.code == 'exact_alarms_not_permitted') {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          task.id!,
          'Task Due: ${task.name}',
          task.description,
          tz.TZDateTime.from(task.dueDate, tz.local),
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: task.id.toString(),
          androidScheduleMode: AndroidScheduleMode.inexact,
        );
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelNotification(int taskId) async {
    await flutterLocalNotificationsPlugin.cancel(taskId);
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    final taskId = int.tryParse(response.payload ?? '');
    if (taskId != null) {
      _navigateToTask(taskId);
    }
  }

  void _navigateToTask(int taskId) {
    final taskStore = GetIt.I<TaskStore>();
    taskStore.getTaskById(taskId).then((result) {
      result.fold(
        (failure) => debugPrint('Failed to get task: $failure'),
        (task) => navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
        ),
      );
    });
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> handleNotificationAction(String action, int taskId) async {
    final taskStore = GetIt.I<TaskStore>();
    final task = await taskStore.fetchTaskById(taskId);

    await task.fold(
      (failure) async => debugPrint('Failed to handle action: $failure'),
      (task) async {
        switch (action) {
          case 'complete_action':
            await taskStore.completeTask(task);
            await cancelNotification(taskId);
            break;
          case 'snooze_action':
            final newDueDate = DateTime.now().add(const Duration(hours: 1));
            await taskStore.editTask(task.copyWith(dueDate: newDueDate));
            await cancelNotification(taskId);
            await scheduleTaskNotification(task.copyWith(dueDate: newDueDate));
            break;
        }
      },
    );
  }
}
