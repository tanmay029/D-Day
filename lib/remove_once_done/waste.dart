
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
