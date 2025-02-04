import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/core/const/colors.dart';
import 'package:highlevel_todo/core/service/notification_service.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;
  final TaskStore _taskStore = GetIt.I<TaskStore>();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate.isBefore(DateTime.now());
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailSection(
              title: 'Task Name',
              content: Text(
                task.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
              ),
            ),
            _buildDetailSection(
              title: 'Description',
              content: Text(
                task.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
              ),
            ),
            _buildDetailSection(
              title: 'Due Date',
              content: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: isOverdue ? AppColors.error : AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _dateFormat.format(task.dueDate),
                    style: TextStyle(
                      color: isOverdue ? AppColors.error : AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildDetailSection(
              title: 'Status',
              content: Row(
                children: [
                  Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.pending_actions,
                    color: task.isCompleted
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      color: task.isCompleted
                          ? AppColors.secondary
                          : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildDetailSection(
              title: 'Tags',
              content: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: task.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({required String title, required Widget content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface.withValues(alpha: 0.6),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (!task.isCompleted) ...[
          _buildActionButton(
            context,
            icon: Icons.check_circle_outline,
            iconColor: AppColors.onPrimary,
            label: 'Mark Complete',
            color: AppColors.secondary,
            onPressed: () => _handleCompleteTask(context),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            context,
            icon: Icons.snooze,
            iconColor: AppColors.onPrimary,
            label: 'Snooze 1 Hour',
            color: AppColors.primary,
            onPressed: _handleSnoozeTask,
          ),
        ],
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          icon: Icons.delete_outline,
          iconColor: AppColors.onPrimary,
          label: 'Delete Task',
          color: AppColors.error,
          onPressed: () => _handleDeleteTask(context),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(
          icon,
          size: 24,
          color: iconColor,
        ),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _handleCompleteTask(BuildContext context) {
    _taskStore.completeTask(task);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task marked as complete'),
        backgroundColor: AppColors.secondary,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () =>
              _taskStore.editTask(task.copyWith(isCompleted: false)),
        ),
      ),
    );
  }

  void _handleSnoozeTask() {
    _taskStore.postponeTask(task);
    ScaffoldMessenger.of(NotificationService.navigatorKey.currentContext!)
        .showSnackBar(
      const SnackBar(
        content: Text('Task snoozed for 1 hour'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _handleDeleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              if (task.id != null) {
                _taskStore.removeTask(task.id!);
              }
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
