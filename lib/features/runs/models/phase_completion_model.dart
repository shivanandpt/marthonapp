import 'package:cloud_firestore/cloud_firestore.dart';

class PhaseCompletionModel {
  final String phase;
  final int duration;
  final bool completed;
  final bool skipped;
  final DateTime startTime;
  final DateTime endTime;
  final double averageSpeed;
  final double distance;

  const PhaseCompletionModel({
    required this.phase,
    required this.duration,
    required this.completed,
    required this.skipped,
    required this.startTime,
    required this.endTime,
    required this.averageSpeed,
    required this.distance,
  });

  factory PhaseCompletionModel.fromMap(Map<String, dynamic> map) {
    return PhaseCompletionModel(
      phase: map['phase'] ?? '',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      completed: map['completed'] ?? false,
      skipped: map['skipped'] ?? false,
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (map['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      averageSpeed: (map['averageSpeed'] as num?)?.toDouble() ?? 0.0,
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phase': phase,
      'duration': duration,
      'completed': completed,
      'skipped': skipped,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'averageSpeed': averageSpeed,
      'distance': distance,
    };
  }
}
