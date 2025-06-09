import 'package:cloud_firestore/cloud_firestore.dart';
import 'days/day_identification_model.dart';
import 'days/day_scheduling_model.dart';
import 'days/day_configuration_model.dart';
import 'days/day_status_model.dart';
import 'days/training_phase_model.dart';
import 'days/day_totals_model.dart';
import 'days/day_target_metrics_model.dart';
import 'days/day_completion_data_model.dart';

class TrainingDayModel {
  final String? id; // Make id optional since Firebase assigns it

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
    this.id, // Remove required since Firebase assigns it
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
      id: id, // Firebase provides the id
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

  // Convert Map to TrainingDayModel
  factory TrainingDayModel.fromMap(Map<String, dynamic> data) {
    // Parse run phases
    final phasesList =
        (data['runPhases'] as List<dynamic>? ?? [])
            .map(
              (phase) =>
                  TrainingPhaseModel.fromMap(phase as Map<String, dynamic>),
            )
            .toList();

    // Calculate totals from phases if not provided
    final totals =
        data['totals'] != null
            ? DayTotalsModel.fromMap(data['totals'])
            : DayTotalsModel.fromPhases(phasesList);

    return TrainingDayModel(
      id: data['id'], // May be null for new training days
      identification: DayIdentificationModel.fromMap(
        data['identification'] ?? data,
      ),
      scheduling: DaySchedulingModel.fromMap(data['scheduling'] ?? data),
      configuration: DayConfigurationModel.fromMap(
        data['configuration'] ?? data,
      ),
      status: DayStatusModel.fromMap(data['status'] ?? {}),
      runPhases: phasesList,
      totals: totals,
      targetMetrics: DayTargetMetricsModel.fromMap(data['targetMetrics'] ?? {}),
      completionData: DayCompletionDataModel.fromMap(
        data['completionData'] ?? {},
      ),
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

  // Convert TrainingDayModel to Map (for local use, includes id if available)
  Map<String, dynamic> toMap() {
    final map = {
      'identification': identification.toMap(),
      'scheduling': scheduling.toMap(),
      'configuration': configuration.toMap(),
      'status': status.toMap(),
      'runPhases': runPhases.map((p) => p.toMap()).toList(),
      'totals': totals.toMap(),
      'targetMetrics': targetMetrics.toMap(),
      'completionData': completionData.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };

    // Only include id if it exists
    if (id != null) {
      map['id'] = id!;
    }

    return map;
  }

  // Convert TrainingDayModel to Firestore document (excludes id since Firebase assigns it)
  Map<String, dynamic> toFirestore() {
    return {
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

  // Mark training day as completed
  TrainingDayModel markAsCompleted({
    DateTime? completedAt,
    int? actualDuration,
    double? actualDistance,
  }) {
    return copyWith(
      status: status.copyWith(completed: true),
      completionData: completionData.copyWith(
        completedAt: completedAt ?? DateTime.now(),
        actualDuration: actualDuration,
        actualDistance: actualDistance,
      ),
      updatedAt: DateTime.now(),
    );
  }

  // Mark training day as skipped
  TrainingDayModel markAsSkipped() {
    return copyWith(
      status: status.copyWith(skipped: true),
      updatedAt: DateTime.now(),
    );
  }

  // Lock training day
  TrainingDayModel lock() {
    return copyWith(
      status: status.copyWith(locked: true),
      updatedAt: DateTime.now(),
    );
  }

  // Unlock training day
  TrainingDayModel unlock() {
    return copyWith(
      status: status.copyWith(locked: false),
      updatedAt: DateTime.now(),
    );
  }

  TrainingDayModel copyWith({
    String? id,
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
    return TrainingDayModel(
      id: id ?? this.id,
      identification: identification ?? this.identification,
      scheduling: scheduling ?? this.scheduling,
      configuration: configuration ?? this.configuration,
      status: status ?? this.status,
      runPhases: runPhases ?? this.runPhases,
      totals: totals ?? this.totals,
      targetMetrics: targetMetrics ?? this.targetMetrics,
      completionData: completionData ?? this.completionData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
