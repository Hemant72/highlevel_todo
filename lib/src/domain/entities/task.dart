import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';

@freezed
abstract class Task with _$Task {
  const factory Task({
    int? id,
    required String name,
    required String description,
    required DateTime dueDate,
    required List<String> tags,
    required bool isCompleted,
  }) = _Task;
}
