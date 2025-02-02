import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';

import '../entities/task.dart' as task;

abstract class TaskRepository {
  Future<Either<Failure, List<task.Task>>> getTasks();
  Future<Either<Failure, void>> createTask(task.Task task);
  Future<Either<Failure, void>> deleteTask(int id);
  Future<Either<Failure, void>> updateTask(task.Task task);
}
