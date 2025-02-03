import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';
import 'package:highlevel_todo/src/presentation/widgets/task_list_widget.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';

class HomePage extends StatelessWidget {
  final TaskStore _taskStore = GetIt.I<TaskStore>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo App')),
      body: TaskList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final dueDateController = TextEditingController();
    final tagsController = TextEditingController();
    DateTime? selectedDueDate;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Task'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Task Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Description is required' : null,
                ),
                TextFormField(
                  controller: dueDateController,
                  decoration: InputDecoration(labelText: 'Due Date & Time'),
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (selectedDate != null) {
                      final selectedTime = await showTimePicker(
                        // ignore: use_build_context_synchronously
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        final combinedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        selectedDueDate = combinedDateTime;
                        dueDateController.text = DateFormat('yyyy-MM-dd HH:mm')
                            .format(combinedDateTime);
                      }
                    }
                  },
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Due Date & Time are required'
                      : null,
                ),
                TextFormField(
                  controller: tagsController,
                  decoration:
                      InputDecoration(labelText: 'Tags (comma separated)'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Tags are required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newTask = Task(
                  name: nameController.text,
                  description: descriptionController.text,
                  dueDate: selectedDueDate!,
                  tags: tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .toList(),
                  isCompleted: false,
                );
                _taskStore.addTask(newTask);
                Navigator.pop(ctx);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
