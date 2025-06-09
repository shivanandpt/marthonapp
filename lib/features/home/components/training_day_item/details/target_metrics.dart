import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'package:marunthon_app/shared/utils/metric_conversion_utils.dart';
import 'metric_item.dart';

class TargetMetrics extends StatelessWidget {
  final TrainingDayModel day;
  final String metricSystem;

  const TargetMetrics({
    super.key,
    required this.day,
    this.metricSystem = 'metric',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Target Metrics",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MetricItem(
                  label: "Distance",
                  value: day.targetMetrics.formattedDistance(metricSystem),
                  icon: LucideIcons.mapPin,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: MetricItem(
                  label: "Duration",
                  value: MetricConversionUtils.formatDuration(
                    day.totals.totalDuration,
                    showSeconds: false,
                  ),
                  icon: LucideIcons.clock,
                ),
              ),
            ],
          ),
          if (day.targetMetrics.targetCalories > 0) ...[
            SizedBox(height: 8),
            MetricItem(
              label: "Calories",
              value: "${day.targetMetrics.targetCalories} cal",
              icon: LucideIcons.flame,
            ),
          ],
          if (day.targetMetrics.targetPace > 0) ...[
            SizedBox(height: 8),
            MetricItem(
              label: "Target Pace",
              value: day.targetMetrics.formattedPace(metricSystem),
              icon: LucideIcons.activity,
            ),
          ],
        ],
      ),
    );
  }
}
