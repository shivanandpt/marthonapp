class PlanSettingsModel {
  final String difficulty; // "beginner", "intermediate", "advanced"
  final int restDaysBetweenRuns;
  final bool allowSkipDays;
  final int maxSkippedDays;

  const PlanSettingsModel({
    required this.difficulty,
    required this.restDaysBetweenRuns,
    required this.allowSkipDays,
    required this.maxSkippedDays,
  });

  factory PlanSettingsModel.fromMap(Map<String, dynamic> map) {
    return PlanSettingsModel(
      difficulty: map['difficulty'] ?? 'beginner',
      restDaysBetweenRuns: (map['restDaysBetweenRuns'] as num?)?.toInt() ?? 1,
      allowSkipDays: map['allowSkipDays'] ?? true,
      maxSkippedDays: (map['maxSkippedDays'] as num?)?.toInt() ?? 2,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'difficulty': difficulty,
      'restDaysBetweenRuns': restDaysBetweenRuns,
      'allowSkipDays': allowSkipDays,
      'maxSkippedDays': maxSkippedDays,
    };
  }

  // Helper getters
  String get difficultyDisplayName {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return 'Unknown';
    }
  }

  bool get isBeginnerFriendly => difficulty.toLowerCase() == 'beginner';

  PlanSettingsModel copyWith({
    String? difficulty,
    int? restDaysBetweenRuns,
    bool? allowSkipDays,
    int? maxSkippedDays,
  }) {
    return PlanSettingsModel(
      difficulty: difficulty ?? this.difficulty,
      restDaysBetweenRuns: restDaysBetweenRuns ?? this.restDaysBetweenRuns,
      allowSkipDays: allowSkipDays ?? this.allowSkipDays,
      maxSkippedDays: maxSkippedDays ?? this.maxSkippedDays,
    );
  }
}
