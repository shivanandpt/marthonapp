import 'package:cloud_firestore/cloud_firestore.dart';

class RunModel {
  final String id;
  final String userId;
  final String? trainingDayId;
  final DateTime timestamp; // startTime
  final int duration; // in seconds
  final int distance; // in meters
  final int elevationGain; // in meters
  final double avgSpeed; // in m/s
  final int steps;
  final bool voiceEnabled;
  final bool vibrationOnly;
  final bool shared;
  final List<Map<String, dynamic>>? routePoints;

  RunModel({
    required this.id,
    required this.userId,
    this.trainingDayId,
    required this.timestamp,
    required this.duration,
    required this.distance,
    this.elevationGain = 0,
    required this.avgSpeed,
    this.steps = 0,
    this.voiceEnabled = true,
    this.vibrationOnly = false,
    this.shared = false,
    this.routePoints,
  });

  // Calculate pace in minutes per km
  double get paceMinPerKm {
    if (distance == 0) return 0;
    return (duration / 60) / (distance / 1000);
  }

  // Calculate calories burned (basic estimate)
  int calculateCalories(int weightKg) {
    // Basic MET calculation (Metabolic Equivalent of Task)
    // Running MET values: slow(6), moderate(8.3), fast(9.8), very fast(12.3)
    double met;
    if (avgSpeed < 2.2) {
      met = 6.0; // slow jogging
    } else if (avgSpeed < 3.3) {
      met = 8.3; // moderate running
    } else if (avgSpeed < 4.2) {
      met = 9.8; // fast running
    } else {
      met = 12.3; // very fast running
    }

    // Calories = MET * weight in kg * time in hours
    return (met * weightKg * (duration / 3600)).round();
  }

  // Convert Firestore document to RunModel
  factory RunModel.fromFirestore(Map<String, dynamic> data, String id) {
    return RunModel(
      id: id,
      userId: data['userId'] ?? '',
      trainingDayId: data['trainingDayId'],
      timestamp:
          data['startTime'] != null
              ? (data['startTime'] as Timestamp).toDate()
              : DateTime.now(),
      duration: data['duration'] ?? 0,
      distance: data['totalDistance'] ?? 0,
      elevationGain: data['elevationGain'] ?? 0,
      avgSpeed: data['avgSpeed']?.toDouble() ?? 0.0,
      steps: data['steps'] ?? 0,
      voiceEnabled: data['voiceEnabled'] ?? true,
      vibrationOnly: data['vibrationOnly'] ?? false,
      shared: data['shared'] ?? false,
      routePoints:
          data['routePoints'] != null
              ? List<Map<String, dynamic>>.from(data['routePoints'])
              : null,
    );
  }

  // Convert RunModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'trainingDayId': trainingDayId,
      'startTime': timestamp,
      'duration': duration,
      'totalDistance': distance,
      'elevationGain': elevationGain,
      'avgSpeed': avgSpeed,
      'steps': steps,
      'voiceEnabled': voiceEnabled,
      'vibrationOnly': vibrationOnly,
      'shared': shared,
      'routePoints': routePoints,
    };
  }

  // Create a copy of this RunModel with updated fields
  RunModel copyWith({
    String? userId,
    String? trainingDayId,
    DateTime? timestamp,
    int? duration,
    int? distance,
    int? elevationGain,
    double? avgSpeed,
    int? steps,
    bool? voiceEnabled,
    bool? vibrationOnly,
    bool? shared,
    List<Map<String, dynamic>>? routePoints,
  }) {
    return RunModel(
      id: this.id,
      userId: userId ?? this.userId,
      trainingDayId: trainingDayId ?? this.trainingDayId,
      timestamp: timestamp ?? this.timestamp,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      elevationGain: elevationGain ?? this.elevationGain,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      steps: steps ?? this.steps,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      vibrationOnly: vibrationOnly ?? this.vibrationOnly,
      shared: shared ?? this.shared,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  // Helper for displaying formatted pace
  String get formattedPace {
    final pace = paceMinPerKm;
    if (pace == 0) return "0:00";

    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  // Helper for displaying formatted duration
  String get formattedDuration {
    final hours = (duration / 3600).floor();
    final minutes = ((duration % 3600) / 60).floor();
    final seconds = duration % 60;

    if (hours > 0) {
      return "${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s";
    } else {
      return "${minutes}m ${seconds.toString().padLeft(2, '0')}s";
    }
  }

  // Helper for displaying formatted distance
  String get formattedDistance {
    final km = distance / 1000;
    return "${km.toStringAsFixed(2)} km";
  }
}
