import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/core/const/colors.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';
import 'package:highlevel_todo/src/presentation/widgets/task_item.dart';

class TaskList extends StatelessWidget {
  final TaskStore _taskStore = GetIt.I<TaskStore>();

  TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => ListView.builder(
        itemCount: _taskStore.tasks.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: Key(_taskStore.tasks[index].id.toString()),
          background: Container(color: AppColors.error),
          confirmDismiss: (_) => _confirmDismiss(context),
          onDismissed: (_) => _taskStore.removeTask(_taskStore.tasks[index].id!),
          child: TaskItem(
            task: _taskStore.tasks[index],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
