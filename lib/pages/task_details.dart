import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:math';

class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late DateTime taskDeadline;
  Duration remainingTime = Duration.zero;
  late Timer _timer;
  late String selectedQuote;

  final List<String> motivationalQuotes = [
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    "Believe in yourself and all that you are.",
    "Every moment is a fresh beginning.",
    "Do what you can, with what you have, where you are."
  ];

  @override
  void initState() {
    super.initState();
    taskDeadline = DateFormat("yyyy-MM-dd h:mm a")
        .parse("${widget.task['date']} ${widget.task['time']}");
    _updateRemainingTime();
    _startTimer();
    selectedQuote =
        motivationalQuotes[Random().nextInt(motivationalQuotes.length)];
  }

  void _updateRemainingTime() {
    setState(() {
      remainingTime = taskDeadline.difference(DateTime.now());
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final newRemainingTime = taskDeadline.difference(DateTime.now());
      if (newRemainingTime.isNegative) {
        timer.cancel();
      }
      setState(() {
        remainingTime = newRemainingTime;
      });
    });
  }

  String formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return "$days d $hours h $minutes m $seconds s";
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = widget.task['done'];
    bool isOverdue = remainingTime.isNegative && !isCompleted;

    return Scaffold(
      appBar: AppBar(title: Text("Task Details"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : isOverdue
                        ? Icons.cancel
                        : Icons.access_time,
                size: 100,
                color: isCompleted
                    ? Colors.green
                    : isOverdue
                        ? Colors.red
                        : Colors.orange,
              ),
              SizedBox(height: 20),
              Text(
                widget.task['task'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text("Due Date: ${widget.task['date']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              Text("Due Time: ${widget.task['time']}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              SizedBox(height: 30),

              // Timer Section
              if (!isCompleted && !isOverdue)
                Column(
                  children: [
                    Text(
                      "Time Remaining:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: AnimatedBuilder(
                        animation:
                            Listenable.merge([ValueNotifier(remainingTime)]),
                        builder: (context, child) {
                          return Text(
                            formatDuration(remainingTime),
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),

                    // Motivational Quote
                    Container(
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Text(
                        selectedQuote,
                        style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),

              // Completion / Overdue Messages
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Great Job! You completed this task on time!",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (isOverdue)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "You can do better than that! Try managing your time wisely.",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 30),

              // Back Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Back to Home",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
