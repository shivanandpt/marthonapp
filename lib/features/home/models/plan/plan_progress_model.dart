class PlanProgressModel {
  final bool isActive;
  final int currentWeek;
  final int currentDay;
  final int completedWeeks;
  final int completedSessions;

  const PlanProgressModel({
    required this.isActive,
    required this.currentWeek,
    required this.currentDay,
    required this.completedWeeks,
    required this.completedSessions,
  });

  factory PlanProgressModel.fromMap(Map<String, dynamic> map) {
    return PlanProgressModel(
      isActive: map['isActive'] ?? true,
      currentWeek: (map['currentWeek'] as num?)?.toInt() ?? 1,
      currentDay: (map['currentDay'] as num?)?.toInt() ?? 1,
      completedWeeks: (map['completedWeeks'] as num?)?.toInt() ?? 0,
      completedSessions: (map['completedSessions'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isActive': isActive,
      'currentWeek': currentWeek,
      'currentDay': currentDay,
      'completedWeeks': completedWeeks,
      'completedSessions': completedSessions,
    };
  }

  // Helper getters
  double get completionPercentage {
    if (completedSessions == 0) return 0.0;
    return (completedSessions / (completedWeeks * 3)).clamp(0.0, 1.0) * 100;
  }

  bool get isCompleted => !isActive && completedWeeks > 0;

  PlanProgressModel copyWith({
    bool? isActive,
    int? currentWeek,
    int? currentDay,
    int? completedWeeks,
    int? completedSessions,
  }) {
    return PlanProgressModel(
      isActive: isActive ?? this.isActive,
      currentWeek: currentWeek ?? this.currentWeek,
      currentDay: currentDay ?? this.currentDay,
      completedWeeks: completedWeeks ?? this.completedWeeks,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }
}
