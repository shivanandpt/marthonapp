class DayStatusModel {
  final bool completed;
  final bool skipped;
  final bool locked; // locked until previous days are completed

  const DayStatusModel({
    required this.completed,
    required this.skipped,
    required this.locked,
  });

  factory DayStatusModel.fromMap(Map<String, dynamic> map) {
    return DayStatusModel(
      completed: map['completed'] ?? false,
      skipped: map['skipped'] ?? false,
      locked: map['locked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'completed': completed, 'skipped': skipped, 'locked': locked};
  }

  // Helper getters
  String get statusText {
    if (completed) return 'Completed';
    if (skipped) return 'Skipped';
    if (locked) return 'Locked';
    return 'Available';
  }

  bool get isAvailable => !completed && !skipped && !locked;
  bool get isDone => completed || skipped;

  DayStatusModel copyWith({bool? completed, bool? skipped, bool? locked}) {
    return DayStatusModel(
      completed: completed ?? this.completed,
      skipped: skipped ?? this.skipped,
      locked: locked ?? this.locked,
    );
  }
}
