import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';

class LocalRunStorage {
  static const String _activeRunKey = 'active_run_data';
  static const String _pendingRunsKey = 'pending_runs_to_upload';

  // Save active run data locally
  static Future<void> saveActiveRun({
    required List<RunPhaseModel> phases,
    required int currentPhaseIndex,
    required String status,
    required int elapsedSeconds,
    required int phaseElapsedSeconds,
    required double totalDistance,
    required List<Map<String, dynamic>> routePoints,
    required DateTime? startTime,
    required int totalPausedSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final runData = {
      'phases': phases.map((p) => p.toMap()).toList(),
      'currentPhaseIndex': currentPhaseIndex,
      'status': status,
      'elapsedSeconds': elapsedSeconds,
      'phaseElapsedSeconds': phaseElapsedSeconds,
      'totalDistance': totalDistance,
      'routePoints': routePoints,
      'startTime': startTime?.toIso8601String(),
      'totalPausedSeconds': totalPausedSeconds,
      'lastSaved': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_activeRunKey, jsonEncode(runData));
  }

  // Load active run data
  static Future<Map<String, dynamic>?> loadActiveRun() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_activeRunKey);

    if (dataString != null) {
      return jsonDecode(dataString);
    }
    return null;
  }

  // Clear active run data
  static Future<void> clearActiveRun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeRunKey);
  }

  // Save completed run for later upload
  static Future<void> saveCompletedRunForUpload({
    required String userId,
    required double distance,
    required int duration,
    required List<Map<String, dynamic>> routePoints,
    required List<RunPhaseModel> phases,
    required DateTime startTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final runData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'distance': distance,
      'duration': duration,
      'routePoints': routePoints,
      'phases': phases.map((p) => p.toMap()).toList(),
      'startTime': startTime.toIso8601String(),
      'completedAt': DateTime.now().toIso8601String(),
    };

    // Get existing pending runs
    final existingData = prefs.getString(_pendingRunsKey);
    List<dynamic> pendingRuns = [];

    if (existingData != null) {
      pendingRuns = jsonDecode(existingData);
    }

    pendingRuns.add(runData);
    await prefs.setString(_pendingRunsKey, jsonEncode(pendingRuns));
  }

  // Get pending runs to upload
  static Future<List<Map<String, dynamic>>> getPendingRuns() async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(_pendingRunsKey);

    if (dataString != null) {
      final data = jsonDecode(dataString) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Remove uploaded run from pending
  static Future<void> removeUploadedRun(String runId) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRuns = await getPendingRuns();

    pendingRuns.removeWhere((run) => run['id'] == runId);
    await prefs.setString(_pendingRunsKey, jsonEncode(pendingRuns));
  }

  // Clear all pending runs
  static Future<void> clearPendingRuns() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingRunsKey);
  }
}
