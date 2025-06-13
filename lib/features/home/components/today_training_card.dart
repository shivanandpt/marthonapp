import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/utils/workout_phase_icons.dart';
import 'package:marunthon_app/features/runs/run_tracking_pag.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';

class TodayTrainingCard extends StatelessWidget {
  final TrainingDayModel todaysTraining;

  const TodayTrainingCard({super.key, required this.todaysTraining});

  // Helper method to format duration from phase map
  String _formatPhaseDuration(Map<String, dynamic> phase) {
    final duration = phase['duration'];
    int durationInSeconds = 0;

    if (duration is int) {
      durationInSeconds = duration;
    } else if (duration is num) {
      durationInSeconds = duration.toInt();
    }

    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;
    final seconds = durationInSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '${seconds}s';
    }
  }

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
            if (todaysTraining.parsedRunPhases.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...todaysTraining.parsedRunPhases.map((runPhase) {
                    // Extract phase name and duration from the map
                    final phaseName =
                        runPhase['phase'] as String? ?? 'Unknown Phase';
                    final formattedDuration = _formatPhaseDuration(runPhase);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            WorkoutPhaseIcons.getPhaseIcon(phaseName),
                            color: AppColors.primary,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "$formattedDuration $phaseName",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Total Duration: ${todaysTraining.formattedTotalDuration}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
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
