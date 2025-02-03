import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/core/service/notification_service.dart';
import 'package:highlevel_todo/src/data/datasources/local_datasource.dart';
import 'package:highlevel_todo/src/data/datasources/task_local_datasource.dart';
import 'package:highlevel_todo/src/data/repositories/task_repository_impl.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';
import 'package:highlevel_todo/src/domain/usecases/create_task.dart';
import 'package:highlevel_todo/src/domain/usecases/delet_task.dart';
import 'package:highlevel_todo/src/domain/usecases/get_task.dart';
import 'package:highlevel_todo/src/domain/usecases/get_task_by_id.dart';
import 'package:highlevel_todo/src/domain/usecases/mark_task_complete.dart';
import 'package:highlevel_todo/src/domain/usecases/snooze_task.dart';
import 'package:highlevel_todo/src/domain/usecases/sort_task.dart';
import 'package:highlevel_todo/src/domain/usecases/update_task.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';
import 'package:path_provider/path_provider.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin());

  getIt.registerLazySingleton<AppDatabase>(
      () => AppDatabase(LazyDatabase(() async {
            final dbFolder = await getApplicationDocumentsDirectory();
            return NativeDatabase(File('${dbFolder.path}/db.sqlite'));
          })));

  getIt.registerLazySingleton<TaskLocalDataSource>(
      () => TaskLocalDataSourceImpl(getIt()));
  getIt.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(
        localDataSource: getIt(),
      ));

  getIt.registerLazySingleton(() => CreateTask(getIt()));
  getIt.registerLazySingleton(() => DeleteTask(getIt()));
  getIt.registerLazySingleton(() => GetTasks(getIt()));
  getIt.registerLazySingleton(() => GetTaskById(getIt()));
  getIt.registerLazySingleton(() => MarkTaskComplete(getIt()));
  getIt.registerLazySingleton(() => SnoozeTask(getIt()));
  getIt.registerLazySingleton(() => SortTasks(getIt()));
  getIt.registerLazySingleton(() => UpdateTask(getIt()));

  getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(getIt()));

  getIt.registerSingleton<TaskStore>(TaskStore(
    notificationService: getIt(),
    createTask: getIt(),
    deleteTask: getIt(),
    getTasks: getIt(),
    getTaskById: getIt(),
    markTaskComplete: getIt(),
    snoozeTask: getIt(),
    sortTasks: getIt(),
    updateTask: getIt(),
  ));
}
