import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

import '../entities/task.dart' as task;

class GetTaskById implements UseCase<task.Task, int> {
  final TaskRepository repository;

  GetTaskById(this.repository);

  @override
  Future<Either<Failure, task.Task>> call(int id) async {
    return await repository.getTaskById(id);
  }
}
