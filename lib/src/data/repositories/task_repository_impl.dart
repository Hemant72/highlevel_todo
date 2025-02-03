import 'package:fpdart/fpdart.dart';
import 'package:highlevel_todo/core/error/failure.dart';
import 'package:highlevel_todo/src/data/datasources/task_local_datasource.dart';
import 'package:highlevel_todo/src/data/model/task_model.dart';
import 'package:highlevel_todo/src/domain/repositories/task_repository.dart';

import '../../domain/entities/task.dart' as task;

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<task.Task>>> getTasks() async {
    try {
      final tasks = await localDataSource.getTasks();
      return Right(tasks.map((model) => model.toEntity()).toList());
    } on Exception {
      return Left(CacheError());
    }
  }

  @override
  Future<Either<Failure, void>> createTask(task.Task task) async {
    try {
      await localDataSource.cacheTask(TaskModel.fromEntity(task));
      return const Right(null);
    } on Exception {
      return Left(CacheError());
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(int id) async {
    try {
      await localDataSource.deleteTask(id);
      return Right(null);
    } on Exception {
      return Left(CacheError());
    }
  }

  @override
  Future<Either<Failure, void>> updateTask(task.Task task) async {
    try {
      await localDataSource.updateTask(TaskModel.fromEntity(task));
      return const Right(null);
    } on Exception {
      return Left(CacheError());
    }
  }
}
