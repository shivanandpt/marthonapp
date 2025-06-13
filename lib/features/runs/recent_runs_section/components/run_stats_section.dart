import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'stat_item.dart';

class RunStatsSection extends StatelessWidget {
  final RunModel run;

  const RunStatsSection({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    // Convert meters to kilometers with 2 decimal places
    final String distance = (run.totalDistance / 1000).toStringAsFixed(2);

    // Use the RunModel's formatted duration
    final String duration = run.formattedDuration;

    // Calculate pace
    final String pace = _formatPace(run);

    return Column(
      children: [
        // First row of stats
        Row(
          children: [
            // Distance
            Expanded(
              child: StatItem(
                icon: LucideIcons.mapPin,
                label: "Distance",
                value: "$distance km",
                color: AppColors.primary,
              ),
            ),
            // Duration
            Expanded(
              child: StatItem(
                icon: LucideIcons.clock,
                label: "Duration",
                value: duration,
                color: AppColors.secondary,
              ),
            ),
            // Steps
            Expanded(
              child: StatItem(
                icon: LucideIcons.footprints,
                label: "Steps",
                value: "${run.steps}",
                color: AppColors.accent,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Second row of stats
        Row(
          children: [
            // Pace
            Expanded(
              child: StatItem(
                icon: LucideIcons.timer,
                label: "Pace",
                value: pace,
                color: AppColors.primary,
              ),
            ),
            // Elevation
            Expanded(
              child: StatItem(
                icon: LucideIcons.trendingUp,
                label: "Elevation",
                value: "${run.elevationGain.toStringAsFixed(0)}m",
                color: AppColors.primary,
              ),
            ),
            // Speed
            Expanded(
              child: StatItem(
                icon: LucideIcons.zap,
                label: "Speed",
                value: "${(run.avgSpeed * 3.6).toStringAsFixed(1)} km/h",
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPace(RunModel run) {
    if (run.totalDistance == 0 || run.duration == 0) return "0:00";

    // Calculate pace in seconds per kilometer
    final double paceSecondsPerKm = (run.duration / (run.totalDistance / 1000));
    final int minutes = (paceSecondsPerKm / 60).floor();
    final int seconds = (paceSecondsPerKm % 60).round();

    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }
}
