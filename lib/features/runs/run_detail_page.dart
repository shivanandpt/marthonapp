import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'components/run_header.dart';
import 'components/run_stats_grid.dart';
import 'components/run_map.dart';
import 'components/run_chart.dart';

class RunDetailPage extends StatelessWidget {
  final RunModel run;

  const RunDetailPage({super.key, required this.run});

  List<FlSpot> _prepareSpeedData() {
    // Properly cast the route points
    final List<Map<String, dynamic>> points =
        (run.routePoints as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    if (points.isEmpty) return [];

    // Safe null checking
    final double startTimestamp =
        points.isNotEmpty && points.first['timestamp'] != null
            ? (points.first['timestamp'] as num).toDouble()
            : 0.0;

    Map<int, List<Map<String, dynamic>>> pointsByMinute = {};

    // Group points by minute
    for (var point in points) {
      if (point['timestamp'] != null) {
        final double timestamp = (point['timestamp'] as num).toDouble();
        final int minute = ((timestamp - startTimestamp) / 60).floor();
        pointsByMinute.putIfAbsent(minute, () => []).add(point);
      }
    }

    // Convert to FlSpot list
    List<FlSpot> speedData = [];
    pointsByMinute.forEach((minute, pointsInMinute) {
      if (pointsInMinute.isNotEmpty) {
        // Calculate average speed for this minute
        double totalSpeed = 0;
        int validPoints = 0;

        for (var point in pointsInMinute) {
          if (point['speed'] != null) {
            totalSpeed += (point['speed'] as num).toDouble();
            validPoints++;
          }
        }

        if (validPoints > 0) {
          final avgSpeed = totalSpeed / validPoints;
          speedData.add(FlSpot(minute.toDouble(), avgSpeed));
        }
      }
    });

    return speedData;
  }

  List<FlSpot> _prepareElevationData() {
    final List<Map<String, dynamic>> points =
        (run.routePoints as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];

    if (points.isEmpty) return [];

    final double startTimestamp =
        points.first['timestamp'] != null
            ? (points.first['timestamp'] as num).toDouble()
            : 0.0;

    Map<int, List<Map<String, dynamic>>> pointsByMinute = {};
    for (var p in points) {
      if (p['timestamp'] != null) {
        final double ts = (p['timestamp'] as num).toDouble();
        final int minute = ((ts - startTimestamp) / 60000).floor();
        pointsByMinute.putIfAbsent(minute, () => []).add(p);
      }
    }

    List<FlSpot> elevationSpots = [];
    for (var entry in pointsByMinute.entries) {
      final int minute = entry.key;
      final pointsInMinute = entry.value;

      final avgElevation =
          pointsInMinute
              .where((p) => p['elevation'] != null)
              .map((p) => (p['elevation'] as num).toDouble())
              .fold<double>(0.0, (a, b) => a + b) /
          (pointsInMinute.where((p) => p['elevation'] != null).isEmpty
              ? 1
              : pointsInMinute.where((p) => p['elevation'] != null).length);

      elevationSpots.add(FlSpot(minute.toDouble(), avgElevation));
    }

    return elevationSpots;
  }

  @override
  Widget build(BuildContext context) {
    final speedData = _prepareSpeedData();
    final elevationData = _prepareElevationData();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Run Details",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        children: [
          // Header with date and time
          RunHeader(run: run),

          // Main stats grid
          RunStatsGrid(run: run),

          // Map
          RunMap(run: run),

          SizedBox(height: 16),

          // Speed Chart
          RunChart(
            title: "Speed Over Time",
            spots: speedData,
            color: AppColors.primary,
            yAxisLabel: "km/h",
          ),

          // Elevation Chart
          RunChart(
            title: "Elevation Over Time",
            spots: elevationData,
            color: AppColors.secondary,
            yAxisLabel: "meters",
            showArea: true,
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
