import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';

class TrainingDaySubtitle extends StatelessWidget {
  final TrainingDayModel day;

  const TrainingDaySubtitle({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateScheduled = day.scheduling.dateScheduled;
    final date = DateFormat('EEEE, MMM dd').format(dateScheduled);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(date),
        if (!day.configuration.restDay &&
            day.identification.sessionType.isNotEmpty)
          Text(
            day.identification.sessionType,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
