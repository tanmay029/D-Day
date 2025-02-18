import 'package:flutter/material.dart';

class TaskListForSelectedDay extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final Function(Map<String, dynamic>) onTaskTap;
  final Function(String) onTaskToggle;
  final Function(Map<String, dynamic>) onDeleteTask;

  const TaskListForSelectedDay({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskToggle,
    required this.onDeleteTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: GestureDetector(
            onTap: () => onTaskTap(task),
            child: ListTile(
              leading: Checkbox(
                value: task['done'],
                onChanged: (bool? value) => onTaskToggle(task['task']),
              ),
              title: Text(
                task['task'],
                style: TextStyle(
                  decoration: task['done']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                "Due: ${task['time']}",
                style: const TextStyle(fontSize: 14),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDeleteTask(task),
              ),
            ),
          ),
        );
      },
    );
  }
}
