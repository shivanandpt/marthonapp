import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RunStatsDisplay extends StatelessWidget {
  final Duration totalTime;
  final double totalDistance;
  final double currentSpeed;
  final double currentElevation;
  final double averagePace;
  final int totalRoutePoints;

  const RunStatsDisplay({
    super.key,
    required this.totalTime,
    required this.totalDistance,
    required this.currentSpeed,
    required this.currentElevation,
    required this.averagePace,
    required this.totalRoutePoints,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String _formatPace(double paceSecondsPerKm) {
    if (paceSecondsPerKm.isInfinite || paceSecondsPerKm.isNaN) {
      return '--:--';
    }
    final minutes = (paceSecondsPerKm / 60).floor();
    final seconds = (paceSecondsPerKm % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Main time display
          Container(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              _formatDuration(totalTime),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
          ),

          // Stats grid
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.map,
                        label: 'Distance',
                        value:
                            '${(totalDistance / 1000).toStringAsFixed(2)} km',
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.secondary.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.zap,
                        label: 'Avg Pace',
                        value: '${_formatPace(averagePace)}/km',
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),
                Container(
                  height: 1,
                  color: AppColors.secondary.withOpacity(0.2),
                ),
                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.gauge,
                        label: 'Speed',
                        value:
                            '${(currentSpeed * 3.6).toStringAsFixed(1)} km/h',
                        color: AppColors.accent,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.secondary.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        icon: LucideIcons.mountain,
                        label: 'Elevation',
                        value: '${currentElevation.toStringAsFixed(0)} m',
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Additional info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, color: AppColors.info, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'GPS Points: $totalRoutePoints',
                      style: TextStyle(fontSize: 12, color: AppColors.info),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'GPS Active',
                      style: TextStyle(fontSize: 12, color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
