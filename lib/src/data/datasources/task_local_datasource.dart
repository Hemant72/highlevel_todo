import 'package:highlevel_todo/src/data/model/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTask(TaskModel task);
  Future<List<TaskModel>> getTasks();
  Future<void> deleteTask(int id);
  Future<void> updateTask(TaskModel task);
}
