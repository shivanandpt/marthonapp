class DayTargetMetricsModel {
  final double targetDistance; // in meters
  final int targetCalories;
  final double targetPace; // minutes per kilometer
  final double? expectedDistance;

  const DayTargetMetricsModel({
    required this.targetDistance,
    required this.targetCalories,
    required this.targetPace,
    this.expectedDistance,
  });

  factory DayTargetMetricsModel.fromMap(Map<String, dynamic> map) {
    return DayTargetMetricsModel(
      targetDistance: (map['targetDistance'] as num?)?.toDouble() ?? 0.0,
      targetCalories: (map['targetCalories'] as num?)?.toInt() ?? 0,
      targetPace: (map['targetPace'] as num?)?.toDouble() ?? 0.0,
      expectedDistance: (map['expectedDistance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetDistance': targetDistance,
      'targetCalories': targetCalories,
      'targetPace': targetPace,
      'expectedDistance': expectedDistance,
    };
  }

  // Helper getters for metric system
  String formattedDistance(String metricSystem) {
    if (metricSystem == 'imperial') {
      final miles = targetDistance * 0.000621371;
      if (miles >= 1.0) {
        return '${miles.toStringAsFixed(2)} mi';
      } else {
        final feet = targetDistance * 3.28084;
        return '${feet.toStringAsFixed(0)} ft';
      }
    } else {
      if (targetDistance >= 1000) {
        return '${(targetDistance / 1000).toStringAsFixed(2)} km';
      } else {
        return '${targetDistance.toStringAsFixed(0)} m';
      }
    }
  }

  String formattedExpectedDistance(String metricSystem) {
    final distance = expectedDistance ?? targetDistance;
    if (metricSystem == 'imperial') {
      final miles = distance * 0.000621371;
      if (miles >= 1.0) {
        return '${miles.toStringAsFixed(2)} mi';
      } else {
        final feet = distance * 3.28084;
        return '${feet.toStringAsFixed(0)} ft';
      }
    } else {
      if (distance >= 1000) {
        return '${(distance / 1000).toStringAsFixed(2)} km';
      } else {
        return '${distance.toStringAsFixed(0)} m';
      }
    }
  }

  String formattedPace(String metricSystem) {
    if (targetPace <= 0) return '0:00';

    if (metricSystem == 'imperial') {
      // Convert min/km to min/mile
      final minPerMile = targetPace * 1.60934;
      final minutes = minPerMile.floor();
      final seconds = ((minPerMile - minutes) * 60).round();
      return '$minutes:${seconds.toString().padLeft(2, '0')}/mi';
    } else {
      final minutes = targetPace.floor();
      final seconds = ((targetPace - minutes) * 60).round();
      return '$minutes:${seconds.toString().padLeft(2, '0')}/km';
    }
  }

  // Legacy formatters (kept for backwards compatibility)
  String get legacyFormattedDistance {
    if (targetDistance >= 1000) {
      return '${(targetDistance / 1000).toStringAsFixed(2)} km';
    } else {
      return '${targetDistance.toStringAsFixed(0)} m';
    }
  }

  String get legacyFormattedPace {
    final paceMinutes = targetPace.floor();
    final paceSeconds = ((targetPace - paceMinutes) * 60).round();
    return '$paceMinutes:${paceSeconds.toString().padLeft(2, '0')}/km';
  }

  DayTargetMetricsModel copyWith({
    double? targetDistance,
    int? targetCalories,
    double? targetPace,
    double? expectedDistance,
  }) {
    return DayTargetMetricsModel(
      targetDistance: targetDistance ?? this.targetDistance,
      targetCalories: targetCalories ?? this.targetCalories,
      targetPace: targetPace ?? this.targetPace,
      expectedDistance: expectedDistance ?? this.expectedDistance,
    );
  }
}
