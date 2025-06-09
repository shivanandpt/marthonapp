import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/components/training_day_item.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';

class UpcomingTrainingSection extends StatelessWidget {
  final List<TrainingDayModel> upcomingDays;
  final TrainingDayModel? todaysTraining;

  const UpcomingTrainingSection({
    Key? key,
    required this.upcomingDays,
    this.todaysTraining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 24, bottom: 8),
          child: Text(
            "Upcoming Training",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...List.generate(upcomingDays.length, (index) {
          final day = upcomingDays[index];
          if (day.dateScheduled == null) return SizedBox.shrink();

          // Skip today's training if we already showed it
          if (todaysTraining != null && day.id == todaysTraining!.id)
            return SizedBox.shrink();

          return TrainingDayItem(day: day);
        }),
      ],
    );
  }
}
