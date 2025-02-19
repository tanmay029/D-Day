import 'package:dooms_day/pages/task_details.dart';
import 'package:dooms_day/utils/routes.dart';
import 'package:dooms_day/widget/AddTaskDialog.dart';
import 'package:dooms_day/widget/ConfirmDeleteDialog.dart';
import 'package:dooms_day/widget/CustomCalendar.dart';
import 'package:dooms_day/widget/TaskListForSelectedDay.dart';
import 'package:dooms_day/widget/TaskListView.dart';
import 'package:dooms_day/widget/month_custom_calendar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final Function toggleTheme;

  const HomePage(
      {super.key, required this.isDarkMode, required this.toggleTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isMonthlySelected = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> tasksForSelectedMonth = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _confirmDeleteTask(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDeleteDialog(
          taskName: task['task'],
          onDelete: () => _removeTask(task),
        );
      },
    );
  }

  void _removeTask(Map<String, dynamic> task) {
    setState(() {
      tasks.removeWhere(
          (t) => t['task'] == task['task'] && t['date'] == task['date']);
    });
    _saveTasks(); // Save updated task list
    _loadTasksForMonth(); // Refresh the monthly view
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasksJson = jsonEncode(tasks);
    await prefs.setString('tasks', tasksJson);
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
      });
      _loadTasksForMonth();
    }
  }

  void _loadTasksForMonth() {
    setState(() {
      tasksForSelectedMonth = tasks.where((task) {
        try {
          DateTime taskDate = DateTime.parse(task['date']);

          return taskDate.year == _focusedDay.year &&
              taskDate.month == _focusedDay.month;
        } catch (e) {
          print("Error parsing date: ${task['date']} - $e");
          return false;
        }
      }).toList();

      // Debugging log
      print(
          "Loaded tasks for ${_focusedDay.month}/${_focusedDay.year}: $tasksForSelectedMonth");
    });
  }

  void _toggleTaskDone(String taskName) {
    setState(() {
      int originalIndex = tasks.indexWhere((task) => task['task'] == taskName);
      if (originalIndex != -1) {
        tasks[originalIndex]['done'] = !tasks[originalIndex]['done'];
      }
    });
    _saveTasks();
    _loadTasksForMonth();
  }

  Map<DateTime, List<Map<String, dynamic>>> _getTaskEvents() {
    Map<DateTime, List<Map<String, dynamic>>> events = {};
    for (var task in tasks) {
      DateTime taskDate = DateTime.parse(task['date']);
      events[taskDate] = events[taskDate] ?? [];
      events[taskDate]!.add(task);
    }
    return events;
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddTaskDialog(
          onTaskAdded: (task, date, time) {
            setState(() {
              tasks.add(
                  {'task': task, 'date': date, 'time': time, 'done': false});
            });
            _saveTasks();
            _loadTasksForMonth();
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getTasksForSelectedDay() {
    String formattedDate = _selectedDay?.toIso8601String().split("T")[0] ?? "";
    return tasks.where((task) => task['date'] == formattedDate).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Tasks"),
          leading: IconButton(
            icon: Icon(widget.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_outlined),
            onPressed: () {
              widget.toggleTheme();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () async {
                await Navigator.pushNamed(context, MyRoutes.settingRoute);
                setState(() {});
              },
            ),
          ],
          centerTitle: true,
          backgroundColor: Colors.blueAccent),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ToggleButtons(
              isSelected: [_isMonthlySelected, !_isMonthlySelected],
              onPressed: (int index) {
                setState(() {
                  _isMonthlySelected = index == 0;
                });
              },
              borderRadius: BorderRadius.circular(10),
              borderColor: Colors.blue,
              selectedBorderColor: Colors.blueAccent,
              fillColor: Colors.blue.withOpacity(0.1),
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Monthly")),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Daily"))
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _isMonthlySelected
                    ? SingleChildScrollView(
                        child: Column(
                          children: [
                            CustomCalendar2(
                              focusedDay: _focusedDay,
                              selectedDay: _selectedDay,
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              onPageChanged: (focusedDay) {
                                setState(() {
                                  _focusedDay = focusedDay;
                                });
                                _loadTasksForMonth();
                              },
                              getTaskEvents: _getTaskEvents,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("This Month",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  ElevatedButton.icon(
                                    onPressed: _showAddTaskDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text("Add Task"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TaskListView(
                              tasks: tasksForSelectedMonth,
                              onTaskTap: (task) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TaskDetailsPage(task: task),
                                  ),
                                );
                              },
                              onTaskToggle: (taskName) {
                                _toggleTaskDone(taskName);
                              },
                              onDeleteTask: (task) {
                                _confirmDeleteTask(task);
                              },
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            CustomCalendar(
                              focusedDay: _focusedDay,
                              selectedDay: _selectedDay,
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                              },
                              getTaskEvents: _getTaskEvents,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tasks for ${_selectedDay?.toLocal().toString().split(' ')[0] ?? "Today"}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _showAddTaskDialog,
                                    icon: const Icon(Icons.add),
                                    label: const Text("Add Task"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.6, // Adjust height dynamically
                              child: TaskListForSelectedDay(
                                tasks: _getTasksForSelectedDay(),
                                onTaskTap: (task) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskDetailsPage(task: task),
                                    ),
                                  );
                                },
                                onTaskToggle: (taskName) {
                                  _toggleTaskDone(taskName);
                                },
                                onDeleteTask: (task) {
                                  _confirmDeleteTask(task);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
