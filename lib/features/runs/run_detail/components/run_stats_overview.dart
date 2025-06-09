import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../models/run_model.dart';
import '../../models/route_point_model.dart';

class RunStatsOverview extends StatelessWidget {
  final RunModel run;

  const RunStatsOverview({Key? key, required this.run}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gpsAccuracy = _calculateAverageAccuracy();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Primary stats row
          Row(
            children: [
              _buildPrimaryStat(
                icon: LucideIcons.mapPin,
                label: "Distance",
                value: "${(run.totalDistance / 1000).toStringAsFixed(2)} km",
                color: AppColors.primary,
              ),
              _buildPrimaryStat(
                icon: LucideIcons.clock,
                label: "Duration",
                value: run.formattedDuration,
                color: AppColors.secondary,
              ),
              _buildPrimaryStat(
                icon: LucideIcons.zap,
                label: "Avg Speed",
                value: "${(run.avgSpeed * 3.6).toStringAsFixed(1)} km/h",
                color: AppColors.accent,
              ),
            ],
          ),
          SizedBox(height: 20),

          // Secondary stats grid
          Row(
            children: [
              _buildSecondaryStat(
                icon: LucideIcons.timer,
                label: "Pace",
                value: _formatPace(run),
                color: AppColors.primary,
              ),
              _buildSecondaryStat(
                icon: LucideIcons.footprints,
                label: "Steps",
                value: "${run.steps}",
                color: AppColors.success,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildSecondaryStat(
                icon: LucideIcons.trendingUp,
                label: "Elevation",
                value: "${run.elevationGain.toStringAsFixed(0)}m",
                color: AppColors.warning,
              ),
              _buildSecondaryStat(
                icon: LucideIcons.satellite,
                label: "GPS Accuracy",
                value: "${gpsAccuracy.toStringAsFixed(1)}m",
                color: AppColors.info,
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildSecondaryStat(
                icon: LucideIcons.flame,
                label: "Calories",
                value: "${run.calories.toStringAsFixed(0)}",
                color: AppColors.error,
              ),
              _buildSecondaryStat(
                icon: _getGpsQualityIcon(gpsAccuracy),
                label: "GPS Quality",
                value: _getGpsQualityText(gpsAccuracy),
                color: _getGpsQualityColor(gpsAccuracy),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateAverageAccuracy() {
    List<RoutePointModel> points = [];

    if (run.routePoints is List<RoutePointModel>) {
      points = run.routePoints as List<RoutePointModel>;
    } else if (run.routePoints is List<dynamic>) {
      points =
          (run.routePoints as List<dynamic>)
              .where((point) => point is Map<String, dynamic>)
              .map(
                (point) =>
                    RoutePointModel.fromMap(point as Map<String, dynamic>),
              )
              .toList();
    }

    if (points.isEmpty) return 0.0;

    final totalAccuracy = points.map((p) => p.accuracy).reduce((a, b) => a + b);
    return totalAccuracy / points.length;
  }

  IconData _getGpsQualityIcon(double accuracy) {
    if (accuracy <= 5) return LucideIcons.checkCircle;
    if (accuracy <= 10) return LucideIcons.alertCircle;
    return LucideIcons.xCircle;
  }

  String _getGpsQualityText(double accuracy) {
    if (accuracy <= 5) return "Excellent";
    if (accuracy <= 10) return "Good";
    if (accuracy <= 20) return "Fair";
    return "Poor";
  }

  Color _getGpsQualityColor(double accuracy) {
    if (accuracy <= 5) return AppColors.success;
    if (accuracy <= 10) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildPrimaryStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  String _formatPace(RunModel run) {
    if (run.totalDistance == 0 || run.duration == 0) return "0:00";

    final double paceSecondsPerKm = (run.duration / (run.totalDistance / 1000));
    final int minutes = (paceSecondsPerKm / 60).floor();
    final int seconds = (paceSecondsPerKm % 60).round();

    return "${minutes}:${seconds.toString().padLeft(2, '0')}/km";
  }
}
