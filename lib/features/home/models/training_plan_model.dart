import 'package:cloud_firestore/cloud_firestore.dart';
import 'plan/plan_structure_model.dart';
import 'plan/plan_progress_model.dart';
import 'plan/plan_dates_model.dart';
import 'plan/plan_settings_model.dart';
import 'plan/plan_statistics_model.dart';

class TrainingPlanModel {
  final String? id;
  final String userId;
  final String goalType; // "5K", "10K", "half-marathon", "marathon"
  final String planType; // "custom" or "default"
  final String planName;
  final String description;

  // Plan Structure
  final PlanStructureModel structure;

  // Progress Tracking
  final PlanProgressModel progress;

  // Dates
  final PlanDatesModel dates;

  // Plan Settings
  final PlanSettingsModel settings;

  // Statistics
  final PlanStatisticsModel statistics;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  TrainingPlanModel({
    this.id,
    required this.userId,
    required this.goalType,
    required this.planType,
    required this.planName,
    required this.description,
    required this.structure,
    required this.progress,
    required this.dates,
    required this.settings,
    required this.statistics,
    required this.createdAt,
    required this.updatedAt,
  });

  // Backward compatibility getters
  int get weeks => structure.weeks;
  bool get isActive => progress.isActive;
  bool get custom => planType == 'custom';

  // Helper getters
  String get goalDisplayName {
    switch (goalType.toLowerCase()) {
      case '5k':
        return '5K Run';
      case '10k':
        return '10K Run';
      case 'half-marathon':
        return 'Half Marathon';
      case 'marathon':
        return 'Marathon';
      default:
        return goalType;
    }
  }

  bool get isCompleted => progress.isCompleted;
  bool get isOverdue => dates.isOverdue;

  double get completionPercentage => progress.completionPercentage;

  int get daysRemaining => dates.daysRemaining;
  int get weeksRemaining => dates.weeksRemaining;

  // Convert Firestore document to TrainingPlanModel
  factory TrainingPlanModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return TrainingPlanModel(
      id: id,
      userId: data['userId'] ?? '',
      goalType: data['goalType'] ?? '5K',
      planType: data['planType'] ?? 'default',
      planName: data['planName'] ?? 'Training Plan',
      description: data['description'] ?? '',
      structure: PlanStructureModel.fromMap(data['structure'] ?? {}),
      progress: PlanProgressModel.fromMap(data['progress'] ?? {}),
      dates: PlanDatesModel.fromMap(data['dates'] ?? {}),
      settings: PlanSettingsModel.fromMap(data['settings'] ?? {}),
      statistics: PlanStatisticsModel.fromMap(data['statistics'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert Map to TrainingPlanModel
  factory TrainingPlanModel.fromMap(Map<String, dynamic> data) {
    return TrainingPlanModel(
      id: data['id'], // May be null for new training plans
      userId: data['userId'] ?? '',
      goalType: data['goalType'] ?? '5K',
      planType: data['planType'] ?? 'default',
      planName: data['planName'] ?? 'Training Plan',
      description: data['description'] ?? '',
      structure: PlanStructureModel.fromMap(data['structure'] ?? {}),
      progress: PlanProgressModel.fromMap(data['progress'] ?? {}),
      dates: PlanDatesModel.fromMap(data['dates'] ?? {}),
      settings: PlanSettingsModel.fromMap(data['settings'] ?? {}),
      statistics: PlanStatisticsModel.fromMap(data['statistics'] ?? {}),
      createdAt:
          data['createdAt'] is DateTime
              ? data['createdAt']
              : (data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
                      DateTime.now()),
      updatedAt:
          data['updatedAt'] is DateTime
              ? data['updatedAt']
              : (data['updatedAt'] is Timestamp
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['updatedAt']?.toString() ?? '') ??
                      DateTime.now()),
    );
  }

  // Convert TrainingPlanModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'goalType': goalType,
      'planType': planType,
      'planName': planName,
      'description': description,
      'structure': structure.toMap(),
      'progress': progress.toMap(),
      'dates': dates.toMap(),
      'settings': settings.toMap(),
      'statistics': statistics.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert TrainingPlanModel to Map (for local use, includes id if available)
  Map<String, dynamic> toMap() {
    final map = {
      'userId': userId,
      'goalType': goalType,
      'planType': planType,
      'planName': planName,
      'description': description,
      'structure': structure.toMap(),
      'progress': progress.toMap(),
      'dates': dates.toMap(),
      'settings': settings.toMap(),
      'statistics': statistics.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  // Create a copy with updated fields
  TrainingPlanModel copyWith({
    String? id,
    String? userId,
    String? goalType,
    String? planType,
    String? planName,
    String? description,
    PlanStructureModel? structure,
    PlanProgressModel? progress,
    PlanDatesModel? dates,
    PlanSettingsModel? settings,
    PlanStatisticsModel? statistics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalType: goalType ?? this.goalType,
      planType: planType ?? this.planType,
      planName: planName ?? this.planName,
      description: description ?? this.description,
      structure: structure ?? this.structure,
      progress: progress ?? this.progress,
      dates: dates ?? this.dates,
      settings: settings ?? this.settings,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  TrainingPlanModel pause() {
    return copyWith(
      progress: progress.copyWith(isActive: false),
      updatedAt: DateTime.now(),
    );
  }

  TrainingPlanModel resume() {
    return copyWith(
      progress: progress.copyWith(isActive: true),
      updatedAt: DateTime.now(),
    );
  }

  TrainingPlanModel markAsCompleted() {
    return copyWith(
      progress: progress.copyWith(isActive: false),
      dates: dates.copyWith(actualEndDate: DateTime.now()),
      updatedAt: DateTime.now(),
    );
  }

  TrainingPlanModel updateProgress({
    int? currentWeek,
    int? currentDay,
    int? completedWeeks,
    int? completedSessions,
  }) {
    return copyWith(
      progress: progress.copyWith(
        currentWeek: currentWeek,
        currentDay: currentDay,
        completedWeeks: completedWeeks,
        completedSessions: completedSessions,
      ),
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'TrainingPlanModel(id: $id, goalType: $goalType, planName: $planName, isActive: ${progress.isActive})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainingPlanModel &&
        other.id == id &&
        other.userId == userId &&
        other.goalType == goalType &&
        other.planType == planType &&
        other.planName == planName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        goalType.hashCode ^
        planType.hashCode ^
        planName.hashCode;
  }
}
