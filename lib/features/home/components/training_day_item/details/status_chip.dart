import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';

class StatusChip extends StatelessWidget {
  final TrainingDayModel day;

  const StatusChip({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusInfo.color.withOpacity(0.3)),
      ),
      child: Text(
        statusInfo.text,
        style: TextStyle(
          fontSize: 12,
          color: statusInfo.color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ({String text, Color color}) _getStatusInfo() {
    if (day.status.completed) {
      return (text: "Completed", color: AppColors.success);
    } else if (day.status.skipped) {
      return (text: "Skipped", color: AppColors.warning);
    } else if (day.status.locked) {
      return (text: "Locked", color: AppColors.textSecondary);
    } else {
      return (text: "Planned", color: AppColors.primary);
    }
  }
}
