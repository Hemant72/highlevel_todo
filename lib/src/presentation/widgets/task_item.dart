import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/src/presentation/pages/task_detail_page.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';

import '../../domain/entities/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final TaskStore _taskStore = GetIt.I<TaskStore>();

  TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.name),
      subtitle: Text(task.description),
      trailing: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => _taskStore.completeTask(task),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => TaskDetailPage(task: task),
        ),
      ),
    );
  }
}
