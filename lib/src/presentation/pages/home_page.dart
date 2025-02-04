import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/src/presentation/store/task_store.dart';
import 'package:highlevel_todo/src/presentation/widgets/task_list_widget.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskStore _taskStore = GetIt.I<TaskStore>();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

  @override
  void initState() {
    super.initState();
    _taskStore.fetchTasks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Sort tasks',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTasks,
        child: TaskList(scrollController: _scrollController),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        elevation: 2,
      ),
    );
  }

  Future<void> _refreshTasks() async {
    await _taskStore.fetchTasks();
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sort Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Due Date (Ascending)'),
              leading: const Icon(Icons.arrow_upward),
              onTap: () {
                _taskStore.sortTaskList(true);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Due Date (Descending)'),
              leading: const Icon(Icons.arrow_downward),
              onTap: () {
                _taskStore.sortTaskList(false);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        DateTime? selectedDueDate;
        List<String> tags = [];

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void showDateTimePicker() async {
              final initialDate = DateTime.now().add(const Duration(hours: 1));
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  // ignore: use_build_context_synchronously
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(initialDate),
                );

                if (pickedTime != null) {
                  setStateDialog(() {
                    selectedDueDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            }

            void showTagEditor() async {
              final tagController = TextEditingController();
              await showDialog(
                context: context,
                builder: (tagCtx) => AlertDialog(
                  title: const Text('Add Tags'),
                  content: TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      hintText: 'Enter tags separated by commas',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(tagCtx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (tagController.text.isNotEmpty) {
                          final newTags = tagController.text
                              .split(',')
                              .map((tag) => tag.trim())
                              .toList();
                          setStateDialog(() {
                            tags = newTags;
                          });
                          Navigator.pop(tagCtx);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
            }

            return AlertDialog(
              title: const Text('New Task'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Task Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: showDateTimePicker,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due Date & Time',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDueDate != null
                                    ? _dateFormat.format(selectedDueDate!)
                                    : 'Select date & time',
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: showTagEditor,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tags',
                            border: OutlineInputBorder(),
                          ),
                          child: Wrap(
                            spacing: 4,
                            children: tags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      visualDensity: VisualDensity.compact,
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        selectedDueDate != null) {
                      final newTask = Task(
                        name: nameController.text,
                        description: descriptionController.text,
                        dueDate: selectedDueDate!,
                        tags: tags,
                        isCompleted: false,
                      );
                      _taskStore.addTask(newTask);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
