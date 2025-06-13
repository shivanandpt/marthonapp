class PlanStatisticsModel {
  final double totalPlannedDistance; // in meters
  final int totalPlannedDuration; // in seconds
  final int averageSessionDuration; // in seconds

  const PlanStatisticsModel({
    required this.totalPlannedDistance,
    required this.totalPlannedDuration,
    required this.averageSessionDuration,
  });

  factory PlanStatisticsModel.fromMap(Map<String, dynamic> map) {
    return PlanStatisticsModel(
      totalPlannedDistance:
          (map['totalPlannedDistance'] as num?)?.toDouble() ?? 0.0,
      totalPlannedDuration: (map['totalPlannedDuration'] as num?)?.toInt() ?? 0,
      averageSessionDuration:
          (map['averageSessionDuration'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPlannedDistance': totalPlannedDistance,
      'totalPlannedDuration': totalPlannedDuration,
      'averageSessionDuration': averageSessionDuration,
    };
  }

  // Helper getters with metric system support
  String formattedTotalDistanceForMetric(String metricSystem) {
    if (metricSystem == 'imperial') {
      final miles = totalPlannedDistance * 0.000621371;
      if (miles >= 1.0) {
        return '${miles.toStringAsFixed(1)} mi';
      } else {
        final feet = totalPlannedDistance * 3.28084;
        return '${feet.toStringAsFixed(0)} ft';
      }
    } else {
      if (totalPlannedDistance >= 1000) {
        return '${(totalPlannedDistance / 1000).toStringAsFixed(1)} km';
      } else {
        return '${totalPlannedDistance.toStringAsFixed(0)} m';
      }
    }
  }

  String formattedTotalDurationWithOptions({bool showSeconds = false}) {
    final hours = totalPlannedDuration ~/ 3600;
    final minutes = (totalPlannedDuration % 3600) ~/ 60;
    final seconds = totalPlannedDuration % 60;

    if (hours > 0) {
      return showSeconds
          ? '${hours}h ${minutes}m ${seconds}s'
          : '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return showSeconds ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  String formattedAverageSessionDurationWithOptions({bool showSeconds = true}) {
    final minutes = averageSessionDuration ~/ 60;
    final seconds = averageSessionDuration % 60;

    if (minutes > 0) {
      return showSeconds ? '${minutes}m ${seconds}s' : '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

  // Legacy getters (backwards compatibility)
  String get formattedTotalDistance {
    if (totalPlannedDistance >= 1000) {
      return '${(totalPlannedDistance / 1000).toStringAsFixed(1)} km';
    } else {
      return '${totalPlannedDistance.toStringAsFixed(0)} m';
    }
  }

  String get formattedTotalDuration {
    final hours = totalPlannedDuration ~/ 3600;
    final minutes = (totalPlannedDuration % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String get formattedAverageSessionDuration {
    final minutes = averageSessionDuration ~/ 60;
    final seconds = averageSessionDuration % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  PlanStatisticsModel copyWith({
    double? totalPlannedDistance,
    int? totalPlannedDuration,
    int? averageSessionDuration,
  }) {
    return PlanStatisticsModel(
      totalPlannedDistance: totalPlannedDistance ?? this.totalPlannedDistance,
      totalPlannedDuration: totalPlannedDuration ?? this.totalPlannedDuration,
      averageSessionDuration:
          averageSessionDuration ?? this.averageSessionDuration,
    );
  }
}
