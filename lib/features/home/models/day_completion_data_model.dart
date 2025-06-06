import 'package:cloud_firestore/cloud_firestore.dart';

class DayCompletionDataModel {
  final DateTime? completedAt;
  final int? actualDuration; // in seconds
  final double? actualDistance; // in meters

  const DayCompletionDataModel({
    this.completedAt,
    this.actualDuration,
    this.actualDistance,
  });

  factory DayCompletionDataModel.fromMap(Map<String, dynamic> map) {
    return DayCompletionDataModel(
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      actualDuration: (map['actualDuration'] as num?)?.toInt(),
      actualDistance: (map['actualDistance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (actualDuration != null) 'actualDuration': actualDuration,
      if (actualDistance != null) 'actualDistance': actualDistance,
    };
  }

  // Helper getters
  bool get hasCompletionData => completedAt != null;

  String? get formattedCompletedAt {
    if (completedAt == null) return null;
    final day = completedAt!.day.toString().padLeft(2, '0');
    final month = completedAt!.month.toString().padLeft(2, '0');
    final year = completedAt!.year.toString();
    return '$day/$month/$year';
  }

  String? get formattedActualDuration {
    if (actualDuration == null) return null;
    final hours = actualDuration! ~/ 3600;
    final minutes = (actualDuration! % 3600) ~/ 60;
    final seconds = actualDuration! % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String? get formattedActualDistance {
    if (actualDistance == null) return null;
    if (actualDistance! >= 1000) {
      return '${(actualDistance! / 1000).toStringAsFixed(2)} km';
    } else {
      return '${actualDistance!.toStringAsFixed(0)} m';
    }
  }

  DayCompletionDataModel copyWith({
    DateTime? completedAt,
    int? actualDuration,
    double? actualDistance,
  }) {
    return DayCompletionDataModel(
      completedAt: completedAt ?? this.completedAt,
      actualDuration: actualDuration ?? this.actualDuration,
      actualDistance: actualDistance ?? this.actualDistance,
    );
  }
}
