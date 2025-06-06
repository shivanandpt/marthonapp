class DayIdentificationModel {
  final int week;
  final int dayOfWeek; // 1=Monday, 2=Tuesday, etc.
  final int dayNumber; // Sequential day number in the plan
  final String sessionType; // "interval", "long_run", "tempo", "recovery"

  const DayIdentificationModel({
    required this.week,
    required this.dayOfWeek,
    required this.dayNumber,
    required this.sessionType,
  });

  factory DayIdentificationModel.fromMap(Map<String, dynamic> map) {
    return DayIdentificationModel(
      week: (map['week'] as num?)?.toInt() ?? 1,
      dayOfWeek: (map['dayOfWeek'] as num?)?.toInt() ?? 1,
      dayNumber: (map['dayNumber'] as num?)?.toInt() ?? 1,
      sessionType: map['sessionType'] ?? 'recovery',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'week': week,
      'dayOfWeek': dayOfWeek,
      'dayNumber': dayNumber,
      'sessionType': sessionType,
    };
  }

  // Helper getters
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String get sessionTypeDisplayName {
    switch (sessionType.toLowerCase()) {
      case 'interval':
        return 'Interval Training';
      case 'long_run':
        return 'Long Run';
      case 'tempo':
        return 'Tempo Run';
      case 'recovery':
        return 'Recovery Run';
      default:
        return sessionType;
    }
  }

  DayIdentificationModel copyWith({
    int? week,
    int? dayOfWeek,
    int? dayNumber,
    String? sessionType,
  }) {
    return DayIdentificationModel(
      week: week ?? this.week,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayNumber: dayNumber ?? this.dayNumber,
      sessionType: sessionType ?? this.sessionType,
    );
  }
}
