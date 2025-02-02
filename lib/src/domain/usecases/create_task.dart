import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

import '../entities/task.dart' as task;

class CreateTask implements UseCase<void, task.Task> {
  final TaskRepository repository;

  CreateTask(this.repository);

  @override
  Future<Either<Failure, void>> call(task.Task task) async {
    return await repository.createTask(task);
  }
}
