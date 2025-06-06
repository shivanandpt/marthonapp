import 'package:equatable/equatable.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';

enum RunStatus { stopped, running, paused, completed }

abstract class RunTrackingState extends Equatable {
  const RunTrackingState();

  @override
  List<Object?> get props => [];
}

class RunTrackingInitial extends RunTrackingState {}

class RunTrackingActive extends RunTrackingState {
  final List<RunPhaseModel> phases;
  final int currentPhaseIndex;
  final RunStatus status;
  final Duration elapsedTime;
  final Duration phaseElapsedTime;
  final double totalDistance;
  final double currentSpeed;
  final double currentElevation;
  final List<Map<String, dynamic>> routePoints;
  final DateTime? startTime;
  final DateTime? lastPauseTime;
  final Duration totalPausedDuration;

  const RunTrackingActive({
    required this.phases,
    required this.currentPhaseIndex,
    required this.status,
    required this.elapsedTime,
    required this.phaseElapsedTime,
    required this.totalDistance,
    required this.currentSpeed,
    required this.currentElevation,
    required this.routePoints,
    this.startTime,
    this.lastPauseTime,
    required this.totalPausedDuration,
  });

  RunPhaseModel get currentPhase => phases[currentPhaseIndex];
  bool get hasNextPhase => currentPhaseIndex < phases.length - 1;
  bool get hasPreviousPhase => currentPhaseIndex > 0;
  bool get isLastPhase => currentPhaseIndex == phases.length - 1;

  @override
  List<Object?> get props => [
    phases,
    currentPhaseIndex,
    status,
    elapsedTime,
    phaseElapsedTime,
    totalDistance,
    currentSpeed,
    currentElevation,
    routePoints,
    startTime,
    lastPauseTime,
    totalPausedDuration,
  ];

  RunTrackingActive copyWith({
    List<RunPhaseModel>? phases,
    int? currentPhaseIndex,
    RunStatus? status,
    Duration? elapsedTime,
    Duration? phaseElapsedTime,
    double? totalDistance,
    double? currentSpeed,
    double? currentElevation,
    List<Map<String, dynamic>>? routePoints,
    DateTime? startTime,
    DateTime? lastPauseTime,
    Duration? totalPausedDuration,
  }) {
    return RunTrackingActive(
      phases: phases ?? this.phases,
      currentPhaseIndex: currentPhaseIndex ?? this.currentPhaseIndex,
      status: status ?? this.status,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      phaseElapsedTime: phaseElapsedTime ?? this.phaseElapsedTime,
      totalDistance: totalDistance ?? this.totalDistance,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      currentElevation: currentElevation ?? this.currentElevation,
      routePoints: routePoints ?? this.routePoints,
      startTime: startTime ?? this.startTime,
      lastPauseTime: lastPauseTime ?? this.lastPauseTime,
      totalPausedDuration: totalPausedDuration ?? this.totalPausedDuration,
    );
  }
}

class RunTrackingCompleted extends RunTrackingState {
  final Duration totalTime;
  final double totalDistance;
  final List<Map<String, dynamic>> routePoints;
  final List<RunPhaseModel> completedPhases;

  const RunTrackingCompleted({
    required this.totalTime,
    required this.totalDistance,
    required this.routePoints,
    required this.completedPhases,
  });

  @override
  List<Object?> get props => [
    totalTime,
    totalDistance,
    routePoints,
    completedPhases,
  ];
}
