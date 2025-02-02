import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

import '../entities/task.dart' as task;

class SortTasks implements UseCase<List<task.Task>, SortParams> {
  final TaskRepository repository;

  SortTasks(this.repository);

  @override
  Future<Either<Failure, List<task.Task>>> call(SortParams params) async {
    final result = await repository.getTasks();
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        if (params.ascending) {
          tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        } else {
          tasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
        }
        return Right(tasks);
      },
    );
  }
}

class SortParams {
  final bool ascending;

  SortParams(this.ascending);
}
