// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$TaskStore on _TaskStoreBase, Store {
  late final _$tasksAtom = Atom(name: '_TaskStoreBase.tasks', context: context);

  @override
  ObservableList<task.Task> get tasks {
    _$tasksAtom.reportRead();
    return super.tasks;
  }

  @override
  set tasks(ObservableList<task.Task> value) {
    _$tasksAtom.reportWrite(value, super.tasks, () {
      super.tasks = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_TaskStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_TaskStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$fetchTasksAsyncAction =
      AsyncAction('_TaskStoreBase.fetchTasks', context: context);

  @override
  Future<void> fetchTasks() {
    return _$fetchTasksAsyncAction.run(() => super.fetchTasks());
  }

  late final _$fetchTaskByIdAsyncAction =
      AsyncAction('_TaskStoreBase.fetchTaskById', context: context);

  @override
  Future<Either<Failure, task.Task>> fetchTaskById(int id) {
    return _$fetchTaskByIdAsyncAction.run(() => super.fetchTaskById(id));
  }

  late final _$addTaskAsyncAction =
      AsyncAction('_TaskStoreBase.addTask', context: context);

  @override
  Future<void> addTask(task.Task task) {
    return _$addTaskAsyncAction.run(() => super.addTask(task));
  }

  late final _$removeTaskAsyncAction =
      AsyncAction('_TaskStoreBase.removeTask', context: context);

  @override
  Future<void> removeTask(int id) {
    return _$removeTaskAsyncAction.run(() => super.removeTask(id));
  }

  late final _$completeTaskAsyncAction =
      AsyncAction('_TaskStoreBase.completeTask', context: context);

  @override
  Future<void> completeTask(task.Task task) {
    return _$completeTaskAsyncAction.run(() => super.completeTask(task));
  }

  late final _$postponeTaskAsyncAction =
      AsyncAction('_TaskStoreBase.postponeTask', context: context);

  @override
  Future<void> postponeTask(task.Task task) {
    return _$postponeTaskAsyncAction.run(() => super.postponeTask(task));
  }

  late final _$sortTaskListAsyncAction =
      AsyncAction('_TaskStoreBase.sortTaskList', context: context);

  @override
  Future<void> sortTaskList(bool ascending) {
    return _$sortTaskListAsyncAction.run(() => super.sortTaskList(ascending));
  }

  late final _$editTaskAsyncAction =
      AsyncAction('_TaskStoreBase.editTask', context: context);

  @override
  Future<void> editTask(task.Task task) {
    return _$editTaskAsyncAction.run(() => super.editTask(task));
  }

  @override
  String toString() {
    return '''
tasks: ${tasks},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
