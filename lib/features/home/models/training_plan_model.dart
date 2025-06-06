import 'package:cloud_firestore/cloud_firestore.dart';
import 'plan/plan_structure_model.dart';
import 'plan/plan_progress_model.dart';
import 'plan/plan_dates_model.dart';
import 'plan/plan_settings_model.dart';
import 'plan/plan_statistics_model.dart';
import 'training_day_model.dart';

class TrainingPlanModel {
  final String id;
  final String userId;
  final String goalType; // "5K", "10K", "half-marathon", "marathon"
  final String planType; // "custom" or "default"
  final String planName;
  final String description;

  // Training Days - Array of training sessions (count equals totalSessions)
  final List<TrainingDayModel> trainingDays;

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
    required this.id,
    required this.userId,
    required this.goalType,
    required this.planType,
    required this.planName,
    required this.description,
    required this.trainingDays,
    required this.structure,
    required this.progress,
    required this.dates,
    required this.settings,
    required this.statistics,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         trainingDays.length == structure.totalSessions,
         'Training days count (${trainingDays.length}) must equal totalSessions (${structure.totalSessions})',
       );

  // Backward compatibility getters
  int get weeks => structure.weeks;
  bool get isActive => progress.isActive;
  bool get custom => planType == 'custom';

  // Helper getters for training days using existing fields
  List<TrainingDayModel> get completedTrainingDays =>
      trainingDays.where((day) => day.completed).toList();

  List<TrainingDayModel> get remainingTrainingDays =>
      trainingDays.where((day) => !day.completed).toList();

  List<TrainingDayModel> get upcomingTrainingDays =>
      trainingDays
          .where(
            (day) =>
                !day.completed &&
                day.dateScheduled != null &&
                day.dateScheduled!.isAfter(
                  DateTime.now().subtract(const Duration(days: 1)),
                ),
          )
          .toList();

  TrainingDayModel? get todaysTrainingDay {
    final today = DateTime.now();
    try {
      return trainingDays.firstWhere(
        (day) =>
            day.dateScheduled != null &&
            _isSameDay(day.dateScheduled!, today) &&
            !day.completed,
      );
    } catch (e) {
      return null;
    }
  }

  TrainingDayModel? get nextTrainingDay {
    final upcoming = upcomingTrainingDays;
    if (upcoming.isEmpty) return null;

    upcoming.sort((a, b) => a.dateScheduled!.compareTo(b.dateScheduled!));
    return upcoming.first;
  }

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
      trainingDays:
          (data['trainingDays'] as List<dynamic>?)
              ?.map(
                (dayData) =>
                    TrainingDayModel.fromMap(dayData as Map<String, dynamic>),
              )
              .toList() ??
          [],
      structure: PlanStructureModel.fromMap(data['structure'] ?? {}),
      progress: PlanProgressModel.fromMap(data['progress'] ?? {}),
      dates: PlanDatesModel.fromMap(data['dates'] ?? {}),
      settings: PlanSettingsModel.fromMap(data['settings'] ?? {}),
      statistics: PlanStatisticsModel.fromMap(data['statistics'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'trainingDays': trainingDays.map((day) => day.toMap()).toList(),
      'structure': structure.toMap(),
      'progress': progress.toMap(),
      'dates': dates.toMap(),
      'settings': settings.toMap(),
      'statistics': statistics.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Create a copy with updated fields
  TrainingPlanModel copyWith({
    String? id,
    String? userId,
    String? goalType,
    String? planType,
    String? planName,
    String? description,
    List<TrainingDayModel>? trainingDays,
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
      trainingDays: trainingDays ?? this.trainingDays,
      structure: structure ?? this.structure,
      progress: progress ?? this.progress,
      dates: dates ?? this.dates,
      settings: settings ?? this.settings,
      statistics: statistics ?? this.statistics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Update a specific training day using existing fields
  TrainingPlanModel updateTrainingDay(
    String trainingDayId,
    TrainingDayModel Function(TrainingDayModel) updateFunction,
  ) {
    final updatedTrainingDays =
        trainingDays.map((day) {
          if (day.id == trainingDayId) {
            return updateFunction(day);
          }
          return day;
        }).toList();

    return copyWith(
      trainingDays: updatedTrainingDays,
      updatedAt: DateTime.now(),
    );
  }

  // Mark training day as completed using existing fields only
  TrainingPlanModel markTrainingDayCompleted(String trainingDayId) {
    final updatedTrainingDays =
        trainingDays.map((day) {
          if (day.id == trainingDayId) {
            return day.copyWith(
              status: day.status.copyWith(completed: true),
              completionData: day.completionData.copyWith(
                completedAt: DateTime.now(),
              ),
            );
          }
          return day;
        }).toList();

    final completedCount =
        updatedTrainingDays.where((day) => day.completed).length;

    return copyWith(
      trainingDays: updatedTrainingDays,
      progress: progress.copyWith(completedSessions: completedCount),
      updatedAt: DateTime.now(),
    );
  }

  // Replace a training day entirely
  TrainingPlanModel replaceTrainingDay(TrainingDayModel updatedDay) {
    final updatedTrainingDays =
        trainingDays.map((day) {
          if (day.id == updatedDay.id) {
            return updatedDay;
          }
          return day;
        }).toList();

    return copyWith(
      trainingDays: updatedTrainingDays,
      updatedAt: DateTime.now(),
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

  // Helper methods for plan management
  TrainingPlanModel markAsCompleted() {
    return copyWith(
      progress: progress.copyWith(isActive: false),
      dates: dates.copyWith(actualEndDate: DateTime.now()),
      updatedAt: DateTime.now(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  String toString() {
    return 'TrainingPlanModel(id: $id, goalType: $goalType, planName: $planName, isActive: ${progress.isActive}, trainingDays: ${trainingDays.length})';
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
