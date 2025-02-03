import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';

import '../../domain/entities/task.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;
  final TaskStore _taskStore = GetIt.I<TaskStore>();

  TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Detail')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.name, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: 8),
          Text(task.description),
          SizedBox(height: 8),
          Text('Due: ${task.dueDate.toString()}'),
          SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: task.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          Spacer(),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _handleCompleteTask(context),
          child: Text('Complete'),
        ),
        ElevatedButton(
          onPressed: () => _handleSnoozeTask(),
          child: Text('Snooze 1h'),
        ),
        ElevatedButton(
          onPressed: () => _handleDeleteTask(context),
          child: Text('Delete'),
        ),
      ],
    );
  }

  void _handleCompleteTask(BuildContext context) {
    _taskStore.completeTask(task);
    Navigator.pop(context);
  }

  void _handleSnoozeTask() => _taskStore.postponeTask(task);

  void _handleDeleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _taskStore.removeTask(task.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
