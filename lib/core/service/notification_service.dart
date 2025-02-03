import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/src/presentation/pages/task_detail_page.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';
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

  NotificationService(this.flutterLocalNotificationsPlugin) {
    initialize();
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id,
      'Task Due: ${task.name}',
      task.description,
      tz.TZDateTime.from(task.dueDate, tz.local),
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: task.id.toString(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
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

  void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    final taskId = int.tryParse(payload ?? '');
    if (taskId != null) {
      _navigateToTask(taskId);
    }
  }

  void _navigateToTask(int taskId) {
    final taskStore = GetIt.I<TaskStore>();
    final task = taskStore.tasks.firstWhere((t) => t.id == taskId);
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => TaskDetailPage(task: task)),
    );
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
