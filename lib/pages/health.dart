import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});

  @override
  _StepTrackerScreenState createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  int currentSteps = 0;
  int goalSteps = 10000;
  late Stream<StepCount> _stepCountStream;
  String lastRecordedDate = "";

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initPedometer();
    _requestBackgroundPermission();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepError);
  }

  void _onStepCount(StepCount event) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (lastRecordedDate != today) {
      setState(() {
        currentSteps = 0;
        goalSteps = 0;
        lastRecordedDate = today;
      });
      _savePreferences();
    } else {
      setState(() {
        currentSteps = event.steps;
      });
    }
  }

  void _onStepError(error) {
    print("Pedometer error: $error");
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      goalSteps = prefs.getInt('goalSteps') ?? 10000;
      lastRecordedDate = prefs.getString('lastRecordedDate') ?? "";
      currentSteps = prefs.getInt('currentSteps') ?? 0;
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('goalSteps', goalSteps);
    await prefs.setString('lastRecordedDate', lastRecordedDate);
    await prefs.setInt('currentSteps', currentSteps);
  }

  Future<void> _requestBackgroundPermission() async {
    print("Requesting background activity permission...");
  }

  void _showGoalInputDialog() {
    TextEditingController goalController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Step Goal"),
          content: TextField(
            controller: goalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Enter step goal"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                int? newGoal = int.tryParse(goalController.text);
                if (newGoal != null && newGoal > 0) {
                  setState(() {
                    goalSteps = newGoal;
                  });
                  _savePreferences();
                }
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _resetSteps() {
    setState(() {
      currentSteps = 0;
      goalSteps = 0;
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    double percentage =
        goalSteps > 0 ? (currentSteps / goalSteps).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Step Tracker"),
        backgroundColor: Colors.orangeAccent,
      ),
      backgroundColor: Colors.orange.shade100,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Setup Daily Walking Goal",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            StepProgressIndicator(
                currentSteps: currentSteps,
                goalSteps: goalSteps,
                percentage: percentage),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _showGoalInputDialog,
                  child: Text("Setup Steps"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetSteps,
                  child: Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentSteps;
  final int goalSteps;
  final double percentage;

  const StepProgressIndicator(
      {super.key, required this.currentSteps,
      required this.goalSteps,
      required this.percentage});

  String getMotivationalText() {
    if (percentage <= 0.25) {
      return "You are better than this, You can do it !!";
    } else if (percentage <= 0.49) {
      return "Don't give up you are almost there !!";
    } else if (percentage <= 0.99) {
      return "Most people give up right before they reach their goal, don't add to that count!!";
    } else {
      return "You did it, you are better than 70% of the people!!!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 120.0,
          lineWidth: 10.0,
          percent: percentage,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$currentSteps / $goalSteps",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                "STEPS",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          progressColor: Colors.orange,
          backgroundColor: Colors.white.withOpacity(0.3),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        SizedBox(height: 20),
        Text(
          getMotivationalText(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
