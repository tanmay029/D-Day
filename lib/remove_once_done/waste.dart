
// // ignore_for_file: sort_child_properties_last, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously

// // import 'package:dooms_day/pages/task_details.dart';
// import 'package:dooms_day/pages/task_details.dart';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert'; // For encoding & decoding JSON

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;
//   bool _isMonthlySelected = true;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   List<Map<String, dynamic>> tasks = [
//     {
//       "task": "Complete Flutter project",
//       "date": "2025-02-20",
//       "time": "5:00 PM",
//       "done": false
//     },
//     {
//       "task": "Attend team meeting",
//       "date": "2025-02-22",
//       "time": "3:00 PM",
//       "done": false
//     },
//     {
//       "task": "Finish reading book",
//       "date": "2025-02-25",
//       "time": "9:00 PM",
//       "done": false
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadTasks();
//     });
//   }

// void _onBottomNavTapped(int index) {
//   setState(() {
//     _selectedIndex = index;
//   });
// }

//   Future<void> _saveTasks() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String tasksJson = jsonEncode(tasks);
//     await prefs.setString('tasks', tasksJson);
//     print("Tasks saved: $tasksJson"); // Debugging
//   }

//   Future<void> _loadTasks() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? tasksJson = prefs.getString('tasks');
//     if (tasksJson != null) {
//       try {
//         List<dynamic> decoded = jsonDecode(tasksJson);
//         setState(() {
//           tasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
//         });
//       } catch (e) {
//         print("Error loading tasks: $e");
//       }
//     }
//   }

//   void _toggleTaskDone(int index) {
//     setState(() {
//       tasks[index]['done'] = !tasks[index]['done'];
//     });
//     _saveTasks(); // Save tasks after updating
//   }

//   void _showAddTaskDialog() {
//     TextEditingController taskController = TextEditingController();
//     TextEditingController dateController = TextEditingController();
//     TextEditingController timeController = TextEditingController();

//     Future<void> _selectDate() async {
//       DateTime? pickedDate = await showDatePicker(
//         context: context,
//         initialDate: DateTime.now(),
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2100),
//       );
//       if (pickedDate != null) {
//         dateController.text = pickedDate.toLocal().toString().split(' ')[0];
//       }
//     }

