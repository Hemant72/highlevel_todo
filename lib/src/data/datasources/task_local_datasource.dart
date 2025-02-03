import 'package:highlevel_todo/src/data/model/task_model.dart';

// part 'task_local_datasource.g.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTask(TaskModel task);
  Future<List<TaskModel>> getTasks();
  Future<void> deleteTask(int id);
  Future<void> updateTask(TaskModel task);
}

// @DriftAccessor(tables: [Tasks])
// class TaskLocalDataSourceImpl extends DatabaseAccessor<AppDatabase>
//     implements TaskLocalDataSource {
//   TaskLocalDataSourceImpl(AppDatabase db) : super(db);

//   @override
//   Future<void> cacheTask(TaskModel task) async {
//     await into(tasks)
//         .insert(task.toCompanion(), mode: InsertMode.insertOrReplace);
//   }

//   @override
//   Future<List<TaskModel>> getTasks() async {
//     final query = select(tasks);
//     return await query.map((row) => TaskModel.fromData(row)).get();
//   }

//   @override
//   Future<void> deleteTask(int id) async {
//     await (delete(tasks)..where((tbl) => tbl.id.equals(id))).go();
//   }

//   @override
//   Future<void> updateTask(TaskModel task) async {
//     await (update(tasks)..where((tbl) => tbl.id.equals(task.id)))
//         .write(task.toCompanion());
//   }
// }
