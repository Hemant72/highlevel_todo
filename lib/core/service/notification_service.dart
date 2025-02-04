import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/src/presentation/pages/task_detail_page.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../src/domain/entities/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'task_channel',
    'Task Notifications',
    importance: Importance.high,
    playSound: true,
  );

  NotificationService(this.flutterLocalNotificationsPlugin);

  Future<void> initialize() async {
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      debugPrint('Notification permission denied');
    }

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
    final androidDetails = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Task reminder',
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
      await flutterLocalNotificationsPlugin.zonedSchedule(
        task.id!,
        'Task Due: ${task.name}',
        task.description,
        tz.TZDateTime.from(task.dueDate, tz.local),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id.toString(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
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
    final taskId = int.tryParse(response.payload ?? '');
    if (taskId != null) {
      _navigateToTask(taskId);
    }
  }

  void _navigateToTask(int taskId) {
    final taskStore = GetIt.I<TaskStore>();
    taskStore.getTaskById(taskId).then((result) {
      result.fold(
        (failure) => null,
        (task) => navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
        ),
      );
    });
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  Future<void> handleNotificationAction(String action, int taskId) async {
    final taskController = GetIt.I<TaskStore>();
    final task = taskController.tasks.firstWhere((t) => t.id == taskId);

    switch (action) {
      case 'complete_action':
        await taskController.completeTask(task);
        await cancelNotification(taskId);
        break;
      case 'snooze_action':
        final newDueDate = task.dueDate.add(const Duration(hours: 1));
        await taskController.editTask(task.copyWith(dueDate: newDueDate));
        await cancelNotification(taskId);
        await scheduleTaskNotification(task.copyWith(dueDate: newDueDate));
        break;
    }
  }
}
