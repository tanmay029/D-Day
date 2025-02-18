import 'package:dooms_day/pages/task_details.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
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
        return AlertDialog(
          title: Text("Delete Task"),
          content: Text("Are you sure you want to delete '${task['task']}'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _removeTask(task);
                Navigator.of(context).pop(); // Close dialog after deleting
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
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

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      _loadTasksForMonth(); // 🔹 UPDATED: Load tasks for selected month
    }
  }

  void _loadTasksForMonth() {
    setState(() {
      tasksForSelectedMonth = tasks.where((task) {
        try {
          // Ensure proper date parsing
          DateTime taskDate = DateTime.parse(task['date']);

          // Match only tasks for the currently selected month & year
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
    _loadTasksForMonth(); // 🔹 UPDATED: Refresh filtered tasks after toggling
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
    TextEditingController taskController = TextEditingController();
    TextEditingController dateController = TextEditingController();
    TextEditingController timeController = TextEditingController();

    Future<void> _selectDate() async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      }
    }

    Future<void> _selectTime() async {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        timeController.text = pickedTime.format(context);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: taskController,
                  decoration: const InputDecoration(labelText: 'Task Name')),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
                readOnly: true,
                onTap: _selectDate,
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Due Time'),
                readOnly: true,
                onTap: _selectTime,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    timeController.text.isNotEmpty) {
                  setState(() {
                    tasks.add({
                      'task': taskController.text,
                      'date': dateController.text,
                      'time': timeController.text,
                      'done': false,
                    });
                  });
                  _saveTasks();
                  _loadTasksForMonth();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Task'),
            ),
          ],
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
                          TableCalendar(
                            firstDay: DateTime.utc(2000, 1, 1),
                            lastDay: DateTime.utc(2100, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            onPageChanged: (focusedDay) {
                              // 🔹 UPDATED: Update tasks when month changes
                              setState(() {
                                _focusedDay = focusedDay;
                              });
                              _loadTasksForMonth();
                            },
                            calendarFormat: CalendarFormat.month,
                            eventLoader: (day) =>
                                _getTaskEvents()[
                                    DateTime(day.year, day.month, day.day)] ??
                                [],
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle),
                              todayDecoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.3),
                                  shape: BoxShape.circle),
                              markersAlignment: Alignment.bottomCenter,
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekendStyle: TextStyle(color: Colors.red),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (events.isNotEmpty) {
                                  return Positioned(
                                    bottom: 1,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.red, // Dot color
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🔹 Added Row with "Add Task" Button in Monthly Section
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tasksForSelectedMonth.length,
                            itemBuilder: (context, index) {
                              final task = tasksForSelectedMonth[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TaskDetailsPage(task: task),
                                    ),
                                  );
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  elevation: 3,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: task['done'],
                                      onChanged: (bool? value) {
                                        _toggleTaskDone(task['task']);
                                      },
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
                                        style: const TextStyle(fontSize: 14)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        _confirmDeleteTask(task);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ))
                    : Column(
                        children: [
                          TableCalendar(
                            firstDay: DateTime.utc(2000, 1, 1),
                            lastDay: DateTime.utc(2100, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                              });
                            },
                            calendarFormat: CalendarFormat.month,
                            eventLoader: (day) =>
                                _getTaskEvents()[
                                    DateTime(day.year, day.month, day.day)] ??
                                [],
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle),
                              todayDecoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.3),
                                  shape: BoxShape.circle),
                              markersAlignment: Alignment.bottomCenter,
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekendStyle: TextStyle(color: Colors.red),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (events.isNotEmpty) {
                                  return Positioned(
                                    bottom: 1,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.red, // Dot color
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 🔹 Added Row with "Add Task" Button
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                          Expanded(
                            child: ListView.builder(
                              itemCount: _getTasksForSelectedDay().length,
                              itemBuilder: (context, index) {
                                final task = _getTasksForSelectedDay()[index];

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TaskDetailsPage(task: task),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      leading: Checkbox(
                                        value: task['done'],
                                        onChanged: (bool? value) {
                                          _toggleTaskDone(task['task']);
                                        },
                                      ),
                                      title: Text(
                                        task['task'],
                                        style: TextStyle(
                                          decoration: task['done']
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                      subtitle: Text("Due: ${task['time']}",
                                          style: const TextStyle(fontSize: 14)),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          _confirmDeleteTask(task);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed, // Ensures visibility of all items
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
