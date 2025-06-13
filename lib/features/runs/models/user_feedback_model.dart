class UserFeedbackModel {
  final int difficulty; // 1-5 scale
  final int enjoyment; // 1-5 scale
  final String notes;

  const UserFeedbackModel({
    required this.difficulty,
    required this.enjoyment,
    required this.notes,
  });

  factory UserFeedbackModel.fromMap(Map<String, dynamic> map) {
    return UserFeedbackModel(
      difficulty: (map['difficulty'] as num?)?.toInt() ?? 1,
      enjoyment: (map['enjoyment'] as num?)?.toInt() ?? 1,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'difficulty': difficulty, 'enjoyment': enjoyment, 'notes': notes};
  }
}