//     Future<void> _selectTime() async {
//       TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//       if (pickedTime != null) {
//         timeController.text = pickedTime.format(context);
//       }
//     }

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Add New Task'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: taskController,
//                 decoration: InputDecoration(labelText: 'Task Name'),
//               ),
//               TextField(
//                 controller: dateController,
//                 decoration: InputDecoration(labelText: 'Due Date'),
//                 readOnly: true,
//                 onTap: _selectDate,
//               ),
//               TextField(
//                 controller: timeController,
//                 decoration: InputDecoration(labelText: 'Due Time'),
//                 readOnly: true,
//                 onTap: _selectTime,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (taskController.text.isNotEmpty &&
//                     dateController.text.isNotEmpty &&
//                     timeController.text.isNotEmpty) {
//                   setState(() {
//                     tasks.add({
//                       'task': taskController.text,
//                       'date': dateController.text,
//                       'time': timeController.text,
//                       'done': false,
//                     });
//                   });
//                   _saveTasks(); // Save tasks after adding
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: Text('Add Task'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   List<Map<String, dynamic>> _getTasksForSelectedDay() {
//     String formattedDate = _selectedDay?.toIso8601String().split("T")[0] ?? "";
//     return tasks.where((task) => task['date'] == formattedDate).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Monthly & Daily View"),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _isMonthlySelected = true;
//                     });
//                   },
//                   child: Text("Monthly"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         _isMonthlySelected ? Colors.blue : Colors.grey,
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _isMonthlySelected = false;
//                     });
//                   },
//                   child: Text("Daily"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor:
//                         !_isMonthlySelected ? Colors.blue : Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             Flexible(
//               child: Center(
//                 child: _isMonthlySelected
//                     ? SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             TableCalendar(
//                               firstDay: DateTime.utc(2000, 1, 1),
//                               lastDay: DateTime.utc(2100, 12, 31),
//                               focusedDay: _focusedDay,
//                               selectedDayPredicate: (day) {
//                                 return isSameDay(_selectedDay, day);
//                               },
//                               onDaySelected: (selectedDay, focusedDay) {
//                                 setState(() {
//                                   _selectedDay = selectedDay;
//                                   _focusedDay = focusedDay;
//                                 });
//                               },
//                               calendarFormat: CalendarFormat.month,
//                             ),
//                             SizedBox(height: 20),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 16.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "This Month",
//                                     style: TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(height: 10),
//                                   ListView.builder(
//                                     shrinkWrap: true,
//                                     physics: NeverScrollableScrollPhysics(),
//                                     itemCount: tasks.length,
//                                     itemBuilder: (context, index) {
//                                       final task = tasks[index];
//                                       return GestureDetector(
//                                         onTap: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   TaskDetailsPage(task: task),
//                                             ),
//                                           );
//                                         },
//                                         child: Card(
//                                           margin: EdgeInsets.only(bottom: 10),
//                                           child: ListTile(
//                                             leading: Checkbox(
//                                               value: task['done'],
//                                               onChanged: (bool? value) {
//                                                 _toggleTaskDone(index);
//                                               },
//                                             ),
//                                             title: Text(
//                                               task['task']!,
//                                               style: TextStyle(
//                                                 decoration: task['done']
//                                                     ? TextDecoration.lineThrough
//                                                     : TextDecoration.none,
//                                               ),
//                                             ),
//                                             subtitle: Text(
//                                               "Due: ${task['date']} at ${task['time']}",
//                                               style: TextStyle(fontSize: 14),
//                                             ),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
// : Column(
//     children: [
//       TableCalendar(
//         firstDay: DateTime.utc(2000, 1, 1),
//         lastDay: DateTime.utc(2100, 12, 31),
//         focusedDay: _focusedDay,
//         selectedDayPredicate: (day) =>
//             isSameDay(_selectedDay, day),
//         onDaySelected: (selectedDay, focusedDay) {
//           setState(() {
//             _selectedDay = selectedDay;
//             _focusedDay = focusedDay;
//           });
//         },
//         calendarFormat: CalendarFormat.month,
//       ),
//       SizedBox(height: 20),
//       Text(
//           "Tasks for ${_selectedDay?.toLocal().toString().split(' ')[0] ?? "Today"}",
//           style: TextStyle(
//               fontSize: 18, fontWeight: FontWeight.bold)),
//       SizedBox(height: 10),
//       Expanded(
//         child: ListView.builder(
//           itemCount: _getTasksForSelectedDay().length,
//           itemBuilder: (context, index) {
//             final task = _getTasksForSelectedDay()[index];
//             return Card(
//               margin: EdgeInsets.symmetric(
//                   horizontal: 16, vertical: 5),
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) =>
//                           TaskDetailsPage(task: task),
//                     ),
//                   );
//                 },
//                 child: ListTile(
// leading: Checkbox(
//   value: task['done'],
//   onChanged: (bool? value) =>
//       _toggleTaskDone(index),
// ),
//                   title: Text(
//                     task['task'],
//                     style: TextStyle(
//                       decoration: task['done']
//                           ? TextDecoration.lineThrough
//                           : TextDecoration.none,
//                     ),
//                   ),
//                   subtitle: Text("Due: ${task['time']}",
//                       style: TextStyle(fontSize: 14)),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     ],
//   ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddTaskDialog,
//         child: Icon(Icons.add),
//         tooltip: "Add Task",
//       ),
//   bottomNavigationBar: BottomNavigationBar(
//     currentIndex: _selectedIndex,
//     onTap: _onBottomNavTapped,
//     type: BottomNavigationBarType.fixed, // Ensures visibility of all items
//     items: [
//       BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//       BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.notifications),
//         label: "Alerts",
//       ),
//       BottomNavigationBarItem(
//           icon: Icon(Icons.settings), label: "Settings"),
//       BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//     ],
//   ),
// );
//   }
// }


//home_page.dart


// import 'package:dooms_day/pages/task_details.dart';
// import 'package:dooms_day/widget/AddTaskDialog.dart';
// import 'package:dooms_day/widget/ConfirmDeleteDialog.dart';
// import 'package:dooms_day/widget/CustomCalendar.dart';
// import 'package:dooms_day/widget/TaskListForSelectedDay.dart';
// import 'package:dooms_day/widget/TaskListView.dart';

// import 'package:dooms_day/widget/month_custom_calendar.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key, required bool isDarkMode, required Function toggleTheme});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   bool _isMonthlySelected = true;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;

//   List<Map<String, dynamic>> tasks = [];
//   List<Map<String, dynamic>> tasksForSelectedMonth = [];
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadTasks();
//     });
//   }

//   void _confirmDeleteTask(Map<String, dynamic> task) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return ConfirmDeleteDialog(
//           taskName: task['task'],
//           onDelete: () => _removeTask(task),
//         );
//       },
//     );
//   }

//   void _removeTask(Map<String, dynamic> task) {
//     setState(() {
//       tasks.removeWhere(
//           (t) => t['task'] == task['task'] && t['date'] == task['date']);
//     });
//     _saveTasks(); // Save updated task list
//     _loadTasksForMonth(); // Refresh the monthly view
//   }

//   Future<void> _saveTasks() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String tasksJson = jsonEncode(tasks);
//     await prefs.setString('tasks', tasksJson);
//   }

//   Future<void> _loadTasks() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? tasksJson = prefs.getString('tasks');
//     if (tasksJson != null) {
//       setState(() {
//         tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
//       });
//       _loadTasksForMonth();
//     }
//   }

//   void _loadTasksForMonth() {
//     setState(() {
//       tasksForSelectedMonth = tasks.where((task) {
//         try {
//           DateTime taskDate = DateTime.parse(task['date']);

//           return taskDate.year == _focusedDay.year &&
//               taskDate.month == _focusedDay.month;
//         } catch (e) {
//           print("Error parsing date: ${task['date']} - $e");
//           return false;
//         }
//       }).toList();

//       // Debugging log
//       print(
//           "Loaded tasks for ${_focusedDay.month}/${_focusedDay.year}: $tasksForSelectedMonth");
//     });
//   }

//   void _toggleTaskDone(String taskName) {
//     setState(() {
//       int originalIndex = tasks.indexWhere((task) => task['task'] == taskName);
//       if (originalIndex != -1) {
//         tasks[originalIndex]['done'] = !tasks[originalIndex]['done'];
//       }
//     });
//     _saveTasks();
//     _loadTasksForMonth();
//   }

//   Map<DateTime, List<Map<String, dynamic>>> _getTaskEvents() {
//     Map<DateTime, List<Map<String, dynamic>>> events = {};
//     for (var task in tasks) {
//       DateTime taskDate = DateTime.parse(task['date']);
//       events[taskDate] = events[taskDate] ?? [];
//       events[taskDate]!.add(task);
//     }
//     return events;
//   }

//   void _showAddTaskDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AddTaskDialog(
//           onTaskAdded: (task, date, time) {
//             setState(() {
//               tasks.add(
//                   {'task': task, 'date': date, 'time': time, 'done': false});
//             });
//             _saveTasks();
//             _loadTasksForMonth();
//           },
//         );
//       },
//     );
//   }

//   List<Map<String, dynamic>> _getTasksForSelectedDay() {
//     String formattedDate = _selectedDay?.toIso8601String().split("T")[0] ?? "";
//     return tasks.where((task) => task['date'] == formattedDate).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text("Tasks"),
//           leading: IconButton(
//               onPressed: () {}, icon: Icon(Icons.nightlight_outlined),),
            //   actions: [IconButton(
            //   icon: Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
            //   onPressed: () async {
            //     // await Navigator.pushNamed(context, MyRoutes.qrRoute);
            //     setState(() {});
            //   },
            // ),],
//           centerTitle: true,
//           backgroundColor: Colors.blueAccent),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const SizedBox(height: 20),
//             ToggleButtons(
//               isSelected: [_isMonthlySelected, !_isMonthlySelected],
//               onPressed: (int index) {
//                 setState(() {
//                   _isMonthlySelected = index == 0;
//                 });
//               },
//               borderRadius: BorderRadius.circular(10),
//               borderColor: Colors.blue,
//               selectedBorderColor: Colors.blueAccent,
//               fillColor: Colors.blue.withOpacity(0.1),
//               children: const [
//                 Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Text("Monthly")),
//                 Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 16),
//                     child: Text("Daily"))
//               ],
//             ),
//             const SizedBox(height: 20),
//             Expanded(
//               child: Center(
//                 child: _isMonthlySelected
//                     ? SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             CustomCalendar2(
//                               focusedDay: _focusedDay,
//                               selectedDay: _selectedDay,
//                               onDaySelected: (selectedDay, focusedDay) {
//                                 setState(() {
//                                   _selectedDay = selectedDay;
//                                   _focusedDay = focusedDay;
//                                 });
//                               },
//                               onPageChanged: (focusedDay) {
//                                 setState(() {
//                                   _focusedDay = focusedDay;
//                                 });
//                                 _loadTasksForMonth();
//                               },
//                               getTaskEvents: _getTaskEvents,
//                             ),
//                             const SizedBox(height: 20),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 16.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   const Text("This Month",
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold)),
//                                   ElevatedButton.icon(
//                                     onPressed: _showAddTaskDialog,
//                                     icon: const Icon(Icons.add),
//                                     label: const Text("Add Task"),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.blueAccent,
//                                       foregroundColor: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             TaskListView(
//                               tasks: tasksForSelectedMonth,
//                               onTaskTap: (task) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         TaskDetailsPage(task: task),
//                                   ),
//                                 );
//                               },
//                               onTaskToggle: (taskName) {
//                                 _toggleTaskDone(taskName);
//                               },
//                               onDeleteTask: (task) {
//                                 _confirmDeleteTask(task);
//                               },
//                             ),
//                           ],
//                         ),
//                       )
//                     : SingleChildScrollView(
//                         child: Column(
//                           children: [
//                             CustomCalendar(
//                               focusedDay: _focusedDay,
//                               selectedDay: _selectedDay,
//                               onDaySelected: (selectedDay, focusedDay) {
//                                 setState(() {
//                                   _selectedDay = selectedDay;
//                                   _focusedDay = focusedDay;
//                                 });
//                               },
//                               getTaskEvents: _getTaskEvents,
//                             ),
//                             const SizedBox(height: 20),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 16.0),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     "Tasks for ${_selectedDay?.toLocal().toString().split(' ')[0] ?? "Today"}",
//                                     style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   ElevatedButton.icon(
//                                     onPressed: _showAddTaskDialog,
//                                     icon: const Icon(Icons.add),
//                                     label: const Text("Add Task"),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.blueAccent,
//                                       foregroundColor: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             SizedBox(
//                               height: MediaQuery.of(context).size.height *
//                                   0.6, // Adjust height dynamically
//                               child: TaskListForSelectedDay(
//                                 tasks: _getTasksForSelectedDay(),
//                                 onTaskTap: (task) {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           TaskDetailsPage(task: task),
//                                     ),
//                                   );
//                                 },
//                                 onTaskToggle: (taskName) {
//                                   _toggleTaskDone(taskName);
//                                 },
//                                 onDeleteTask: (task) {
//                                   _confirmDeleteTask(task);
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//main_screen.dart


// import 'package:dooms_day/widget/bottomNavigationBar.dart';
// import 'package:flutter/material.dart';
// import 'home_page.dart';
// import 'search_page.dart';
// import 'alerts_page.dart';
// import 'settings_page.dart';
// import 'profile_page.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key}) : super(key: key);

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const HomePage(),
//     const SearchPage(),
//     const AlertsPage(),
//     const SettingsPage(),
//     const ProfilePage(),
//   ];

//   void _onBottomNavTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex], // Show the selected page
//       bottomNavigationBar: CustomBottomNavBar(
//         currentIndex: _selectedIndex,
//         onTap: _onBottomNavTapped,
//       ),
//     );
//   }
// }



//main.dart


/*
import 'package:dooms_day/pages/main_screen.dart';
import 'package:dooms_day/pages/settings_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Day',
      home: const MainScreen(),
      routes: {
        '/setting': (_) => SettingsPage(),
      },
    );
  }
}


*/