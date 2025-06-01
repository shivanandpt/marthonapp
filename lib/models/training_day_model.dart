import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingDayModel {
  final String id;
  final String planId;
  final int week;
  final int dayOfWeek;
  final DateTime? dateScheduled;
  final bool optional;
  final List<dynamic> runPhases;

  TrainingDayModel({
    required this.id,
    required this.planId,
    required this.week,
    required this.dayOfWeek,
    this.dateScheduled,
    required this.optional,
    required this.runPhases,
  });

  // Convert Firestore document to TrainingDayModel
  factory TrainingDayModel.fromFirestore(Map<String, dynamic> data, String id) {
    return TrainingDayModel(
      id: id,
      planId: data['planId'] ?? '',
      week: data['week'] ?? 1,
      dayOfWeek: data['dayOfWeek'] ?? 1,
      dateScheduled:
          data['dateScheduled'] != null
              ? (data['dateScheduled'] as Timestamp).toDate()
              : null,
      optional: data['optional'] ?? false,
      runPhases: data['runPhases'] ?? [],
    );
  }

  // Convert TrainingDayModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'week': week,
      'dayOfWeek': dayOfWeek,
      'dateScheduled': dateScheduled,
      'optional': optional,
      'runPhases': runPhases,
    };
  }

  // Create a copy of this TrainingDayModel with updated fields
  TrainingDayModel copyWith({
    String? planId,
    int? week,
    int? dayOfWeek,
    DateTime? dateScheduled,
    bool? optional,
    List<dynamic>? runPhases,
  }) {
    return TrainingDayModel(
      id: this.id,
      planId: planId ?? this.planId,
      week: week ?? this.week,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dateScheduled: dateScheduled ?? this.dateScheduled,
      optional: optional ?? this.optional,
      runPhases: runPhases ?? this.runPhases,
    );
  }
}
