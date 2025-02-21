import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pedometer/pedometer.dart';

class StepTrackerScreen extends StatefulWidget {
  @override
  _StepTrackerScreenState createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  int currentSteps = 0;
  int goalSteps = 10000;
  late Stream<StepCount> _stepCountStream;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepError);
  }

  void _onStepCount(StepCount event) {
    setState(() {
      currentSteps = event.steps; // Update the step count
    });
  }

  void _onStepError(error) {
    print("Pedometer error: $error");
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (currentSteps / goalSteps).clamp(0.0, 1.0);
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Beta Testing"),
      ),
      backgroundColor: Color(0xFFF2A900),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StepProgressIndicator(currentSteps: currentSteps, percentage: percentage),
            SizedBox(height: 20),
            GoalSelectionWidget(
              goalSteps: goalSteps,
              onGoalChanged: (newGoal) {
                setState(() {
                  goalSteps = newGoal;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentSteps;
  final double percentage;

  StepProgressIndicator({required this.currentSteps, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 10.0,
      percent: percentage,
      center: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$currentSteps",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "STEPS",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      progressColor: Colors.white,
      backgroundColor: Colors.white.withOpacity(0.3),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}

class GoalSelectionWidget extends StatelessWidget {
  final int goalSteps;
  final ValueChanged<int> onGoalChanged;

  GoalSelectionWidget({required this.goalSteps, required this.onGoalChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "GOAL: $goalSteps STEPS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Slider(
          min: 1000,
          max: 20000,
          divisions: 19,
          value: goalSteps.toDouble(),
          onChanged: (value) {
            onGoalChanged(value.toInt());
          },
        ),
        Text(
          "164 CAL",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
