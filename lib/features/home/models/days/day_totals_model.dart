import 'training_phase_model.dart';

class DayTotalsModel {
  final int totalDuration; // Sum of all phases in seconds
  final int totalRunTime; // Sum of only run phases
  final int totalWalkTime; // Sum of walk + warmup + cooldown
  final double runWalkRatio; // run time / walk time

  const DayTotalsModel({
    required this.totalDuration,
    required this.totalRunTime,
    required this.totalWalkTime,
    required this.runWalkRatio,
  });

  factory DayTotalsModel.fromPhases(List<TrainingPhaseModel> phases) {
    int totalDuration = 0;
    int totalRunTime = 0;
    int totalWalkTime = 0;

    for (var phase in phases) {
      totalDuration += phase.duration;
      if (phase.isRunPhase) {
        totalRunTime += phase.duration;
      } else if (phase.isWalkPhase) {
        totalWalkTime += phase.duration;
      }
    }

    double ratio = totalWalkTime > 0 ? totalRunTime / totalWalkTime : 0.0;

    return DayTotalsModel(
      totalDuration: totalDuration,
      totalRunTime: totalRunTime,
      totalWalkTime: totalWalkTime,
      runWalkRatio: ratio,
    );
  }

  factory DayTotalsModel.fromMap(Map<String, dynamic> map) {
    return DayTotalsModel(
      totalDuration: (map['totalDuration'] as num?)?.toInt() ?? 0,
      totalRunTime: (map['totalRunTime'] as num?)?.toInt() ?? 0,
      totalWalkTime: (map['totalWalkTime'] as num?)?.toInt() ?? 0,
      runWalkRatio: (map['runWalkRatio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalDuration': totalDuration,
      'totalRunTime': totalRunTime,
      'totalWalkTime': totalWalkTime,
      'runWalkRatio': runWalkRatio,
    };
  }

  // Helper getters with metric system support
  String formattedTotalDurationWithOptions({bool showSeconds = true}) {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final seconds = totalDuration % 60;

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

  String formattedRunTimeWithOptions({bool showSeconds = true}) {
    final minutes = totalRunTime ~/ 60;
    final seconds = totalRunTime % 60;
    return showSeconds ? '${minutes}m ${seconds}s' : '${minutes}m';
  }

  String formattedWalkTimeWithOptions({bool showSeconds = true}) {
    final minutes = totalWalkTime ~/ 60;
    final seconds = totalWalkTime % 60;
    return showSeconds ? '${minutes}m ${seconds}s' : '${minutes}m';
  }

  // Default getters (backwards compatibility)
  String get formattedTotalDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final seconds = totalDuration % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get formattedRunTime {
    final minutes = totalRunTime ~/ 60;
    final seconds = totalRunTime % 60;
    return '${minutes}m ${seconds}s';
  }

  String get formattedWalkTime {
    final minutes = totalWalkTime ~/ 60;
    final seconds = totalWalkTime % 60;
    return '${minutes}m ${seconds}s';
  }

  String get formattedRatio {
    return '${runWalkRatio.toStringAsFixed(1)}:1';
  }

  DayTotalsModel copyWith({
    int? totalDuration,
    int? totalRunTime,
    int? totalWalkTime,
    double? runWalkRatio,
  }) {
    return DayTotalsModel(
      totalDuration: totalDuration ?? this.totalDuration,
      totalRunTime: totalRunTime ?? this.totalRunTime,
      totalWalkTime: totalWalkTime ?? this.totalWalkTime,
      runWalkRatio: runWalkRatio ?? this.runWalkRatio,
    );
  }
}
