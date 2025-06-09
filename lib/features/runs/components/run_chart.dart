// lib/features/runs/components/run_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class RunChart extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final Color color;
  final String yAxisLabel;
  final bool showArea;

  const RunChart({
    super.key,
    required this.title,
    required this.spots,
    required this.color,
    required this.yAxisLabel,
    this.showArea = false,
  });

  @override
  Widget build(BuildContext context) {
    if (spots.length <= 1) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Insufficient data for $title',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final double yPadding = (maxY - minY) * 0.1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: AppColors.cardBg,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minY: minY - yPadding,
                    maxY: maxY + yPadding,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      verticalInterval: 5,
                      getDrawingVerticalLine:
                          (value) => FlLine(
                            color: AppColors.textSecondary.withOpacity(0.2),
                            strokeWidth: 1,
                          ),
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: AppColors.textSecondary.withOpacity(0.2),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget:
                              (value, meta) => Text(
                                value.toStringAsFixed(0),
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 5,
                          getTitlesWidget:
                              (value, meta) => Text(
                                "${value.toInt()}m",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.3),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: color,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        belowBarData:
                            showArea
                                ? BarAreaData(
                                  show: true,
                                  color: color.withOpacity(0.15),
                                )
                                : BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "$yAxisLabel over time (minutes)",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
