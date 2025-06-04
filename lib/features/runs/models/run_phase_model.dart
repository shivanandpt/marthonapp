// lib/models/run_phase_model.dart
class RunPhaseModel {
  final String phase;
  final int duration; // in seconds

  RunPhaseModel({
    required this.phase,
    required this.duration,
  });

  factory RunPhaseModel.fromMap(Map<String, dynamic> map) {
    return RunPhaseModel(
      phase: map['phase'] ?? '',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phase': phase,
      'duration': duration,
    };
  }

  // Helper method to format duration
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  String toString() {
    return 'RunPhaseModel(phase: $phase, duration: ${formattedDuration})';
  }
}