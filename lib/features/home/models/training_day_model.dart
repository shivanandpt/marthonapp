import 'package:cloud_firestore/cloud_firestore.dart';
import 'day_identification_model.dart';
import 'day_scheduling_model.dart';
import 'day_configuration_model.dart';
import 'day_status_model.dart';
import 'training_phase_model.dart';
import 'day_totals_model.dart';
import 'day_target_metrics_model.dart';
import 'day_completion_data_model.dart';

class TrainingDayModel {
  final String id;
  final String planId;

  // Day Identification
  final DayIdentificationModel identification;

  // Scheduling
  final DaySchedulingModel scheduling;

  // Day Configuration
  final DayConfigurationModel configuration;

  // Status
  final DayStatusModel status;

  // Run Phases Structure
  final List<TrainingPhaseModel> runPhases;

  // Calculated Totals
  final DayTotalsModel totals;

  // Target Metrics
  final DayTargetMetricsModel targetMetrics;

  // Completion Data
  final DayCompletionDataModel completionData;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  TrainingDayModel({
    required this.id,
    required this.planId,
    required this.identification,
    required this.scheduling,
    required this.configuration,
    required this.status,
    required this.runPhases,
    required this.totals,
    required this.targetMetrics,
    required this.completionData,
    required this.createdAt,
    required this.updatedAt,
  });

  // Backward compatibility getters
  int get week => identification.week;
  int get dayOfWeek => identification.dayOfWeek;
  DateTime get dateScheduled => scheduling.dateScheduled;
  bool get optional => configuration.optional;
  String get dayName => identification.dayName;
  bool get isToday => scheduling.isToday;
  bool get isPast => scheduling.isPast;
  bool get isUpcoming => scheduling.isUpcoming;
  bool get hasPhases => runPhases.isNotEmpty;
  int get phaseCount => runPhases.length;
  int get totalDuration => totals.totalDuration;
  String get formattedTotalDuration => totals.formattedTotalDuration;

  // Enhanced getters
  String get sessionType => identification.sessionType;
  String get sessionTypeDisplayName => identification.sessionTypeDisplayName;
  bool get completed => status.completed;
  bool get skipped => status.skipped;
  bool get locked => status.locked;
  bool get isAvailable => status.isAvailable;
  bool get restDay => configuration.restDay;
  String get difficulty => configuration.difficulty;
  String get timeSlot => scheduling.timeSlot;

  // Phase-related getters
  List<String> get phaseNames => runPhases.map((p) => p.phase).toList();
  List<Map<String, dynamic>> get parsedRunPhases =>
      runPhases.map((p) => p.toMap()).toList();

  String get workoutType {
    if (!hasPhases || restDay) return 'Rest Day';
    if (configuration.restDay) return 'Rest Day';

    final sessionTypeLower = sessionType.toLowerCase();
    switch (sessionTypeLower) {
      case 'interval':
        return 'Interval Training';
      case 'long_run':
        return 'Long Run';
      case 'tempo':
        return 'Tempo Run';
      case 'recovery':
        return 'Recovery Run';
      default:
        return 'Training';
    }
  }

  Map<String, dynamic>? getPhaseByName(String phaseName) {
    try {
      final phase = runPhases.firstWhere((p) => p.phase == phaseName);
      return phase.toMap();
    } catch (e) {
      return null;
    }
  }

  // Convert Firestore document to TrainingDayModel
  factory TrainingDayModel.fromFirestore(Map<String, dynamic> data, String id) {
    // Parse run phases
    final phasesList =
        (data['runPhases'] as List<dynamic>? ?? [])
            .map(
              (phase) =>
                  TrainingPhaseModel.fromMap(phase as Map<String, dynamic>),
            )
            .toList();

    // Calculate totals from phases
    final totals = DayTotalsModel.fromPhases(phasesList);

    return TrainingDayModel(
      id: id,
      planId: data['planId'] ?? '',
      identification: DayIdentificationModel.fromMap(
        data['identification'] ?? data,
      ),
      scheduling: DaySchedulingModel.fromMap(data['scheduling'] ?? data),
      configuration: DayConfigurationModel.fromMap(
        data['configuration'] ?? data,
      ),
      status: DayStatusModel.fromMap(data['status'] ?? {}),
      runPhases: phasesList,
      totals:
          data['totals'] != null
              ? DayTotalsModel.fromMap(data['totals'])
              : totals,
      targetMetrics: DayTargetMetricsModel.fromMap(data['targetMetrics'] ?? {}),
      completionData: DayCompletionDataModel.fromMap(
        data['completionData'] ?? {},
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert TrainingDayModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'identification': identification.toMap(),
      'scheduling': scheduling.toMap(),
      'configuration': configuration.toMap(),
      'status': status.toMap(),
      'runPhases': runPhases.map((p) => p.toMap()).toList(),
      'totals': totals.toMap(),
      'targetMetrics': targetMetrics.toMap(),
      'completionData': completionData.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper methods for day management
  TrainingDayModel markAsCompleted({
    int? actualDuration,
    double? actualDistance,
  }) {
    return copyWith(
      status: status.copyWith(completed: true),
      completionData: completionData.copyWith(
        completedAt: DateTime.now(),
        actualDuration: actualDuration,
        actualDistance: actualDistance,
      ),
      updatedAt: DateTime.now(),
    );
  }

  TrainingDayModel markAsSkipped() {
    return copyWith(
      status: status.copyWith(skipped: true),
      updatedAt: DateTime.now(),
    );
  }

  TrainingDayModel unlock() {
    return copyWith(
      status: status.copyWith(locked: false),
      updatedAt: DateTime.now(),
    );
  }

  TrainingDayModel lock() {
    return copyWith(
      status: status.copyWith(locked: true),
      updatedAt: DateTime.now(),
    );
  }

  // Create a copy with updated fields
  TrainingDayModel copyWith({
    String? id,
    String? planId,
    DayIdentificationModel? identification,
    DaySchedulingModel? scheduling,
    DayConfigurationModel? configuration,
    DayStatusModel? status,
    List<TrainingPhaseModel>? runPhases,
    DayTotalsModel? totals,
    DayTargetMetricsModel? targetMetrics,
    DayCompletionDataModel? completionData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final newPhases = runPhases ?? this.runPhases;
    final newTotals = totals ?? DayTotalsModel.fromPhases(newPhases);

    return TrainingDayModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      identification: identification ?? this.identification,
      scheduling: scheduling ?? this.scheduling,
      configuration: configuration ?? this.configuration,
      status: status ?? this.status,
      runPhases: newPhases,
      totals: newTotals,
      targetMetrics: targetMetrics ?? this.targetMetrics,
      completionData: completionData ?? this.completionData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'TrainingDayModel(id: $id, week: ${identification.week}, day: ${identification.dayOfWeek}, type: ${identification.sessionType})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrainingDayModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
