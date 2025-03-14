import 'package:flutter/material.dart';
import 'package:swift_task/models/task.dart';
import 'package:intl/intl.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final Function(bool?) onCompletionToggle;
  final VoidCallback onTap;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onCompletionToggle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 優先度を示すカラーマーカー
              Container(
                width: 4,
                height: 60,
                color: TaskUtils.getPriorityColor(task.priority),
              ),
              const SizedBox(width: 16),
              // チェックボックス
              Checkbox(
                value: task.isCompleted,
                onChanged: onCompletionToggle,
                activeColor: Colors.green,
              ),
              const SizedBox(width: 8),
              // タスク情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: task.isCompleted ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // 期限
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MM/dd').format(task.dueDate),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _getDueDateColor(task.dueDate),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getRemainingDays(task.dueDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDueDateColor(task.dueDate),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 期限までの残り日数を計算
  String _getRemainingDays(DateTime dueDate) {
    final difference = dueDate.difference(DateTime.now()).inDays;
    if (difference < 0) {
      return '期限切れ';
    } else if (difference == 0) {
      return '今日まで';
    } else {
      return 'あと$difference日';
    }
  }

  // 期限の色を取得
  Color _getDueDateColor(DateTime dueDate) {
    final difference = dueDate.difference(DateTime.now()).inDays;
    if (difference < 0) {
      return Colors.red;
    } else if (difference <= 1) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}
