import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/training_plan_model.dart';
import '../../models/training_day_model.dart';
import '../../../user/user_profile/setup/models/user_model.dart';

class AIPlanPreview extends StatelessWidget {
  final TrainingPlanModel trainingPlan;
  final List<TrainingDayModel> trainingDays;
  final UserModel user;
  final Function(TrainingPlanModel, List<TrainingDayModel>) onApprove;
  final VoidCallback onRegenerate;
  final VoidCallback onCancel;

  const AIPlanPreview({
    super.key,
    required this.trainingPlan,
    required this.trainingDays,
    required this.user,
    required this.onApprove,
    required this.onRegenerate,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildPlanOverview(),
          const SizedBox(height: 24),
          _buildWeeklyBreakdown(),
          const SizedBox(height: 24),
          _buildSampleWeek(),
          const SizedBox(height: 32),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    trainingPlan.planName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              trainingPlan.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your AI-generated training plan is ready!',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOverview() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plan Overview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Duration',
                    '${trainingPlan.structure.weeks} weeks',
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Sessions',
                    '${trainingPlan.structure.totalSessions}',
                    Icons.fitness_center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Weekly Frequency',
                    '${trainingPlan.structure.runDaysPerWeek} days/week',
                    Icons.repeat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Goal',
                    trainingPlan.goalType,
                    Icons.flag,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Distance',
                    trainingPlan.statistics.formattedTotalDistanceForMetric(
                      user.metricSystem,
                    ),
                    Icons.straighten,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Time',
                    trainingPlan.statistics.formattedTotalDurationWithOptions(
                      showSeconds: false,
                    ),
                    Icons.timer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.disabled.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBreakdown() {
    // Calculate session breakdown from training days
    final sessionTypes = <String, int>{};
    for (final day in trainingDays) {
      final sessionType = day.identification.sessionType;
      sessionTypes[sessionType] = (sessionTypes[sessionType] ?? 0) + 1;
    }

    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Session Type Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...sessionTypes.entries.map((entry) {
              final percentage =
                  (entry.value / trainingPlan.structure.totalSessions * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        _formatSessionType(entry.key),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.disabled.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getSessionTypeColor(entry.key),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value} (${percentage.toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSampleWeek() {
    // Get first week's sessions as sample
    final firstWeekSessions =
        trainingDays.where((day) => day.identification.week == 1).toList();

    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sample Week (Week 1)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...firstWeekSessions.map((session) => _buildSessionCard(session)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(TrainingDayModel session) {
    // Create a meaningful title from session type and day information
    String title = session.sessionTypeDisplayName;
    if (session.configuration.restDay) {
      title = 'Rest Day';
    }

    // Use metric-aware formatting for distance and duration
    String distanceText = session.targetMetrics.formattedDistance(
      user.metricSystem,
    );
    String durationText = session.totals.formattedTotalDurationWithOptions(
      showSeconds: false,
    );

    // Build phase details for walk/run intervals
    String phaseDetails = '';
    if (session.runPhases.isNotEmpty && !session.configuration.restDay) {
      final phases = session.runPhases;
      final runPhases =
          phases.where((p) => p.phase.toLowerCase() == 'run').toList();
      final walkPhases =
          phases.where((p) => p.phase.toLowerCase() == 'walk').toList();

      if (runPhases.isNotEmpty && walkPhases.isNotEmpty) {
        final runDuration = runPhases.first.duration ~/ 60; // minutes
        final walkDuration = walkPhases.first.duration ~/ 60; // minutes
        final intervals = runPhases.length;
        phaseDetails =
            '$intervals intervals: ${runDuration}m run, ${walkDuration}m walk';
      } else if (runPhases.isNotEmpty) {
        phaseDetails = 'Continuous run';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _getSessionTypeColor(
          session.identification.sessionType,
        ).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: _getSessionTypeColor(
            session.identification.sessionType,
          ).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getSessionTypeColor(session.identification.sessionType),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getSessionTypeIcon(session.identification.sessionType),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$distanceText • $durationText',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (phaseDetails.isNotEmpty)
                  Text(
                    phaseDetails,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (session.configuration.difficulty.isNotEmpty &&
                    phaseDetails.isEmpty)
                  Text(
                    'Difficulty: ${session.configuration.difficulty}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onApprove(trainingPlan, trainingDays),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check),
                SizedBox(width: 8),
                Text(
                  'Approve',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onRegenerate,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Regenerate'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  side: BorderSide(color: AppColors.disabled),
                  foregroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close),
                    SizedBox(width: 8),
                    Text('Cancel'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatSessionType(String type) {
    switch (type) {
      case 'easy_run':
        return 'Easy Run';
      case 'intervals':
        return 'Intervals';
      case 'tempo_run':
        return 'Tempo';
      case 'long_run':
        return 'Long Run';
      default:
        return type;
    }
  }

  Color _getSessionTypeColor(String type) {
    switch (type) {
      case 'easy_run':
        return AppColors.primary;
      case 'intervals':
        return Colors.red;
      case 'tempo_run':
        return Colors.orange;
      case 'long_run':
        return Colors.purple;
      default:
        return AppColors.disabled;
    }
  }

  IconData _getSessionTypeIcon(String type) {
    switch (type) {
      case 'easy_run':
        return Icons.directions_walk;
      case 'intervals':
        return Icons.speed;
      case 'tempo_run':
        return Icons.trending_up;
      case 'long_run':
        return Icons.landscape;
      default:
        return Icons.fitness_center;
    }
  }
}
