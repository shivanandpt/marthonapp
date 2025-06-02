import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class RunModel {
  final String id;
  final String userId;
  final String? trainingDayId;
  final DateTime timestamp; // startTime
  final int duration; // in seconds
  final double distance; // in meters
  final double elevationGain; // in meters
  final double avgSpeed; // in m/s
  final int steps;
  final bool voiceEnabled;
  final bool vibrationOnly;
  final bool shared;
  final List<Map<String, dynamic>>? routePoints;

  // Additional properties
  final double pace; // in min/km
  final int calories;
  final int avgHeartRate;
  final int maxHeartRate;
  final double temperature; // in Celsius
  final double humidity; // in percentage
  final double windSpeed; // in m/s
  final String notes;
  final String weather;

  double get totalDistance => distance.toDouble();
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
    this.pace = 0,
    this.calories = 0,
    this.avgHeartRate = 0,
    this.maxHeartRate = 0,
    this.temperature = 0,
    this.humidity = 0,
    this.windSpeed = 0,
    this.notes = '',
    this.weather = '',
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
      distance:
          (data['distance'] as num?)?.toDouble() ?? 0.0, // Fix: Handle null
      duration: data['duration'] ?? 0,
      avgSpeed:
          (data['avgSpeed'] as num?)?.toDouble() ??
          0.0, // Added required parameter
      pace: (data['pace'] as num?)?.toDouble() ?? 0.0, // Fix: Handle null
      calories: data['calories'] ?? 0,
      avgHeartRate: data['avgHeartRate'] ?? 0,
      maxHeartRate: data['maxHeartRate'] ?? 0,
      elevationGain:
          (data['elevationGain'] as num?)?.toDouble() ??
          0.0, // Fix: Handle null
      timestamp:
          data['timestamp'] != null
              ? (data['timestamp'] as Timestamp).toDate()
              : DateTime.now(),
      routePoints:
          (data['routeCoordinates'] as List<dynamic>?)
              ?.map(
                (coord) => {
                  'latitude': (coord['latitude'] as num?)?.toDouble() ?? 0.0,
                  'longitude': (coord['longitude'] as num?)?.toDouble() ?? 0.0,
                },
              )
              .toList() ??
          [],
      trainingDayId: data['trainingDayId'],
      notes: data['notes'] ?? '',
      weather: data['weather'] ?? '',
      temperature:
          (data['temperature'] as num?)?.toDouble() ?? 0.0, // Fix: Handle null
      humidity:
          (data['humidity'] as num?)?.toDouble() ?? 0.0, // Fix: Handle null
      windSpeed:
          (data['windSpeed'] as num?)?.toDouble() ?? 0.0, // Fix: Handle null
    );
  }

  // Convert RunModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'distance': distance,
      'duration': duration,
      'pace': pace,
      'calories': calories,
      'avgHeartRate': avgHeartRate,
      'maxHeartRate': maxHeartRate,
      'elevationGain': elevationGain,
      'timestamp': Timestamp.fromDate(timestamp),
      'routeCoordinates': routePoints ?? [],
      'trainingDayId': trainingDayId,
      'notes': notes,
      'weather': weather,
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
    };
  }

  // Create a copy of this RunModel with updated fields
  RunModel copyWith({
    String? userId,
    String? trainingDayId,
    DateTime? timestamp,
    int? duration,
    double? distance,
    double? elevationGain,
    double? avgSpeed,
    int? steps,
    bool? voiceEnabled,
    bool? vibrationOnly,
    bool? shared,
    List<Map<String, dynamic>>? routePoints,
    double? pace,
    int? calories,
    int? avgHeartRate,
    int? maxHeartRate,
    double? temperature,
    double? humidity,
    double? windSpeed,
    String? notes,
    String? weather,
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
      pace: pace ?? this.pace,
      calories: calories ?? this.calories,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      notes: notes ?? this.notes,
      weather: weather ?? this.weather,
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
