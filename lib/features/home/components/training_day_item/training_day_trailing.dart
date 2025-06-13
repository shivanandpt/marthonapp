import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';

class TrainingDayTrailing extends StatelessWidget {
  final TrainingDayModel day;
  final bool isToday;

  const TrainingDayTrailing({
    super.key,
    required this.day,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    if (day.status.completed) {
      return Icon(LucideIcons.check, color: AppColors.success);
    } else if (day.status.skipped) {
      return Icon(LucideIcons.x, color: AppColors.warning);
    } else if (day.status.locked) {
      return Icon(LucideIcons.lock, color: AppColors.textSecondary);
    } else if (isToday) {
      return Icon(LucideIcons.chevronRight, color: AppColors.primary);
    }
    return const SizedBox.shrink(); // Return an empty widget instead of null
  }
}
