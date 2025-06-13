class PlanStructureModel {
  final int weeks;
  final int runDaysPerWeek;
  final int totalSessions; // weeks * runDaysPerWeek

  const PlanStructureModel({
    required this.weeks,
    required this.runDaysPerWeek,
    required this.totalSessions,
  });

  factory PlanStructureModel.fromMap(Map<String, dynamic> map) {
    final weeks = (map['weeks'] as num?)?.toInt() ?? 12;
    final runDaysPerWeek = (map['runDaysPerWeek'] as num?)?.toInt() ?? 3;

    return PlanStructureModel(
      weeks: weeks,
      runDaysPerWeek: runDaysPerWeek,
      totalSessions: map['totalSessions'] as int? ?? (weeks * runDaysPerWeek),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weeks': weeks,
      'runDaysPerWeek': runDaysPerWeek,
      'totalSessions': totalSessions,
    };
  }

  PlanStructureModel copyWith({
    int? weeks,
    int? runDaysPerWeek,
    int? totalSessions,
  }) {
    return PlanStructureModel(
      weeks: weeks ?? this.weeks,
      runDaysPerWeek: runDaysPerWeek ?? this.runDaysPerWeek,
      totalSessions: totalSessions ?? this.totalSessions,
    );
  }
}
