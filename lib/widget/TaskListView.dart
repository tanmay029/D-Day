import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskListView extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final Function(Map<String, dynamic>) onTaskTap;
  final Function(String) onTaskToggle;
  final Function(Map<String, dynamic>) onDeleteTask;

  const TaskListView({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskToggle,
    required this.onDeleteTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        // Parse deadline time
        DateTime taskDeadline = DateFormat("yyyy-MM-dd h:mm a")
            .parse("${task['date']} ${task['time']}");

        bool isOverdue = DateTime.now().isAfter(taskDeadline) && !task['done'];
        bool isCompleted = task['done'];

        return GestureDetector(
          onTap: () => onTaskTap(task),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: isOverdue
                  ? const Icon(Icons.cancel, color: Colors.red) // ❌ Overdue
                  : isCompleted
                      ? const Icon(Icons.check_circle,
                          color: Colors.green) // ✅ Completed
                      : Checkbox(
                          value: isCompleted,
                          onChanged: (bool? value) {
                            if (value == true) {
                              onTaskToggle(
                                  task['task']); // Allow checking only once
                            }
                          },
                        ),
              title: Text(
                task['task']!,
                style: TextStyle(
                  decoration: isCompleted || isOverdue
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                "Due: ${task['date']} at ${task['time']}",
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






/*

import 'package:flutter/material.dart';

class TaskListView extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final Function(Map<String, dynamic>) onTaskTap;
  final Function(String) onTaskToggle;
  final Function(Map<String, dynamic>) onDeleteTask;

  const TaskListView({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskToggle,
    required this.onDeleteTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return GestureDetector(
          onTap: () => onTaskTap(task),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Checkbox(
                value: task['done'],
                onChanged: (bool? value) => onTaskToggle(task['task']),
              ),
              title: Text(
                task['task']!,
                style: TextStyle(
                  decoration: task['done']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: Text(
                "Due: ${task['date']} at ${task['time']}",
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


*/