import 'package:flutter/material.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'rest_day_content.dart';
import 'workout_content.dart';
import 'target_metrics.dart';
import 'completion_data.dart';

class ModalContent extends StatelessWidget {
  final TrainingDayModel day;

  const ModalContent({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rest Day or Workout Details
        if (day.configuration.restDay)
          RestDayContent()
        else
          WorkoutContent(day: day),

        // Target Metrics (if not rest day)
        if (!day.configuration.restDay) ...[
          SizedBox(height: 16),
          TargetMetrics(day: day),
        ],

        // Completion Data (if completed)
        if (day.status.completed) ...[
          SizedBox(height: 16),
          CompletionData(day: day),
        ],
      ],
    );
  }
}
