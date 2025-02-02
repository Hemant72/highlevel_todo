import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

import '../entities/task.dart' as task;

class SnoozeTask implements UseCase<void, task.Task> {
  final TaskRepository repository;

  SnoozeTask(this.repository);

  @override
  Future<Either<Failure, void>> call(task.Task task) async {
    final updatedTask =
        task.copyWith(dueDate: task.dueDate.add(Duration(hours: 1)));
    return await repository.updateTask(updatedTask);
  }
}
