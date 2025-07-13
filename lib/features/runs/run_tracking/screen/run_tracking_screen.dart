import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';
import 'package:marunthon_app/features/runs/run_tracking/bloc/run_tracking_bloc.dart';
import 'package:marunthon_app/features/runs/run_tracking/bloc/run_tracking_state.dart';
import 'package:marunthon_app/features/runs/run_tracking/bloc/run_tracking_event.dart';
import 'package:marunthon_app/features/runs/run_tracking/components/run_phase_header.dart';
import 'package:marunthon_app/features/runs/run_tracking/components/run_controls.dart';
import 'package:marunthon_app/features/runs/run_tracking/components/run_stats_display.dart';
import 'package:marunthon_app/core/utils/location_permission_helper.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RunTrackingScreen extends StatelessWidget {
  final List<RunPhaseModel>? phases;

  const RunTrackingScreen({super.key, this.phases});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RunTrackingBloc()..add(StartRun(phases: phases)),
      child: _RunTrackingView(phases: phases),
    );
  }
}

class _RunTrackingView extends StatelessWidget {
  final List<RunPhaseModel>? phases;
  
  const _RunTrackingView({this.phases});

  double _calculateAveragePace(double distanceKm, Duration time) {
    if (distanceKm == 0 || time.inSeconds == 0) return 0;
    return time.inSeconds / distanceKm; // seconds per km
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => _showExitConfirmation(context),
        ),
        title: Text(
          'Run Tracking',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RunTrackingBloc, RunTrackingState>(
        listener: (context, state) {
          if (state is RunTrackingCompleted) {
            Navigator.of(context).pop({
              'completed': true,
              'totalTime': state.totalTime,
              'totalDistance': state.totalDistance,
              'routePoints': state.routePoints,
            });
          }
        },
        builder: (context, state) {
          if (state is RunTrackingInitial) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is RunTrackingError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Location Access Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'To track your runs, we need access to your location.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Go to Settings > Privacy & Security > Location Services and enable location for this app.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cardBg,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Go Back'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await LocationPermissionHelper.openAppSettings();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Open Settings'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<RunTrackingBloc>().add(
                                StartRun(phases: phases),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RunTrackingActive) {
            final averagePace = _calculateAveragePace(
              state.totalDistance / 1000,
              state.elapsedTime,
            );

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Phase header
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: RunPhaseHeader(
                      currentPhase: state.currentPhase,
                      currentPhaseIndex: state.currentPhaseIndex,
                      totalPhases: state.phases.length,
                      phaseElapsedTime: state.phaseElapsedTime,
                      hasNextPhase: state.hasNextPhase,
                      hasPreviousPhase: state.hasPreviousPhase,
                      onNextPhase:
                          state.status == RunStatus.paused
                              ? () => context.read<RunTrackingBloc>().add(
                                NextPhase(),
                              )
                              : null,
                      onPreviousPhase:
                          state.status == RunStatus.paused
                              ? () => context.read<RunTrackingBloc>().add(
                                PreviousPhase(),
                              )
                              : null,
                    ),
                  ),

                  // Stats display
                  RunStatsDisplay(
                    totalTime: state.elapsedTime,
                    totalDistance: state.totalDistance,
                    currentSpeed: state.currentSpeed,
                    currentElevation: state.currentElevation,
                    averagePace: averagePace,
                    totalRoutePoints: state.routePoints.length,
                  ),

                  SizedBox(height: 20),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'Something went wrong',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<RunTrackingBloc, RunTrackingState>(
        builder: (context, state) {
          if (state is RunTrackingActive) {
            return RunControls(
              status: state.status,
              hasNextPhase: state.hasNextPhase,
              hasPreviousPhase: state.hasPreviousPhase,
              onPlayPause: () {
                if (state.status == RunStatus.running) {
                  context.read<RunTrackingBloc>().add(PauseRun());
                } else {
                  context.read<RunTrackingBloc>().add(ResumeRun());
                }
              },
              onEnd: () => _showEndConfirmation(context),
              onNextPhase:
                  state.status == RunStatus.running
                      ? () => context.read<RunTrackingBloc>().add(NextPhase())
                      : null,
              onPreviousPhase:
                  state.status == RunStatus.running
                      ? () =>
                          context.read<RunTrackingBloc>().add(PreviousPhase())
                      : null,
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            title: Text(
              'Exit Run?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Are you sure you want to exit? Your progress will be saved.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Exit', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
    );
  }

  void _showEndConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            title: Text(
              'End Run?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Text(
              'Are you sure you want to end this run? This will save your progress.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<RunTrackingBloc>().add(EndRun());
                },
                child: Text(
                  'End Run',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );
  }
}
