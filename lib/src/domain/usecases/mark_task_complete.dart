import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

import '../entities/task.dart' as task;

class MarkTaskComplete implements UseCase<void, task.Task> {
  final TaskRepository repository;

  MarkTaskComplete(this.repository);

  @override
  Future<Either<Failure, void>> call(task.Task task) async {
    final updatedTask = task.copyWith(isCompleted: true);
    return await repository.updateTask(updatedTask);
  }
}
