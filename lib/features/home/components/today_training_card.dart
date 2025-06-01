import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/utils/workout_phase_icons.dart';
import 'package:marunthon_app/features/log_run/run_tracking_pag.dart';
import 'package:marunthon_app/models/training_day_model.dart';

class TodayTrainingCard extends StatelessWidget {
  final TrainingDayModel todaysTraining;

  const TodayTrainingCard({Key? key, required this.todaysTraining})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Card(
      margin: EdgeInsets.symmetric(vertical: 16),
      color: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    LucideIcons.calendar,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Today's Training",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              formattedDate,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            SizedBox(height: 16),

            // Training details based on run phases
            if (todaysTraining.runPhases.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...todaysTraining.runPhases.map((phase) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            WorkoutPhaseIcons.getPhaseIcon(phase['type']),
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${phase['duration']} min ${phase['type']}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              )
            else
              Text(
                "No specific workout defined for today",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),

            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RunTrackingPage(
                            //trainingDay: todaysTraining
                          ),
                    ),
                  );
                },
                icon: Icon(LucideIcons.play),
                label: Text("Start Run"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
