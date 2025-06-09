import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'training_day_badges.dart';

class TrainingDayTitle extends StatelessWidget {
  final TrainingDayModel day;

  const TrainingDayTitle({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Week ${day.identification.week}, Day ${day.identification.dayOfWeek}",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TrainingDayBadges(day: day),
      ],
    );
  }
}
