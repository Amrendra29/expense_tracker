import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'fitness_detail_screen.dart';
import '../../services/fitness_data_service.dart';

class FitnessDashboard extends StatefulWidget {
  const FitnessDashboard({super.key});

  @override
  State<FitnessDashboard> createState() => _FitnessDashboardState();
}

class _FitnessDashboardState extends State<FitnessDashboard> {
  final _fitnessService = FitnessDataService();
  StreamSubscription<StepCount>? _subscription;

  int _steps = 0;
  double _calories = 0.0;
  double _distance = 0.0;
  int _goalSteps = 10000;
  DateTime _lastSync = DateTime.now();
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _initPedometer();
    _loadLocalData();
  }

  Future<void> _initPedometer() async {
    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) return;

    _subscription = Pedometer.stepCountStream.listen((event) {
      setState(() {
        _steps = event.steps;
        _distance = _steps * 0.0008;
        _calories = _steps * 0.04;
        _lastSync = DateTime.now();
      });
      _saveDailyData();
    }, onError: (error) => debugPrint("Pedometer error: $error"));
  }

  Future<void> _loadLocalData() async {
    setState(() => _isSyncing = true);
    final history = await _fitnessService.loadLocalHistory();
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (history.containsKey(todayKey)) {
      setState(() {
        _steps = history[todayKey]['steps'] ?? 0;
        _calories = history[todayKey]['calories'] ?? 0.0;
        _distance = _steps * 0.0008;
      });
    }
    setState(() => _isSyncing = false);
  }

  Future<void> _saveDailyData() async {
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _fitnessService.saveDayData(dateKey, {
      'steps': _steps,
      'calories': _calories,
      'distance': _distance,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_steps / _goalSteps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4FF),
      appBar: AppBar(
        title: const Text("Fitness Tracker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh Data",
            onPressed: () async {
              await _loadLocalData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data refreshed"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Logged out successfully"),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadLocalData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSyncStatus(),
            const SizedBox(height: 10),
            _buildTodaySummary(progress),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildWhoSuggestionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _isSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6C63FF),
                ),
              )
            : const Icon(Icons.check_circle, color: Colors.green, size: 20),
        const SizedBox(width: 6),
        Text(
          _isSyncing
              ? "Syncing..."
              : "Last updated: ${DateFormat('hh:mm a').format(_lastSync)}",
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTodaySummary(double progress) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FitnessDetailScreen()),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
        color: const Color(0xFFF0EFFF),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                "Today's Walking Record",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 20),
              CircularPercentIndicator(
                radius: 80.0,
                lineWidth: 10.0,
                animation: true,
                percent: progress,
                center: Text(
                  "${(progress * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: const Color(0xFF6C63FF),
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(height: 15),
              Text(
                "$_steps / $_goalSteps steps",
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${_calories.toStringAsFixed(1)} kcal burned",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department,
            color: Colors.redAccent,
            label: "Calories",
            value: "${_calories.toStringAsFixed(1)} kcal",
          ),
        ),
        Expanded(
          child: _buildStatCard(
            icon: Icons.route,
            color: Colors.green,
            label: "Distance",
            value: "${_distance.toStringAsFixed(2)} km",
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhoSuggestionCard() {
    return Card(
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(
              Icons.health_and_safety,
              color: Colors.deepPurple,
              size: 35,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "WHO recommends 150 minutes of brisk walking weekly "
                "for improved heart and lung health.",
                style: TextStyle(
                  color: Colors.deepPurple.shade800,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
