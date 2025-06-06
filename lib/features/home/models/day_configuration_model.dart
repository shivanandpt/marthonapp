class DayConfigurationModel {
  final bool optional;
  final bool restDay;
  final String difficulty; // "easy", "moderate", "hard"

  const DayConfigurationModel({
    required this.optional,
    required this.restDay,
    required this.difficulty,
  });

  factory DayConfigurationModel.fromMap(Map<String, dynamic> map) {
    return DayConfigurationModel(
      optional: map['optional'] ?? false,
      restDay: map['restDay'] ?? false,
      difficulty: map['difficulty'] ?? 'easy',
    );
  }

  Map<String, dynamic> toMap() {
    return {'optional': optional, 'restDay': restDay, 'difficulty': difficulty};
  }

  // Helper getters
  String get difficultyDisplayName {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'moderate':
        return 'Moderate';
      case 'hard':
        return 'Hard';
      default:
        return difficulty;
    }
  }

  bool get isWorkoutDay => !restDay;

  DayConfigurationModel copyWith({
    bool? optional,
    bool? restDay,
    String? difficulty,
  }) {
    return DayConfigurationModel(
      optional: optional ?? this.optional,
      restDay: restDay ?? this.restDay,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
