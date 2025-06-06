import 'package:cloud_firestore/cloud_firestore.dart';

class DaySchedulingModel {
  final DateTime dateScheduled;
  final String timeSlot; // "morning", "afternoon", "evening"

  const DaySchedulingModel({
    required this.dateScheduled,
    required this.timeSlot,
  });

  factory DaySchedulingModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate = DateTime.now();

    // Handle dateScheduled field - support both string and Timestamp
    if (map['dateScheduled'] != null) {
      final dateField = map['dateScheduled'];

      if (dateField is String) {
        try {
          final parts = dateField.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            parsedDate = DateTime(year, month, day);
          }
        } catch (e) {
          print('Error parsing dateScheduled: $dateField, error: $e');
          parsedDate = DateTime.now();
        }
      } else if (dateField is Timestamp) {
        parsedDate = dateField.toDate();
      }
    }

    return DaySchedulingModel(
      dateScheduled: parsedDate,
      timeSlot: map['timeSlot'] ?? 'morning',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateScheduled': Timestamp.fromDate(dateScheduled),
      'timeSlot': timeSlot,
    };
  }

  // Helper getters
  String get formattedDate {
    final day = dateScheduled.day.toString().padLeft(2, '0');
    final month = dateScheduled.month.toString().padLeft(2, '0');
    final year = dateScheduled.year.toString();
    return '$day/$month/$year';
  }

  String get timeSlotDisplayName {
    switch (timeSlot.toLowerCase()) {
      case 'morning':
        return 'Morning';
      case 'afternoon':
        return 'Afternoon';
      case 'evening':
        return 'Evening';
      default:
        return timeSlot;
    }
  }

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(
      dateScheduled.year,
      dateScheduled.month,
      dateScheduled.day,
    );
    return today.isAtSameMomentAs(scheduledDate);
  }

  bool get isPast {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(
      dateScheduled.year,
      dateScheduled.month,
      dateScheduled.day,
    );
    return scheduledDate.isBefore(today);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledDate = DateTime(
      dateScheduled.year,
      dateScheduled.month,
      dateScheduled.day,
    );
    return scheduledDate.isAfter(today);
  }

  DaySchedulingModel copyWith({DateTime? dateScheduled, String? timeSlot}) {
    return DaySchedulingModel(
      dateScheduled: dateScheduled ?? this.dateScheduled,
      timeSlot: timeSlot ?? this.timeSlot,
    );
  }
}
