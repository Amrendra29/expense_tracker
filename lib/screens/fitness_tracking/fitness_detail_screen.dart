import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/fitness_data_service.dart';

class FitnessDetailScreen extends StatefulWidget {
  const FitnessDetailScreen({super.key});

  @override
  State<FitnessDetailScreen> createState() => _FitnessDetailScreenState();
}

class _FitnessDetailScreenState extends State<FitnessDetailScreen> {
  final _fitnessService = FitnessDataService();
  Map<String, dynamic> _history = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _fitnessService.loadLocalHistory();
    setState(() => _history = history);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _history.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // latest first

    return Scaffold(
      appBar: AppBar(
        title: const Text("Walking Record"),
        backgroundColor: const Color(0xFF3A0CA3),
      ),
      body: ListView.builder(
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final dateKey = sorted[index].key;
          final data = sorted[index].value;
          final steps = data['steps'] ?? 0;
          final kcal = data['calories'] ?? 0.0;
          final distance = (steps * 0.0008);
          final dayName = DateFormat('EEE, MMM d').format(DateTime.parse(dateKey));

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.directions_walk, color: Colors.deepPurple),
              title: Text("$steps steps"),
              subtitle: Text("$distance km · ${kcal.toStringAsFixed(1)} kcal"),
              trailing: Text(dayName,
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
            ),
          );
        },
      ),
    );
  }
}
