import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/run_phase_model.dart';

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
    DateTime? parsedDate;

    // Handle dateScheduled field
    if (data['dateScheduled'] != null) {
      final dateField = data['dateScheduled'];

      if (dateField is String) {
        // Parse DD/MM/YYYY format
        try {
          final parts = dateField.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            parsedDate = DateTime(year, month, day);
          } else {
            print('Invalid date format: $dateField');
            parsedDate = null;
          }
        } catch (e) {
          print('Error parsing dateScheduled: $dateField, error: $e');
          parsedDate = null;
        }
      } else if (dateField is Timestamp) {
        // Handle Timestamp (for future compatibility)
        parsedDate = dateField.toDate();
      } else {
        print(
          'Unknown dateScheduled type: ${dateField.runtimeType}, value: $dateField',
        );
        parsedDate = null;
      }
    }

    return TrainingDayModel(
      id: id,
      planId: data['planId'] ?? '',
      week: (data['week'] as num?)?.toInt() ?? 1,
      dayOfWeek: (data['dayOfWeek'] as num?)?.toInt() ?? 1,
      dateScheduled: parsedDate,
      optional: data['optional'] ?? false,
      runPhases: data['runPhases'] ?? [],
    );
  }

  // Convert TrainingDayModel to Firestore document
  Map<String, dynamic> toFirestore() {
    String? dateString;
    if (dateScheduled != null) {
      // Format as DD/MM/YYYY to match your existing data format
      final day = dateScheduled!.day.toString().padLeft(2, '0');
      final month = dateScheduled!.month.toString().padLeft(2, '0');
      final year = dateScheduled!.year.toString();
      dateString = '$day/$month/$year';
    }

    return {
      'planId': planId,
      'week': week,
      'dayOfWeek': dayOfWeek,
      'dateScheduled': dateString,
      'optional': optional,
      'runPhases': runPhases,
    };
  }

  // Helper method to get formatted date string
  String? get formattedDate {
    if (dateScheduled == null) return null;
    final day = dateScheduled!.day.toString().padLeft(2, '0');
    final month = dateScheduled!.month.toString().padLeft(2, '0');
    final year = dateScheduled!.year.toString();
    return '$day/$month/$year';
  }

  // Add this helper method to TrainingDayModel
  List<RunPhaseModel> get parsedRunPhases {
    return runPhases
        .where((phase) => phase is Map<String, dynamic>)
        .map((phase) => RunPhaseModel.fromMap(phase as Map<String, dynamic>))
        .toList();
  }

  // Helper method to get total training duration
  int get totalDuration {
    return parsedRunPhases.fold(0, (sum, phase) => sum + phase.duration);
  }

  // Helper method to get formatted total duration
  String get formattedTotalDuration {
    final total = totalDuration;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '${minutes}m ${seconds}s';
  }

  // Create a copy of this TrainingDayModel with updated fields
  TrainingDayModel copyWith({
    String? id,
    String? planId,
    int? week,
    int? dayOfWeek,
    DateTime? dateScheduled,
    bool? optional,
    List<dynamic>? runPhases,
  }) {
    return TrainingDayModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      week: week ?? this.week,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dateScheduled: dateScheduled ?? this.dateScheduled,
      optional: optional ?? this.optional,
      runPhases: runPhases ?? this.runPhases,
    );
  }

  @override
  String toString() {
    return 'TrainingDayModel(id: $id, planId: $planId, week: $week, dayOfWeek: $dayOfWeek, dateScheduled: $dateScheduled, optional: $optional, runPhases: ${runPhases.length} phases)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrainingDayModel &&
        other.id == id &&
        other.planId == planId &&
        other.week == week &&
        other.dayOfWeek == dayOfWeek &&
        other.dateScheduled == dateScheduled &&
        other.optional == optional;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        planId.hashCode ^
        week.hashCode ^
        dayOfWeek.hashCode ^
        dateScheduled.hashCode ^
        optional.hashCode;
  }
}
