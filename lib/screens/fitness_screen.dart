import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;
  int goalSteps = 10000;
  double _calories = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(onStepCount).onError(onStepCountError);
    } catch (e) {
      debugPrint('Error initializing Pedometer: $e');
    }
  }

  void onStepCount(StepCount event) {
    // event.steps is cumulative since last reboot, so we display directly for now
    setState(() {
      _steps = event.steps;
      _calories = _steps * 0.04; // Rough estimate: 0.04 kcal per step
    });
  }

  void onStepCountError(error) {
    debugPrint('Step Count Error: $error');
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_steps % goalSteps) / goalSteps;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Tracker"),
        backgroundColor: const Color(0xFF3A0CA3),
      ),
      backgroundColor: const Color(0xFFF9F6FF),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Today's Summary",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Text(
                    "${(progress * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.directions_walk,
                  color: Colors.deepPurple,
                ),
                title: const Text("Steps"),
                subtitle: Text("$_steps / $goalSteps"),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.local_fire_department,
                  color: Colors.redAccent,
                ),
                title: const Text("Calories Burned"),
                subtitle: Text("${_calories.toStringAsFixed(1)} kcal"),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                "Move around to see real-time updates!",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
