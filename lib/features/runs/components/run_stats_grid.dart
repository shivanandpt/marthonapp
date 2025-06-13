// lib/features/runs/components/run_stats_grid.dart
import 'package:flutter/material.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'stat_box.dart';

class RunStatsGrid extends StatelessWidget {
  final RunModel run;

  const RunStatsGrid({super.key, required this.run});

  // Calculate calories burned (using your actual data)
  double get caloriesBurned {
    // More accurate calculation using steps and duration
    // Basic formula: steps * 0.04 calories per step for running
    return run.steps * 0.04;
  }

  // Use the actual elevation gain from the data
  double get elevationGained {
    return run.elevationGain;
  }

  // Format pace using totalDistance
  String get averagePace {
    if (run.totalDistance == 0 || run.duration == 0) return "0:00";

    final double paceSecondsPerKm = (run.duration / (run.totalDistance / 1000));
    final int minutes = (paceSecondsPerKm / 60).floor();
    final int seconds = (paceSecondsPerKm % 60).round();

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  // Convert avgSpeed from m/s to km/h
  String get averageSpeedKmh {
    final double speedKmh = run.avgSpeed * 3.6;
    return speedKmh.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Row 1: Distance and Duration
          Row(
            children: [
              Expanded(
                child: StatBox(
                  icon: LucideIcons.mapPin,
                  label: "Distance",
                  value: (run.totalDistance / 1000).toStringAsFixed(2),
                  unit: "km",
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  icon: LucideIcons.clock,
                  label: "Duration",
                  value: run.formattedDuration,
                  unit: "",
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Row 2: Speed and Pace
          Row(
            children: [
              Expanded(
                child: StatBox(
                  icon: LucideIcons.zap,
                  label: "Avg Speed",
                  value: averageSpeedKmh,
                  unit: "km/h",
                  color: AppColors.accent,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  icon: LucideIcons.timer,
                  label: "Avg Pace",
                  value: averagePace,
                  unit: "min/km",
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Row 3: Elevation and Steps
          Row(
            children: [
              Expanded(
                child: StatBox(
                  icon: LucideIcons.trendingUp,
                  label: "Elevation Gained",
                  value: elevationGained.toStringAsFixed(0),
                  unit: "m",
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  icon: LucideIcons.footprints,
                  label: "Steps",
                  value: run.steps.toString(),
                  unit: "",
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Row 4: Calories and Training Day (if available)
          Row(
            children: [
              Expanded(
                child: StatBox(
                  icon: LucideIcons.flame,
                  label: "Calories",
                  value: caloriesBurned.toStringAsFixed(0),
                  unit: "kcal",
                  color: AppColors.error,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  icon:
                      run.trainingDayId != null
                          ? LucideIcons.target
                          : LucideIcons.activity,
                  label:
                      run.trainingDayId != null ? "Training Run" : "Free Run",
                  value: run.trainingDayId != null ? "Yes" : "No",
                  unit: "",
                  color:
                      run.trainingDayId != null
                          ? AppColors.primary
                          : AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
