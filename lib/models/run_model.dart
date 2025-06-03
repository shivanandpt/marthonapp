import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:marunthon_app/models/training_day_model.dart';

class RunModel {
  final String id;
  final String userId;
  final double avgSpeed; // m/s
  final int duration; // seconds
  final double elevationGain; // meters
  final List<Map<String, dynamic>> routePoints;
  final bool shared;
  final DateTime startTime; // Using startTime instead of timestamp
  final int steps;
  final double totalDistance; // meters
  final String? trainingDayId;
  final bool vibrationOnly;
  final bool voiceEnabled;

  const RunModel({
    required this.id,
    required this.userId,
    required this.avgSpeed,
    required this.duration,
    required this.elevationGain,
    required this.routePoints,
    required this.shared,
    required this.startTime,
    required this.steps,
    required this.totalDistance,
    this.trainingDayId,
    required this.vibrationOnly,
    required this.voiceEnabled,
  });

  // Helper getters for backward compatibility
  double get distance => totalDistance; // Use totalDistance
  DateTime get timestamp => startTime; // Use startTime
  double get speed => avgSpeed; // Use avgSpeed

  // Add this getter
  String get formattedDuration {
    final duration = Duration(seconds: this.duration);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  factory RunModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RunModel._fromData(data, doc.id);
  }

  factory RunModel.fromData(Map<String, dynamic> data, String id) {
    return RunModel._fromData(data, id);
  }

  factory RunModel._fromData(Map<String, dynamic> data, String id) {
    return RunModel(
      id: id,
      userId: data['userId'] ?? '',
      avgSpeed: (data['avgSpeed'] as num?)?.toDouble() ?? 0.0,
      duration: (data['duration'] as num?)?.toInt() ?? 0,
      elevationGain: (data['elevationGain'] as num?)?.toDouble() ?? 0.0,
      routePoints: List<Map<String, dynamic>>.from(data['routePoints'] ?? []),
      shared: data['shared'] ?? false,
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      steps: (data['steps'] as num?)?.toInt() ?? 0,
      totalDistance: (data['totalDistance'] as num?)?.toDouble() ?? 0.0,
      trainingDayId: data['trainingDayId'],
      vibrationOnly: data['vibrationOnly'] ?? false,
      voiceEnabled: data['voiceEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'avgSpeed': avgSpeed,
      'duration': duration,
      'elevationGain': elevationGain,
      'routePoints': routePoints,
      'shared': shared,
      'startTime': Timestamp.fromDate(startTime),
      'steps': steps,
      'totalDistance': totalDistance,
      if (trainingDayId != null) 'trainingDayId': trainingDayId,
      'vibrationOnly': vibrationOnly,
      'voiceEnabled': voiceEnabled,
    };
  }
}

// // When saving a run from training, ensure trainingDayId is set
// // In your run creation/saving logic:

// Future<void> completeTrainingRun(
//   TrainingDayModel trainingDay,
//   RunModel run,
// ) async {
//   // Ensure the run has the training day ID
//   final updatedRun = RunModel(
//     id: run.id,
//     userId: run.userId,
//     distance: run.distance,
//     duration: run.duration,
//     pace: run.pace,
//     calories: run.calories,
//     avgHeartRate: run.avgHeartRate,
//     maxHeartRate: run.maxHeartRate,
//     elevation: run.elevation,
//     timestamp: run.timestamp,
//     routeCoordinates: run.routeCoordinates,
//     trainingDayId: trainingDay.id, // IMPORTANT: Set this
//     notes: run.notes,
//     weather: run.weather,
//     temperature: run.temperature,
//     humidity: run.humidity,
//     windSpeed: run.windSpeed,
//   );

//   await _runService.createRun(updatedRun);
// }
