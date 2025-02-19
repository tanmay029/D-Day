import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task_details.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredTasks(int minDays, int maxDays) {
    DateTime now = DateTime.now();
    return tasks.where((task) {
      DateTime taskDate = DateTime.parse(task['date']);
      int difference = taskDate.difference(now).inDays;
      return difference >= minDays && difference <= maxDays;
    }).toList();
  }

  Widget _buildTaskList(
      String title, Color color, List<Map<String, dynamic>> taskList) {
    return taskList.isEmpty
        ? SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  var task = taskList[index];
                  DateTime taskDate = DateTime.parse(task['date']);
                  Duration timeRemaining = taskDate.difference(DateTime.now());
                  return ListTile(
                    title: Text(task['task']),
                    subtitle: Text(
                        "Due: ${task['date']} \nTime Remaining: ${timeRemaining.inDays} days, ${timeRemaining.inHours % 24} hours"),
                    trailing: Checkbox(
                      value: task['done'],
                      onChanged: (bool? newValue) {
                        setState(() {
                          task['done'] = newValue;
                        });
                        _saveTasks();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailsPage(task: task),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alerts"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {},
              ),
              Positioned(
                right: 11,
                top: 11,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.red,
                  child: Text(
                    _getFilteredTasks(0, 6).length.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTaskList("Urgent (Less than a day left)", Colors.red,
                _getFilteredTasks(0, 0)),
            _buildTaskList("High Priority (1-3 days left)", Colors.blue,
                _getFilteredTasks(1, 3)),
            _buildTaskList("Moderate Priority (4-7 days left)", Colors.green,
                _getFilteredTasks(4, 6)),
          ],
        ),
      ),
    );
  }
}
