enum RunPhaseType { warmup, easyRun, intervals, recovery, cooldown, freeRun }

class RunPhaseModel {
  final String id;
  final RunPhaseType type;
  final String name;
  final Duration targetDuration;
  final double? targetDistance;
  final String? targetPace;
  final String description;
  final String instructions;

  const RunPhaseModel({
    required this.id,
    required this.type,
    required this.name,
    required this.targetDuration,
    this.targetDistance,
    this.targetPace,
    required this.description,
    required this.instructions,
  });

  factory RunPhaseModel.fromMap(Map<String, dynamic> map) {
    return RunPhaseModel(
      id: map['id'] ?? '',
      type: RunPhaseType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => RunPhaseType.freeRun,
      ),
      name: map['name'] ?? '',
      targetDuration: Duration(seconds: map['targetDuration'] ?? 0),
      targetDistance: map['targetDistance']?.toDouble(),
      targetPace: map['targetPace'],
      description: map['description'] ?? '',
      instructions: map['instructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'name': name,
      'targetDuration': targetDuration.inSeconds,
      'targetDistance': targetDistance,
      'targetPace': targetPace,
      'description': description,
      'instructions': instructions,
    };
  }
}
