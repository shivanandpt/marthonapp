class DayTargetMetricsModel {
  final double targetDistance; // in meters
  final int targetCalories;
  final double targetPace; // minutes per kilometer

  const DayTargetMetricsModel({
    required this.targetDistance,
    required this.targetCalories,
    required this.targetPace,
  });

  factory DayTargetMetricsModel.fromMap(Map<String, dynamic> map) {
    return DayTargetMetricsModel(
      targetDistance: (map['targetDistance'] as num?)?.toDouble() ?? 0.0,
      targetCalories: (map['targetCalories'] as num?)?.toInt() ?? 0,
      targetPace: (map['targetPace'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetDistance': targetDistance,
      'targetCalories': targetCalories,
      'targetPace': targetPace,
    };
  }

  // Helper getters
  String get formattedDistance {
    if (targetDistance >= 1000) {
      return '${(targetDistance / 1000).toStringAsFixed(2)} km';
    } else {
      return '${targetDistance.toStringAsFixed(0)} m';
    }
  }

  String get formattedPace {
    final paceMinutes = targetPace.floor();
    final paceSeconds = ((targetPace - paceMinutes) * 60).round();
    return '${paceMinutes}:${paceSeconds.toString().padLeft(2, '0')}/km';
  }

  DayTargetMetricsModel copyWith({
    double? targetDistance,
    int? targetCalories,
    double? targetPace,
  }) {
    return DayTargetMetricsModel(
      targetDistance: targetDistance ?? this.targetDistance,
      targetCalories: targetCalories ?? this.targetCalories,
      targetPace: targetPace ?? this.targetPace,
    );
  }
}
