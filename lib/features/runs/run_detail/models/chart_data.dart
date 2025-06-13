import 'package:fl_chart/fl_chart.dart';

class ChartDataPoint {
  final double x;
  final double y;
  final DateTime timestamp;

  ChartDataPoint({
    required this.x,
    required this.y,
    required this.timestamp,
  });
}

class RunChartData {
  final List<FlSpot> speedData;
  final List<FlSpot> elevationData;
  final List<FlSpot> paceData;
  final List<FlSpot> heartRateData;
  final List<FlSpot> accuracyData; // Add accuracy data

  RunChartData({
    required this.speedData,
    required this.elevationData,
    required this.paceData,
    required this.heartRateData,
    required this.accuracyData, // Add to constructor
  });
}
