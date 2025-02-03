import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/usecases/create_task.dart';
import 'package:highlevel_todo/src/domain/usecases/delet_task.dart';
import 'package:highlevel_todo/src/domain/usecases/get_task.dart';
import 'package:highlevel_todo/src/domain/usecases/mark_task_complete.dart';
import 'package:highlevel_todo/src/domain/usecases/snooze_task.dart';
import 'package:highlevel_todo/src/domain/usecases/sort_task.dart';
import 'package:highlevel_todo/src/domain/usecases/update_task.dart';
import 'package:mobx/mobx.dart';

import '../../domain/entities/task.dart';

part 'task_store.g.dart';

// ignore: library_private_types_in_public_api
class TaskStore = _TaskStoreBase with _$TaskStore;

abstract class _TaskStoreBase with Store {
  final CreateTask createTask;
  final DeleteTask deleteTask;
  final GetTasks getTasks;
  final MarkTaskComplete markTaskComplete;
  final SnoozeTask snoozeTask;
  final SortTasks sortTasks;
  final UpdateTask updateTask;

  _TaskStoreBase({
    required this.createTask,
    required this.deleteTask,
    required this.getTasks,
    required this.markTaskComplete,
    required this.snoozeTask,
    required this.sortTasks,
    required this.updateTask,
  });

  @observable
  ObservableList<Task> tasks = ObservableList<Task>();

  @action
  Future<void> fetchTasks() async {
    final result = await getTasks(NoParams());
    result.fold(
      (failure) => null,
      (tasks) => this.tasks = ObservableList.of(tasks),
    );
  }

  @action
  Future<void> addTask(Task task) async {
    final result = await createTask(task);
    result.fold(
      (failure) => null,
      (_) => tasks.add(task),
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
  Future<void> completeTask(Task task) async {
    final result = await markTaskComplete(task);
    result.fold(
      (failure) => null,
      (_) => tasks.remove(task),
    );
  }

  @action
  Future<void> postponeTask(Task task) async {
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
  Future<void> editTask(Task task) async {
    final result = await updateTask(task);
    result.fold(
      (failure) => null,
      (_) => fetchTasks(),
    );
  }
}
