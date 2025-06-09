import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'training_day_icon.dart';
import 'training_day_title.dart';
import 'training_day_subtitle.dart';
import 'training_day_trailing.dart';

class TrainingDayCard extends StatelessWidget {
  final TrainingDayModel day;
  final bool isToday;
  final VoidCallback onTap;

  const TrainingDayCard({
    super.key,
    required this.day,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = _getCardColor();

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      color: cardColor,
      child: ListTile(
        leading: TrainingDayIcon(day: day, isToday: isToday),
        title: TrainingDayTitle(day: day),
        subtitle: TrainingDaySubtitle(day: day),
        trailing: TrainingDayTrailing(day: day, isToday: isToday),
        onTap: onTap,
      ),
    );
  }

  Color _getCardColor() {
    if (day.status.completed) {
      return AppColors.success.withOpacity(0.1);
    } else if (day.status.skipped) {
      return AppColors.warning.withOpacity(0.1);
    } else if (isToday) {
      return AppColors.primary.withOpacity(0.1);
    } else {
      return AppColors.cardBg;
    }
  }
}
