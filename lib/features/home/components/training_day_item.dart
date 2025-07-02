import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/utils/date_utils.dart';
import 'package:marunthon_app/features/runs/run_tracking_page.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'training_day_item/training_day_card.dart';
import 'training_day_item/training_day_details_modal.dart';

class TrainingDayItem extends StatelessWidget {
  final TrainingDayModel day;

  const TrainingDayItem({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    // Use the new model structure for date
    final dateScheduled = day.scheduling.dateScheduled;

    // Calculate if this is today
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(dateScheduled, now);

    return TrainingDayCard(
      day: day,
      isToday: isToday,
      onTap: () => _handleTap(context, isToday),
    );
  }

  void _handleTap(BuildContext context, bool isToday) {
    if (day.status.locked && !isToday) {
      _showLockedDayMessage(context);
    } else if (isToday && !day.status.completed && !day.configuration.restDay) {
      // Navigate to run tracking for today's workout
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RunTrackingPage()),
      );
    } else {
      // Show workout details
      TrainingDayDetailsModal.show(context, day);
    }
  }

  void _showLockedDayMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'This workout is locked. Complete previous workouts first.',
        ),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}
