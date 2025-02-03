import 'package:drift/drift.dart';
import 'package:highlevel_todo/src/data/datasources/local_datasource.dart';
import 'package:highlevel_todo/src/data/model/task_model.dart';

part 'task_local_datasource.g.dart';

abstract class TaskLocalDataSource {
  Future<int> cacheTask(TaskModel task);
  Future<List<TaskModel>> getTasks();
  Future<void> deleteTask(int id);
  Future<void> updateTask(TaskModel task);
}

@DriftAccessor(tables: [Tasks])
class TaskLocalDataSourceImpl extends DatabaseAccessor<AppDatabase>
    implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(super.db);

  TableInfo<Tasks, Task> get tasks => db.tasks;

  @override
  Future<int> cacheTask(TaskModel task) async {
    return await into(tasks).insert(
      TasksCompanion(
        name: Value(task.name),
        description: Value(task.description),
        dueDate: Value(task.dueDate),
        tags: Value(task.tags),
        isCompleted: Value(task.isCompleted),
      ),
    );
  }

  @override
  Future<List<TaskModel>> getTasks() async {
    final query = select(tasks);
    final rows = await query.get();
    return rows
        .map((row) => TaskModel(
              id: row.id,
              name: row.name,
              description: row.description,
              dueDate: row.dueDate,
              tags: row.tags,
              isCompleted: row.isCompleted,
            ))
        .toList();
  }

  @override
  Future<void> deleteTask(int id) async {
    await (delete(tasks)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await (update(tasks)..where((tbl) => tbl.id.equals(task.id)))
        .write(TasksCompanion(
      name: Value(task.name),
      description: Value(task.description),
      dueDate: Value(task.dueDate),
      tags: Value(task.tags),
      isCompleted: Value(task.isCompleted),
    ));
  }
}
