import 'package:fl_chart/fl_chart.dart';
import '../../models/run_model.dart';
import '../../models/route_point_model.dart';
import '../models/chart_data.dart';

class ChartDataProcessor {
  static RunChartData processRunData(RunModel run) {
    final points = _extractRoutePoints(run);
    
    return RunChartData(
      speedData: _prepareSpeedData(points),
      elevationData: _prepareElevationData(points),
      paceData: _preparePaceData(points),
      heartRateData: _prepareHeartRateData(points),
      accuracyData: _prepareAccuracyData(points), // Add accuracy data
    );
  }

  static List<RoutePointModel> _extractRoutePoints(RunModel run) {
    // Handle both List<RoutePointModel> and List<dynamic> cases
    if (run.routePoints is List<RoutePointModel>) {
      return run.routePoints as List<RoutePointModel>;
    } else if (run.routePoints is List<dynamic>) {
      // Convert dynamic list to RoutePointModel list
      return (run.routePoints as List<dynamic>)
          .where((point) => point is Map<String, dynamic>)
          .map((point) => RoutePointModel.fromMap(point as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static List<FlSpot> _prepareSpeedData(List<RoutePointModel> points) {
    if (points.isEmpty) return [];

    final startTimestamp = _getStartTimestamp(points);
    final groupedPoints = _groupPointsByMinute(points, startTimestamp);

    return groupedPoints.entries
        .map((entry) => _calculateAverageSpeed(entry.key, entry.value))
        .where((spot) => spot != null)
        .cast<FlSpot>()
        .toList();
  }

  static List<FlSpot> _prepareElevationData(List<RoutePointModel> points) {
    if (points.isEmpty) return [];

    final startTimestamp = _getStartTimestamp(points);
    final groupedPoints = _groupPointsByMinute(points, startTimestamp);

    return groupedPoints.entries
        .map((entry) => _calculateAverageElevation(entry.key, entry.value))
        .where((spot) => spot != null)
        .cast<FlSpot>()
        .toList();
  }

  static List<FlSpot> _preparePaceData(List<RoutePointModel> points) {
    if (points.isEmpty) return [];

    final startTimestamp = _getStartTimestamp(points);
    final groupedPoints = _groupPointsByMinute(points, startTimestamp);

    return groupedPoints.entries
        .map((entry) => _calculateAveragePace(entry.key, entry.value))
        .where((spot) => spot != null)
        .cast<FlSpot>()
        .toList();
  }

  static List<FlSpot> _prepareHeartRateData(List<RoutePointModel> points) {
    // Since RoutePointModel doesn't have heartRate, return empty for now
    // You can add heartRate field to RoutePointModel if needed
    return [];
  }

  static List<FlSpot> _prepareAccuracyData(List<RoutePointModel> points) {
    if (points.isEmpty) return [];

    final startTimestamp = _getStartTimestamp(points);
    final groupedPoints = _groupPointsByMinute(points, startTimestamp);

    return groupedPoints.entries
        .map((entry) => _calculateAverageAccuracy(entry.key, entry.value))
        .where((spot) => spot != null)
        .cast<FlSpot>()
        .toList();
  }

  static double _getStartTimestamp(List<RoutePointModel> points) {
    return points.isNotEmpty
        ? points.first.timestamp.millisecondsSinceEpoch.toDouble()
        : 0.0;
  }

  static Map<int, List<RoutePointModel>> _groupPointsByMinute(
    List<RoutePointModel> points,
    double startTimestamp,
  ) {
    Map<int, List<RoutePointModel>> pointsByMinute = {};

    for (var point in points) {
      final double timestamp = point.timestamp.millisecondsSinceEpoch.toDouble();
      final int minute = ((timestamp - startTimestamp) / 60000).floor();
      pointsByMinute.putIfAbsent(minute, () => []).add(point);
    }

    return pointsByMinute;
  }

  static FlSpot? _calculateAverageSpeed(int minute, List<RoutePointModel> points) {
    final validSpeeds = points
        .where((p) => p.speed > 0)
        .map((p) => p.speed)
        .toList();

    if (validSpeeds.isEmpty) return null;

    final avgSpeed = validSpeeds.reduce((a, b) => a + b) / validSpeeds.length;
    return FlSpot(minute.toDouble(), avgSpeed * 3.6); // Convert m/s to km/h
  }

  static FlSpot? _calculateAverageElevation(int minute, List<RoutePointModel> points) {
    final validElevations = points
        .map((p) => p.elevation)
        .toList();

    if (validElevations.isEmpty) return null;

    final avgElevation = validElevations.reduce((a, b) => a + b) / validElevations.length;
    return FlSpot(minute.toDouble(), avgElevation);
  }

  static FlSpot? _calculateAveragePace(int minute, List<RoutePointModel> points) {
    final validSpeeds = points
        .where((p) => p.speed > 0)
        .map((p) => p.speed)
        .toList();

    if (validSpeeds.isEmpty) return null;

    final avgSpeed = validSpeeds.reduce((a, b) => a + b) / validSpeeds.length;
    final paceMinutesPerKm = (1000 / avgSpeed) / 60; // minutes per km
    return FlSpot(minute.toDouble(), paceMinutesPerKm);
  }

  static FlSpot? _calculateAverageAccuracy(int minute, List<RoutePointModel> points) {
    final validAccuracies = points
        .map((p) => p.accuracy)
        .toList();

    if (validAccuracies.isEmpty) return null;

    final avgAccuracy = validAccuracies.reduce((a, b) => a + b) / validAccuracies.length;
    return FlSpot(minute.toDouble(), avgAccuracy);
  }
}
