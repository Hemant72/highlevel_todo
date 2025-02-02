import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

import '../entities/task.dart' as task;

class GetTasks implements UseCase<List<task.Task>, NoParams> {
  final TaskRepository repository;

  GetTasks(this.repository);

  @override
  Future<Either<Failure, List<task.Task>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}
