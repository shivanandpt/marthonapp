import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/models/training_plan_model.dart';

class TrainingPlanCard extends StatelessWidget {
  final TrainingPlanModel activePlan;
  final int daysCompleted;
  final int totalDays;
  final int currentWeek;
  final int totalWeeks;

  const TrainingPlanCard({
    Key? key,
    required this.activePlan,
    required this.daysCompleted,
    required this.totalDays,
    required this.currentWeek,
    required this.totalWeeks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate progress percentage
    double progress = totalDays > 0 ? daysCompleted / totalDays : 0;

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Training Plan",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Week $currentWeek of $totalWeeks",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              activePlan.goalType,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: AppColors.primary,
              minHeight: 8,
            ),
            SizedBox(height: 8),

            // Progress stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$daysCompleted days completed",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "${(totalDays - daysCompleted)} days remaining",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
