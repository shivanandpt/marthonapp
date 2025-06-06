import 'package:cloud_firestore/cloud_firestore.dart';
import 'heart_rate_model.dart';
import 'weather_model.dart';
import 'route_point_model.dart';
import 'phase_completion_model.dart';
import 'run_settings_model.dart';
import 'social_sharing_model.dart';
import 'user_feedback_model.dart';

class RunModel {
  // Identification
  final String id;
  final String userId;
  final String? trainingDayId;
  final String? planId;

  // Run Identification
  final int runNumber; // Sequential run number for the user
  final String sessionType; // "training", "free_run", "race"

  // Timing
  final DateTime startTime;
  final DateTime endTime;
  final int duration; // Total duration in seconds
  final int activeDuration; // Duration excluding pauses
  final int pausedDuration; // Total time spent paused

  // Performance Metrics
  final double totalDistance; // in meters
  final double elevationGain; // in meters
  final double elevationLoss; // in meters
  final double avgSpeed; // meters per second
  final double maxSpeed; // meters per second
  final double avgPace; // minutes per kilometer
  final double bestPace; // best 1km pace
  final int steps;
  final int cadence; // steps per minute

  // Health Metrics
  final int calories; // estimated calories burned
  final HeartRateModel? heartRate;

  // Weather Conditions
  final WeatherModel? weather;

  // Route Data
  final List<RoutePointModel> routePoints;

  // Phase Completion Details
  final List<PhaseCompletionModel> phasesCompleted;

  // User Settings During Run
  final RunSettingsModel settings;

  // Social & Sharing
  final SocialSharingModel socialSharing;

  // Status & Completion
  final String status; // "completed", "paused", "abandoned", "in_progress"
  final double completionRate; // percentage of planned workout completed

