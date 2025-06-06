import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/run_tracking/screen/run_tracking_screen.dart';
import 'package:marunthon_app/features/home/bloc/home_bloc.dart';
import 'package:marunthon_app/features/home/bloc/home_state.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StartRunFAB extends StatelessWidget {
  const StartRunFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: FloatingActionButton.extended(
            onPressed: () => _startRun(context, state),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            icon: const Icon(LucideIcons.play, size: 24),
            label: const Text(
              'Start Run',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  void _startRun(BuildContext context, HomeState state) {
    List<RunPhaseModel>? phases;

    // Check if user has an active training plan with today's training day
    if (state is HomeLoaded && state.activePlan != null) {
      final today = DateTime.now();

      try {
        // Access training days from the training plan
        final trainingDays = state.activePlan!.trainingDays;

        if (trainingDays != null && trainingDays.isNotEmpty) {
          // Find today's training day by checking dateScheduled
          final todayTrainingDay =
              trainingDays.where((trainingDay) {
                try {
                  return trainingDay.dateScheduled != null &&
                      _isSameDay(trainingDay.dateScheduled!, today) &&
                      !(trainingDay.completed ?? false);
                } catch (e) {
                  return false;
                }
              }).firstOrNull;

          if (todayTrainingDay != null) {
            try {
              // Get phases directly from the training day
              final dayPhases = todayTrainingDay.phases ?? [];
              if (dayPhases.isNotEmpty) {
                phases = List<RunPhaseModel>.from(dayPhases);
                final dayName = todayTrainingDay.name ?? 'Today\'s Training';

                // Show confirmation dialog for structured training day
                _showWorkoutConfirmationDialog(context, phases, dayName);
                return;
              }
            } catch (e) {
              // If there's an error accessing phases, continue with free run
              print('Error accessing training day phases: $e');
            }
          }
        }
      } catch (e) {
        // If there's an error accessing training days, continue with free run
        print('Error accessing training days: $e');
      }
    }

    // Navigate to free run (default behavior)
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RunTrackingScreen()));
  }

  void _showWorkoutConfirmationDialog(
    BuildContext context,
    List<RunPhaseModel> phases,
    String dayName,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Today\'s Training'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have a structured training planned for today with ${phases.length} phases.',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Would you like to:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Start free run
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RunTrackingScreen(),
                    ),
                  );
                },
                child: const Text('Free Run'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Start structured training
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RunTrackingScreen(phases: phases),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Start Training'),
              ),
            ],
          ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
