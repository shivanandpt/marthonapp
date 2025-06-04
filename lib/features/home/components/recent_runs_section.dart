import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/run_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RecentRunsSection extends StatelessWidget {
  final List<RunModel> recentRuns;

  const RecentRunsSection({super.key, required this.recentRuns});

  // For a smoother transition, you can add hero animations:
  void _navigateToRunDetail(BuildContext context, RunModel run) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => RunDetailPage(run: run),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Runs",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                context.go('/my-runs');
              },
              child: Text(
                "View All",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Recent runs list
        ...recentRuns.take(3).map((run) => _buildRunCard(context, run)),
      ],
    );
  }

  Widget _buildRunCard(BuildContext context, RunModel run) {
    final String formattedDate = DateFormat(
      'MMM dd, yyyy',
    ).format(run.startTime);
    final String formattedTime = DateFormat('HH:mm').format(run.startTime);

    // Convert meters to kilometers with 2 decimal places
    final String distance = (run.totalDistance / 1000).toStringAsFixed(2);

    // Use the RunModel's formatted duration (same as detail page)
    final String duration = run.formattedDuration;

    // Calculate pace using totalDistance and duration
    final String pace = _formatPace(run);

    return Hero(
      tag: 'run-${run.id}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          color: AppColors.cardBg,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _navigateToRunDetail(context, run),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with date and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            LucideIcons.chevronRight,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  Row(
                    children: [
                      // Distance
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.mapPin,
                          label: "Distance",
                          value: "$distance km",
                          color: AppColors.primary,
                        ),
                      ),
                      // Duration - now using consistent formatting
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.clock,
                          label: "Duration",
                          value: duration,
                          color: AppColors.secondary,
                        ),
                      ),
                      // Steps
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.footprints,
                          label: "Steps",
                          value: "${run.steps}",
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),

                  // Optional: Add second row with more stats
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Pace
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.timer,
                          label: "Pace",
                          value: pace,
                          color: AppColors.primary,
                        ),
                      ),
                      // Elevation
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.trendingUp,
                          label: "Elevation",
                          value: "${run.elevationGain.toStringAsFixed(0)}m",
                          color: AppColors.primary,
                        ),
                      ),
                      // Speed
                      Expanded(
                        child: _buildStatItem(
                          icon: LucideIcons.zap,
                          label: "Speed",
                          value:
                              "${(run.avgSpeed * 3.6).toStringAsFixed(1)} km/h",
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatPace(RunModel run) {
    if (run.totalDistance == 0 || run.duration == 0) return "0:00";

    // Calculate pace in seconds per kilometer
    final double paceSecondsPerKm = (run.duration / (run.totalDistance / 1000));
    final int minutes = (paceSecondsPerKm / 60).floor();
    final int seconds = (paceSecondsPerKm % 60).round();

    return "${minutes}:${seconds.toString().padLeft(2, '0')}";
  }
}
