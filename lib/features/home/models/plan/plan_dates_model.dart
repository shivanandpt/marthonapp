import 'package:cloud_firestore/cloud_firestore.dart';

class PlanDatesModel {
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualEndDate;

  const PlanDatesModel({
    required this.startDate,
    required this.estimatedEndDate,
    this.actualEndDate,
  });

  factory PlanDatesModel.fromMap(Map<String, dynamic> map) {
    return PlanDatesModel(
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedEndDate:
          (map['estimatedEndDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(Duration(days: 84)), // 12 weeks default
      actualEndDate: (map['actualEndDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': Timestamp.fromDate(startDate),
      'estimatedEndDate': Timestamp.fromDate(estimatedEndDate),
      if (actualEndDate != null)
        'actualEndDate': Timestamp.fromDate(actualEndDate!),
    };
  }

  // Helper getters
  Duration get totalDuration => estimatedEndDate.difference(startDate);

  Duration get remainingDuration {
    final now = DateTime.now();
    if (now.isAfter(estimatedEndDate)) return Duration.zero;
    return estimatedEndDate.difference(now);
  }

  bool get isOverdue {
    if (actualEndDate != null) return false;
    return DateTime.now().isAfter(estimatedEndDate);
  }

  int get daysRemaining => remainingDuration.inDays;

  int get weeksRemaining => (daysRemaining / 7).ceil();

  PlanDatesModel copyWith({
    DateTime? startDate,
    DateTime? estimatedEndDate,
    DateTime? actualEndDate,
  }) {
    return PlanDatesModel(
      startDate: startDate ?? this.startDate,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
    );
  }
}
