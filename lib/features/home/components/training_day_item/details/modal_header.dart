import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'status_chip.dart';

class ModalHeader extends StatelessWidget {
  final TrainingDayModel day;

  const ModalHeader({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Training Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            StatusChip(day: day),
          ],
        ),
        SizedBox(height: 8),
        Text(
          "Week ${day.identification.week}, Day ${day.identification.dayOfWeek}",
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        Text(
          DateFormat('EEEE, MMMM d').format(day.scheduling.dateScheduled),
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        if (day.identification.sessionType.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              "Session Type: ${day.identification.sessionType}",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
