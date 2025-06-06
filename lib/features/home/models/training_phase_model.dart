class TrainingPhaseModel {
  final String phase; // "warmup", "run", "walk", "cooldown"
  final int duration; // in seconds
  final String instruction;
  final String targetPace; // "slow", "moderate", "fast"
  final String voicePrompt;

  const TrainingPhaseModel({
    required this.phase,
    required this.duration,
    required this.instruction,
    required this.targetPace,
    required this.voicePrompt,
  });

  factory TrainingPhaseModel.fromMap(Map<String, dynamic> map) {
    return TrainingPhaseModel(
      phase: map['phase'] ?? 'run',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      instruction: map['instruction'] ?? '',
      targetPace: map['targetPace'] ?? 'moderate',
      voicePrompt: map['voicePrompt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phase': phase,
      'duration': duration,
      'instruction': instruction,
      'targetPace': targetPace,
      'voicePrompt': voicePrompt,
    };
  }

  // Helper getters
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get phaseDisplayName {
    switch (phase.toLowerCase()) {
      case 'warmup':
        return 'Warm Up';
      case 'run':
        return 'Run';
      case 'walk':
        return 'Walk';
      case 'cooldown':
        return 'Cool Down';
      default:
        return phase;
    }
  }

  String get targetPaceDisplayName {
    switch (targetPace.toLowerCase()) {
      case 'slow':
        return 'Slow';
      case 'moderate':
        return 'Moderate';
      case 'fast':
        return 'Fast';
      default:
        return targetPace;
    }
  }

  bool get isRunPhase => phase.toLowerCase() == 'run';
  bool get isWalkPhase =>
      phase.toLowerCase() == 'walk' ||
      phase.toLowerCase() == 'warmup' ||
      phase.toLowerCase() == 'cooldown';

  TrainingPhaseModel copyWith({
    String? phase,
    int? duration,
    String? instruction,
    String? targetPace,
    String? voicePrompt,
  }) {
    return TrainingPhaseModel(
      phase: phase ?? this.phase,
      duration: duration ?? this.duration,
      instruction: instruction ?? this.instruction,
      targetPace: targetPace ?? this.targetPace,
      voicePrompt: voicePrompt ?? this.voicePrompt,
    );
  }
}
