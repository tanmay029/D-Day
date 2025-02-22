import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

import 'task_details.dart';
import 'package:intl/intl.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({Key? key}) : super(key: key);

  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<Map<String, dynamic>> tasks = [];
  late Timer _timer;
  DateTime? _lastNotificationTime;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _initializeNotifications();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
      });

      for (var task in tasks) {
        DateTime taskDateTime = DateFormat("yyyy-MM-dd HH:mm a")
            .parse("${task['date']} ${task['time']}");
        print(
            "TASK PARSED: $taskDateTime (Original: ${task['date']} ${task['time']})");
      }
      _scheduleNotifications();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {}); 

      
      if (_lastNotificationTime == null ||
          DateTime.now().difference(_lastNotificationTime!).inMinutes >= 30) {
        _scheduleNotifications();
      }
    });
  }

  Future<void> _scheduleNotifications() async {
    DateTime now = DateTime.now();

    
    if (_lastNotificationTime != null &&
        now.difference(_lastNotificationTime!).inMinutes < 30) {
      return;
    }

    for (var task in tasks) {
      if (task['done'] == true) continue; 

      DateTime taskDeadline = DateFormat("yyyy-MM-dd HH:mm a")
          .parse("${task['date']} ${task['time']}");

      Duration diff = taskDeadline.difference(now);
      int remainingMinutes = diff.inMinutes;


      if (remainingMinutes % 30 == 0 && remainingMinutes <= 240) {
        _sendNotification(task['task'], remainingMinutes ~/ 60);
        _lastNotificationTime = now; 
        break; 
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredTasks(int minDays, int maxDays) {
    DateTime now = DateTime.now();
    return tasks.where((task) {
      DateTime taskDateTime = DateFormat("yyyy-MM-dd HH:mm a")
          .parse("${task['date']} ${task['time']}");


      if (!taskDateTime.isAfter(now) || task['done'] == true) {
        return false;
      }

      Duration diff = taskDateTime.difference(now);
      int remainingDays = diff.inHours ~/ 24; 
      int remainingHours = diff.inHours.remainder(24);

      return (remainingDays >= minDays && remainingDays <= maxDays) ||
          (remainingDays == maxDays &&
              remainingHours >
                  0); 
    }).toList();
  }

  String _formatTimeRemaining(DateTime taskDateTime) {
    DateTime now = DateTime.now();
    Duration timeRemaining = taskDateTime.difference(now);

    if (timeRemaining.isNegative) {
      return "Time Over";
    }

    int days = timeRemaining.inDays;
    int totalHours = timeRemaining.inHours;
    int hours = totalHours - (days * 24);
    int minutes = timeRemaining.inMinutes.remainder(60);
    int seconds = timeRemaining.inSeconds.remainder(60);

    return "$days d $hours h $minutes m $seconds s";
  }

  Widget _buildTaskList(
      String title, Color color, List<Map<String, dynamic>> taskList) {
    return taskList.isEmpty
        ? const SizedBox()
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
                physics: const NeverScrollableScrollPhysics(),
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  var task = taskList[index];
                  DateTime taskDateTime = DateFormat("yyyy-MM-dd HH:mm a")
                      .parse("${task['date']} ${task['time']}");

                  return ListTile(
                    title: Text(task['task']),
                    subtitle: Text(
                        "Due: ${task['date']} ${task['time']} \nTime Remaining: ${_formatTimeRemaining(taskDateTime)}"),
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



  Future<void> _sendNotification(String taskName, int remainingHours) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'task_alerts',
      'Task Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      "Task Reminder",
      "Task: $taskName\n$remainingHours hour(s) remaining!",
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alerts"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
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
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildTaskList("Urgent (Less than a day left)", Colors.red,
              _getFilteredTasks(0, 0)),
          _buildTaskList("High Priority (1-2 days left)", Colors.blue,
              _getFilteredTasks(1, 2)),
          _buildTaskList("Medium/Low Priority (3-6 days left)", Colors.green,
              _getFilteredTasks(3, 6)),
        ],
      ),
    );
  }
}
