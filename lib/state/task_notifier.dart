import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:swift_task/models/task.dart';

// タスクの状態を管理するNotifierクラス
class TaskNotifier extends StateNotifier<List<Task>> {
  final _uuid = const Uuid();

  TaskNotifier() : super([]) {
    // 初期状態としてサンプルタスクを設定
    state = _initSampleTasks();
  }

  // タスクを追加
  void addTask(String title, String description, DateTime dueDate,
      TaskPriority priority) {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    state = [...state, newTask];
  }

  // タスクを削除
  void removeTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  // タスクの完了状態を切り替え
  void toggleTaskCompletion(String id) {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();
  }

  // タスクを更新
  void updateTask(String id, String title, String description, DateTime dueDate,
      TaskPriority priority) {
    state = state.map((task) {
      if (task.id == id) {
        return task.copyWith(
          title: title,
          description: description,
          dueDate: dueDate,
          priority: priority,
        );
      }
      return task;
    }).toList();
  }

  // AIによるタスク優先度の再計算
  void recalculateTaskPriorities() {
    state = state.map((task) {
      if (!task.isCompleted) {
        // 実際のAIロジックは将来実装
        final newPriority = TaskUtils.calculateAIPriority(task);
        // 優先度が変わった場合のみ更新
        if (task.priority != newPriority) {
          return task.copyWith(priority: newPriority);
        }
      }
      return task;
    }).toList();
  }

  // サンプルデータの初期化
  List<Task> _initSampleTasks() {
    final now = DateTime.now();
    final tasks = <Task>[];

    tasks.add(Task(
      id: _uuid.v4(),
      title: 'プロジェクト計画書の作成',
      description: '新規プロジェクトの計画書を作成し、チームと共有する',
      dueDate: now.add(const Duration(days: 1)),
      priority: TaskPriority.high,
    ));

    tasks.add(Task(
      id: _uuid.v4(),
      title: 'ウィークリーミーティング',
      description: '毎週の進捗確認ミーティング',
      dueDate: now.add(const Duration(days: 2)),
      priority: TaskPriority.medium,
    ));

    tasks.add(Task(
      id: _uuid.v4(),
      title: 'プレゼン資料の準備',
      description: 'クライアントミーティング用のプレゼンテーション資料を準備する',
      dueDate: now.add(const Duration(days: 4)),
      priority: TaskPriority.high,
    ));

    tasks.add(Task(
      id: _uuid.v4(),
      title: 'ブログ記事の執筆',
      description: '新機能についてのブログ記事を書く',
      dueDate: now.add(const Duration(days: 7)),
      priority: TaskPriority.low,
    ));

    tasks.add(Task(
      id: _uuid.v4(),
      title: 'アプリのバグ修正',
      description: 'レポートされたクラッシュの問題を修正する',
      dueDate: now.add(const Duration(days: 3)),
      priority: TaskPriority.medium,
    ));

    return tasks;
  }
}

// タスク状態のプロバイダー
final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

// 完了タスクを取得するプロバイダー
final completedTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskNotifierProvider);
  return tasks.where((task) => task.isCompleted).toList();
});

// 未完了タスクを取得するプロバイダー
final pendingTasksProvider = Provider<List<Task>>((ref) {
  final tasks = ref.watch(taskNotifierProvider);
  return tasks.where((task) => !task.isCompleted).toList();
});

// 完了率を計算するプロバイダー
final completionRateProvider = Provider<double>((ref) {
  final tasks = ref.watch(taskNotifierProvider);
  if (tasks.isEmpty) return 0.0;
  final completedCount = tasks.where((task) => task.isCompleted).length;
  return completedCount / tasks.length;
});
