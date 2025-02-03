import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/task.dart' as task;

part 'task_model.freezed.dart';
part 'task_model.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required int id,
    required String name,
    required String description,
    required DateTime dueDate,
    required List<String> tags,
    required bool isCompleted,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  factory TaskModel.fromEntity(task.Task task) {
    return TaskModel(
      id: task.id!,
      name: task.name,
      description: task.description,
      dueDate: task.dueDate,
      tags: task.tags,
      isCompleted: task.isCompleted,
    );
  }
}

extension TaskModelMapper on TaskModel {
  task.Task toEntity() {
    return task.Task(
      id: id,
      name: name,
      description: description,
      dueDate: dueDate,
      tags: tags,
      isCompleted: isCompleted,
    );
  }
}
