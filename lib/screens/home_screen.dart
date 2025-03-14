import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:swift_task/models/task.dart';
import 'package:swift_task/state/task_notifier.dart';
import 'package:swift_task/widgets/task_list_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider);
    final pendingTasksList = ref.watch(pendingTasksProvider);
    final completionRate = ref.watch(completionRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swift Task'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(taskNotifierProvider.notifier)
                  .recalculateTaskPriorities();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AIによるタスク優先度を再計算しました')),
              );
            },
            tooltip: 'AIによる優先度再計算',
          ),
        ],
      ),
      body: Column(
        children: [
          // 日付と進捗状況の表示
          _buildDateAndProgressHeader(context, completionRate),

          // タスク一覧
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('タスクがありません。新しいタスクを追加してください。'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskListItem(
                        task: task,
                        onCompletionToggle: (value) {
                          ref
                              .read(taskNotifierProvider.notifier)
                              .toggleTaskCompletion(task.id);
                        },
                        onTap: () {
                          // タスク詳細画面への遷移（将来実装）
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${task.title}の詳細を表示します')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // クイック操作ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add),
        tooltip: '新しいタスクを追加',
      ),
      // ナビゲーションメニュー
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        onTap: (index) {
          if (index != 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('この機能は現在開発中です')),
            );
          }
        },
      ),
    );
  }

  // 日付と進捗状況のヘッダーを構築
  Widget _buildDateAndProgressHeader(
      BuildContext context, double completionRate) {
    final now = DateTime.now();
    final dateFormat = DateFormat.yMMMMd('ja_JP');
    final weekdayFormat = DateFormat.EEEE('ja_JP');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(now),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weekdayFormat.format(now),
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              _buildProgressIndicator(context, completionRate),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'タスク一覧',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 進捗状況のインジケーターを構築
  Widget _buildProgressIndicator(BuildContext context, double completionRate) {
    final percentage = (completionRate * 100).toInt();

    return Column(
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: completionRate,
                backgroundColor: Colors.grey.withOpacity(0.3),
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Center(
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '完了率',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  // タスク追加ダイアログを表示
  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新しいタスクを追加'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'タイトル',
                  hintText: 'タスクのタイトルを入力',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '説明',
                  hintText: 'タスクの説明を入力',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    ListTile(
                      title: const Text('期限'),
                      subtitle:
                          Text(DateFormat.yMMMd('ja_JP').format(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: const Text('優先度'),
                      subtitle: Text(_getPriorityText(selectedPriority)),
                      trailing: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: TaskUtils.getPriorityColor(selectedPriority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => SimpleDialog(
                            title: const Text('優先度を選択'),
                            children: TaskPriority.values.map((priority) {
                              return SimpleDialogOption(
                                onPressed: () {
                                  setState(() {
                                    selectedPriority = priority;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: TaskUtils.getPriorityColor(
                                            priority),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_getPriorityText(priority)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                ref.read(taskNotifierProvider.notifier).addTask(
                      titleController.text,
                      descriptionController.text,
                      selectedDate,
                      selectedPriority,
                    );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('タイトルを入力してください')),
                );
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  // 優先度のテキスト表現を取得
  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return '高';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.low:
        return '低';
    }
  }
}
