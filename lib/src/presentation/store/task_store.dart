import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/service/notification_service.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/usecases/create_task.dart';
import 'package:highlevel_todo/src/domain/usecases/delet_task.dart';
import 'package:highlevel_todo/src/domain/usecases/get_task.dart';
import 'package:highlevel_todo/src/domain/usecases/get_task_by_id.dart';
import 'package:highlevel_todo/src/domain/usecases/mark_task_complete.dart';
import 'package:highlevel_todo/src/domain/usecases/snooze_task.dart';
import 'package:highlevel_todo/src/domain/usecases/sort_task.dart';
import 'package:highlevel_todo/src/domain/usecases/update_task.dart';
import 'package:mobx/mobx.dart';

import '../../domain/entities/task.dart' as task;

part 'task_store.g.dart';

// ignore: library_private_types_in_public_api
class TaskStore = _TaskStoreBase with _$TaskStore;

abstract class _TaskStoreBase with Store {
  final NotificationService notificationService;
  final CreateTask createTask;
  final DeleteTask deleteTask;
  final GetTasks getTasks;
  final GetTaskById getTaskById;
  final MarkTaskComplete markTaskComplete;
  final SnoozeTask snoozeTask;
  final SortTasks sortTasks;
  final UpdateTask updateTask;

  _TaskStoreBase({
    required this.createTask,
    required this.deleteTask,
    required this.getTasks,
    required this.getTaskById,
    required this.markTaskComplete,
    required this.snoozeTask,
    required this.sortTasks,
    required this.updateTask,
    required this.notificationService,
  });

  @observable
  ObservableList<task.Task> tasks = ObservableList<task.Task>();

  @action
  Future<void> fetchTasks() async {
    final result = await getTasks(NoParams());
    result.fold(
      (failure) => null,
      (tasks) => this.tasks = ObservableList.of(tasks),
    );
  }

  @action
  Future<Either<Failure, task.Task>> fetchTaskById(int id) async {
    return await getTaskById(id);
  }

  @action
  Future<void> addTask(task.Task task) async {
    final result = await createTask(task);
    result.fold(
      (failure) => null,
      (createdTask) {
        tasks.add(createdTask);
        notificationService.scheduleTaskNotification(createdTask);
      },
    );
  }

  @action
  Future<void> removeTask(int id) async {
    final result = await deleteTask(id);
    result.fold(
      (failure) => null,
      (_) => tasks.removeWhere((task) => task.id == id),
    );
  }

  @action
  Future<void> completeTask(task.Task task) async {
    final result = await markTaskComplete(task);
    result.fold(
      (failure) => null,
      (_) {
        final index = tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          tasks[index] = task.copyWith(isCompleted: true);
          tasks = ObservableList.of(tasks);
        }
      },
    );
  }

  @action
  Future<void> postponeTask(task.Task task) async {
    final result = await snoozeTask(task);
    result.fold(
      (failure) => null,
      (_) => fetchTasks(),
    );
  }

  @action
  Future<void> sortTaskList(bool ascending) async {
    final result = await sortTasks(SortParams(ascending));
    result.fold(
      (failure) => null,
      (sortedTasks) => tasks = ObservableList.of(sortedTasks),
    );
  }

  @action
  Future<void> editTask(task.Task task) async {
    final result = await updateTask(task);
    result.fold(
      (failure) => null,
      (_) => fetchTasks(),
    );
  }
}
