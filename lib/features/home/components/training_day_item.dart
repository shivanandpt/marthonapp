import 'package:flutter/material.dart' hide DateUtils;
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/utils/date_utils.dart';
import 'package:marunthon_app/features/home/utils/workout_phase_icons.dart';
import 'package:marunthon_app/features/log_run/run_tracking_pag.dart';
import 'package:marunthon_app/models/training_day_model.dart';

class TrainingDayItem extends StatelessWidget {
  final TrainingDayModel day;

  const TrainingDayItem({Key? key, required this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date =
        day.dateScheduled != null
            ? DateFormat('EEEE, MMM dd').format(day.dateScheduled!)
            : "Unscheduled";

    // Calculate if this is today
    bool isToday = false;
    if (day.dateScheduled != null) {
      final now = DateTime.now();
      isToday = DateUtils.isSameDay(day.dateScheduled!, now);
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      color: isToday ? AppColors.primary.withOpacity(0.1) : AppColors.cardBg,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isToday
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.secondary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.calendar,
            color: isToday ? AppColors.primary : AppColors.secondary,
          ),
        ),
        title: Row(
          children: [
            Text(
              "Week ${day.week}, Day ${day.dayOfWeek}",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            if (day.optional)
              Container(
                margin: EdgeInsets.only(left: 8),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "Optional",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ),
        subtitle: Text(date),
        trailing:
            isToday
                ? Icon(LucideIcons.chevronRight, color: AppColors.primary)
                : null,
        onTap: () {
          if (isToday) {
            // Navigate to run tracking for today's workout
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => RunTrackingPage(
                      //trainingDayId: day.id
                    ),
              ),
            );
          } else {
            // Show workout details
            _showTrainingDayDetails(context, day);
          }
        },
      ),
    );
  }

  void _showTrainingDayDetails(BuildContext context, TrainingDayModel day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Training Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Week ${day.week}, Day ${day.dayOfWeek}",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              if (day.dateScheduled != null)
                Text(
                  DateFormat('EEEE, MMMM d').format(day.dateScheduled!),
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              SizedBox(height: 16),

              if (day.runPhases.isEmpty)
                Text(
                  "No specific workout defined for this day",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      day.runPhases.map((phase) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                WorkoutPhaseIcons.getPhaseIcon(phase['type']),
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "${phase['duration']} min ${phase['type']}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),

              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
