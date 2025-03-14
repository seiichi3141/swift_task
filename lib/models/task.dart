import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

enum TaskPriority {
  high,
  medium,
  low,
}

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    @Default(false) bool isCompleted,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}

// タスク関連のユーティリティ関数
class TaskUtils {
  // AIによる優先度の計算（実際のAIロジックは将来実装）
  static TaskPriority calculateAIPriority(Task task) {
    // 仮のロジック：期限が近いほど優先度が高い
    final daysLeft = task.dueDate.difference(DateTime.now()).inDays;

    if (daysLeft < 2) {
      return TaskPriority.high;
    } else if (daysLeft < 5) {
      return TaskPriority.medium;
    } else {
      return TaskPriority.low;
    }
  }

  // 優先度に基づく色を取得
  static Color getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}
