import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

import '../entities/task.dart' as task;

class UpdateTask implements UseCase<void, task.Task> {
  final TaskRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Either<Failure, void>> call(task.Task task) async {
    return await repository.updateTask(task);
  }
}
