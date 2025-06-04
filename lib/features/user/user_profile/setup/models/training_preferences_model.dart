import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingPreferencesModel {
  final String injuryNotes;
  final String goal; // "5K", "10K", "half-marathon", "marathon"
  final DateTime? goalEventDate;
  final int runDaysPerWeek; // max 3
  final String experience; // "beginner", "intermediate", "advanced"

  const TrainingPreferencesModel({
    this.injuryNotes = '',
    this.goal = '5K',
    this.goalEventDate,
    this.runDaysPerWeek = 3,
    this.experience = 'beginner',
  });

  factory TrainingPreferencesModel.fromMap(Map<String, dynamic> data) {
    return TrainingPreferencesModel(
      injuryNotes: data['injuryNotes'] ?? '',
      goal: data['goal'] ?? '5K',
      goalEventDate:
          data['goalEventDate'] != null
              ? (data['goalEventDate'] as Timestamp).toDate()
              : null,
      runDaysPerWeek: data['runDaysPerWeek'] ?? 3,
      experience: data['experience'] ?? 'beginner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'injuryNotes': injuryNotes,
      'goal': goal,
      'goalEventDate': goalEventDate,
      'runDaysPerWeek': runDaysPerWeek,
      'experience': experience,
    };
  }

  TrainingPreferencesModel copyWith({
    String? injuryNotes,
    String? goal,
    DateTime? goalEventDate,
    int? runDaysPerWeek,
    String? experience,
  }) {
    return TrainingPreferencesModel(
      injuryNotes: injuryNotes ?? this.injuryNotes,
      goal: goal ?? this.goal,
      goalEventDate: goalEventDate ?? this.goalEventDate,
      runDaysPerWeek: runDaysPerWeek ?? this.runDaysPerWeek,
      experience: experience ?? this.experience,
    );
  }
}
