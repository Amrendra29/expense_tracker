import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FitnessDataService {
  final _prefs = SharedPreferences.getInstance();
  final _firestore = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  /// ✅ Save daily data locally + sync to Firestore
  Future<void> saveDayRecord(int steps, double calories) async {
    final prefs = await _prefs;
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Load old history
    Map<String, dynamic> history = {};
    String? historyString = prefs.getString('history');
    if (historyString != null) {
      history = jsonDecode(historyString);
    }

    // Update today’s record
    history[today] = {'steps': steps, 'calories': calories};
    await prefs.setString('history', jsonEncode(history));

    // ✅ Sync to Firebase
    if (_user != null) {
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('fitness_history')
          .doc(today)
          .set({
            'steps': steps,
            'calories': calories,
            'timestamp': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    }
  }

  /// ✅ Load local history
  Future<Map<String, dynamic>> loadLocalHistory() async {
    final prefs = await _prefs;
    String? historyString = prefs.getString('history');
    if (historyString != null) {
      return jsonDecode(historyString);
    }
    return {};
  }

  /// ✅ Load cloud history from Firestore
  Future<Map<String, dynamic>> loadCloudHistory() async {
    if (_user == null) return {};
    final query = await _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('fitness_history')
        .orderBy('timestamp', descending: true)
        .get();

    Map<String, dynamic> result = {};
    for (var doc in query.docs) {
      result[doc.id] = {'steps': doc['steps'], 'calories': doc['calories']};
    }
    return result;
  }

  /// ✅ Save baseline and date
  Future<void> saveBaseline(int baseline) async {
    final prefs = await _prefs;
    await prefs.setInt('baseline', baseline);
    await prefs.setString('last_date', DateTime.now().toIso8601String());
  }

  /// ✅ Load baseline and last saved date
  Future<Map<String, dynamic>> loadBaseline() async {
    final prefs = await _prefs;
    int baseline = prefs.getInt('baseline') ?? 0;
    String? lastDateStr = prefs.getString('last_date');
    DateTime lastDate = lastDateStr != null
        ? DateTime.parse(lastDateStr)
        : DateTime.now();
    return {'baseline': baseline, 'lastDate': lastDate};
  }

  /// ✅ Save today's live data (used by FitnessDashboard)
  Future<void> saveDayData(String dateKey, Map<String, dynamic> data) async {
    final prefs = await _prefs;

    // Load existing history
    String? historyString = prefs.getString('history');
    Map<String, dynamic> history = historyString != null
        ? Map<String, dynamic>.from(jsonDecode(historyString))
        : {};

    // Save or update today’s entry
    history[dateKey] = data;

    await prefs.setString('history', jsonEncode(history));

    // Optionally sync to Firebase (if logged in)
    if (_user != null) {
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .collection('fitness_history')
          .doc(dateKey)
          .set(data, SetOptions(merge: true));
    }
  }
}
