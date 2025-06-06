import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'metric_item.dart';

class CompletionData extends StatelessWidget {
  final TrainingDayModel day;

  const CompletionData({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!day.completionData.hasCompletionData) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.checkCircle, color: AppColors.success),
              SizedBox(width: 8),
              Text(
                "Completed",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          if (day.completionData.completedAt != null) ...[
            SizedBox(height: 8),
            Text(
              "Completed at: ${DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a').format(day.completionData.completedAt!)}",
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
          if (day.completionData.actualDistance != null ||
              day.completionData.actualDuration != null) ...[
            SizedBox(height: 8),
            Row(
              children: [
                if (day.completionData.actualDistance != null)
                  Expanded(
                    child: MetricItem(
                      label: "Actual Distance",
                      value:
                          "${(day.completionData.actualDistance! / 1000).toStringAsFixed(1)} km",
                      icon: LucideIcons.mapPin,
                    ),
                  ),
                if (day.completionData.actualDistance != null &&
                    day.completionData.actualDuration != null)
                  SizedBox(width: 16),
                if (day.completionData.actualDuration != null)
                  Expanded(
                    child: MetricItem(
                      label: "Actual Duration",
                      value: "${day.completionData.actualDuration} min",
                      icon: LucideIcons.clock,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
