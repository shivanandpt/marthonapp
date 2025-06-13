import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';

class TrainingDayIcon extends StatelessWidget {
  final TrainingDayModel day;
  final bool isToday;

  const TrainingDayIcon({super.key, required this.day, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData();
    final iconColor = _getIconColor();

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor),
    );
  }

  IconData _getIconData() {
    if (day.status.completed) {
      return LucideIcons.checkCircle;
    } else if (day.status.skipped) {
      return LucideIcons.xCircle;
    } else if (day.status.locked) {
      return LucideIcons.lock;
    } else if (isToday) {
      return LucideIcons.calendar;
    } else {
      return LucideIcons.calendar;
    }
  }

  Color _getIconColor() {
    if (day.status.completed) {
      return AppColors.success;
    } else if (day.status.skipped) {
      return AppColors.warning;
    } else if (day.status.locked) {
      return AppColors.textSecondary;
    } else if (isToday) {
      return AppColors.primary;
    } else {
      return AppColors.secondary;
    }
  }
}