  // User Feedback
  final UserFeedbackModel? feedback;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const RunModel({
    required this.id,
    required this.userId,
    this.trainingDayId,
    this.planId,
    required this.runNumber,
    required this.sessionType,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.activeDuration,
    required this.pausedDuration,
    required this.totalDistance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.avgPace,
    required this.bestPace,
    required this.steps,
    required this.cadence,
    required this.calories,
    this.heartRate,
    this.weather,
    required this.routePoints,
    required this.phasesCompleted,
    required this.settings,
    required this.socialSharing,
    required this.status,
    required this.completionRate,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters for backward compatibility
  double get distance => totalDistance;
  DateTime get timestamp => startTime;
  double get speed => avgSpeed;
  bool get shared => socialSharing.shared;
  bool get voiceEnabled => settings.voiceEnabled;
  bool get vibrationOnly => settings.vibrationOnly;

  // Utility getters
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

  String get formattedActiveDuration {
    final duration = Duration(seconds: activeDuration);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  String get formattedDistance {
    if (totalDistance >= 1000) {
      return '${(totalDistance / 1000).toStringAsFixed(2)} km';
    } else {
      return '${totalDistance.toStringAsFixed(0)} m';
    }
  }

  String get formattedPace {
    final paceMinutes = avgPace.floor();
    final paceSeconds = ((avgPace - paceMinutes) * 60).round();
    return '${paceMinutes}:${paceSeconds.toString().padLeft(2, '0')}/km';
  }

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isPaused => status == 'paused';
  bool get isAbandoned => status == 'abandoned';

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
      trainingDayId: data['trainingDayId'],
      planId: data['planId'],
      runNumber: (data['runNumber'] as num?)?.toInt() ?? 1,
      sessionType: data['sessionType'] ?? 'free_run',
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: (data['endTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: (data['duration'] as num?)?.toInt() ?? 0,
      activeDuration: (data['activeDuration'] as num?)?.toInt() ?? 0,
      pausedDuration: (data['pausedDuration'] as num?)?.toInt() ?? 0,
      totalDistance: (data['totalDistance'] as num?)?.toDouble() ?? 0.0,
      elevationGain: (data['elevationGain'] as num?)?.toDouble() ?? 0.0,
      elevationLoss: (data['elevationLoss'] as num?)?.toDouble() ?? 0.0,
      avgSpeed: (data['avgSpeed'] as num?)?.toDouble() ?? 0.0,
      maxSpeed: (data['maxSpeed'] as num?)?.toDouble() ?? 0.0,
      avgPace: (data['avgPace'] as num?)?.toDouble() ?? 0.0,
      bestPace: (data['bestPace'] as num?)?.toDouble() ?? 0.0,
      steps: (data['steps'] as num?)?.toInt() ?? 0,
      cadence: (data['cadence'] as num?)?.toInt() ?? 0,
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      heartRate:
          data['heartRate'] != null
              ? HeartRateModel.fromMap(data['heartRate'])
              : null,
      weather:
          data['weather'] != null
              ? WeatherModel.fromMap(data['weather'])
              : null,
      routePoints:
          (data['routePoints'] as List<dynamic>?)
              ?.map((point) => RoutePointModel.fromMap(point))
              .toList() ??
          [],
      phasesCompleted:
          (data['phasesCompleted'] as List<dynamic>?)
              ?.map((phase) => PhaseCompletionModel.fromMap(phase))
              .toList() ??
          [],
      settings: RunSettingsModel.fromMap(data['settings'] ?? {}),
      socialSharing: SocialSharingModel.fromMap(data['socialSharing'] ?? {}),
      status: data['status'] ?? 'completed',
      completionRate: (data['completionRate'] as num?)?.toDouble() ?? 100.0,
      feedback:
          data['feedback'] != null
              ? UserFeedbackModel.fromMap(data['feedback'])
              : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      if (trainingDayId != null) 'trainingDayId': trainingDayId,
      if (planId != null) 'planId': planId,
      'runNumber': runNumber,
      'sessionType': sessionType,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'duration': duration,
      'activeDuration': activeDuration,
      'pausedDuration': pausedDuration,
      'totalDistance': totalDistance,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'avgSpeed': avgSpeed,
      'maxSpeed': maxSpeed,
      'avgPace': avgPace,
      'bestPace': bestPace,
      'steps': steps,
      'cadence': cadence,
      'calories': calories,
      if (heartRate != null) 'heartRate': heartRate!.toMap(),
      if (weather != null) 'weather': weather!.toMap(),
      'routePoints': routePoints.map((point) => point.toMap()).toList(),
      'phasesCompleted': phasesCompleted.map((phase) => phase.toMap()).toList(),
      'settings': settings.toMap(),
      'socialSharing': socialSharing.toMap(),
      'status': status,
      'completionRate': completionRate,
      if (feedback != null) 'feedback': feedback!.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to create a copy with updated fields
  RunModel copyWith({
    String? id,
    String? userId,
    String? trainingDayId,
    String? planId,
    int? runNumber,
    String? sessionType,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    int? activeDuration,
    int? pausedDuration,
    double? totalDistance,
    double? elevationGain,
    double? elevationLoss,
    double? avgSpeed,
    double? maxSpeed,
    double? avgPace,
    double? bestPace,
    int? steps,
    int? cadence,
    int? calories,
    HeartRateModel? heartRate,
    WeatherModel? weather,
    List<RoutePointModel>? routePoints,
    List<PhaseCompletionModel>? phasesCompleted,
    RunSettingsModel? settings,
    SocialSharingModel? socialSharing,
    String? status,
    double? completionRate,
    UserFeedbackModel? feedback,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RunModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      trainingDayId: trainingDayId ?? this.trainingDayId,
      planId: planId ?? this.planId,
      runNumber: runNumber ?? this.runNumber,
      sessionType: sessionType ?? this.sessionType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      activeDuration: activeDuration ?? this.activeDuration,
      pausedDuration: pausedDuration ?? this.pausedDuration,
      totalDistance: totalDistance ?? this.totalDistance,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      avgSpeed: avgSpeed ?? this.avgSpeed,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      avgPace: avgPace ?? this.avgPace,
      bestPace: bestPace ?? this.bestPace,
      steps: steps ?? this.steps,
      cadence: cadence ?? this.cadence,
      calories: calories ?? this.calories,
      heartRate: heartRate ?? this.heartRate,
      weather: weather ?? this.weather,
      routePoints: routePoints ?? this.routePoints,
      phasesCompleted: phasesCompleted ?? this.phasesCompleted,
      settings: settings ?? this.settings,
      socialSharing: socialSharing ?? this.socialSharing,
      status: status ?? this.status,
      completionRate: completionRate ?? this.completionRate,
      feedback: feedback ?? this.feedback,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
