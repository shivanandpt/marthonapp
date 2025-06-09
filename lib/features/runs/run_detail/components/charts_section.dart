import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../models/chart_data.dart';
import 'chart_section.dart';

class ChartsSection extends StatelessWidget {
  final RunChartData chartData;

  const ChartsSection({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Performance Charts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Speed Chart
        ChartSection(
          title: "Speed Over Time",
          data: chartData.speedData,
          color: AppColors.primary,
          yAxisLabel: "Speed (km/h)",
          unit: " km/h",
        ),

        // Pace Chart
        ChartSection(
          title: "Pace Over Time",
          data: chartData.paceData,
          color: AppColors.secondary,
          yAxisLabel: "Pace (min/km)",
          unit: " min/km",
        ),

        // Elevation Chart
        ChartSection(
          title: "Elevation Over Time",
          data: chartData.elevationData,
          color: AppColors.warning,
          yAxisLabel: "Elevation (m)",
          showArea: true,
          unit: "m",
        ),

        // GPS Accuracy Chart
        ChartSection(
          title: "GPS Accuracy Over Time",
          data: chartData.accuracyData,
          color: AppColors.accent,
          yAxisLabel: "Accuracy (m)",
          unit: "m",
        ),

        // Heart Rate Chart (if available - you might want to add this field to RoutePointModel)
        if (chartData.heartRateData.isNotEmpty)
          ChartSection(
            title: "Heart Rate Over Time",
            data: chartData.heartRateData,
            color: AppColors.error,
            yAxisLabel: "Heart Rate (bpm)",
            unit: " bpm",
          ),
      ],
    );
  }
}
