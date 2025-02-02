import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/core/usecases/usecase.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

class DeleteTask implements UseCase<void, int> {
  final TaskRepository repository;

  DeleteTask(this.repository);

  @override
  Future<Either<Failure, void>> call(int id) async {
    return await repository.deleteTask(id);
  }
}
