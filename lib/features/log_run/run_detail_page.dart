import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marunthon_app/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class RunDetailPage extends StatefulWidget {
  final RunModel run;

  const RunDetailPage({super.key, required this.run});

  @override
  State<RunDetailPage> createState() => _RunDetailPageState();
}

class _RunDetailPageState extends State<RunDetailPage> {
  GoogleMapController? _mapController;
  LatLngBounds getBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;
    for (final p in points) {
      if (minLat == null || p.latitude < minLat) minLat = p.latitude;
      if (maxLat == null || p.latitude > maxLat) maxLat = p.latitude;
      if (minLng == null || p.longitude < minLng) minLng = p.longitude;
      if (maxLng == null || p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat ?? 0, minLng ?? 0),
      northeast: LatLng(maxLat ?? 0, maxLng ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> points = widget.run.routePoints;
    final List<LatLng> polylinePoints =
        points.map((p) => LatLng(p['latitude'], p['longitude'])).toList();
    final bounds = getBounds(polylinePoints);

    final CameraPosition initialCameraPosition =
        polylinePoints.isNotEmpty
            ? CameraPosition(target: polylinePoints.first, zoom: 16)
            : CameraPosition(target: LatLng(0, 0), zoom: 1);

    // Prepare data for charts
    final double startTimestamp =
        points.isNotEmpty && points.first['timestamp'] != null
            ? (points.first['timestamp'] as num).toDouble()
            : 0.0;

    // Group points by minute offset from start
    Map<int, List<Map<String, dynamic>>> pointsByMinute = {};
    for (var p in points) {
      if (p['timestamp'] != null) {
        final double ts = (p['timestamp'] as num).toDouble();
        final int minute = ((ts - startTimestamp) / 60000).floor();
        pointsByMinute.putIfAbsent(minute, () => []).add(p);
      }
    }

    // Calculate per-minute averages
    List<FlSpot> speedSpots = [];
    List<FlSpot> elevationSpots = [];
    for (var entry in pointsByMinute.entries) {
      final int minute = entry.key;
      final pointsInMinute = entry.value;
      final avgSpeed =
          pointsInMinute
              .where((p) => p['speed'] != null)
              .map(
                (p) =>
                    (p['speed'] as num).toDouble().clamp(0.0, double.infinity),
              )
              .fold<double>(0.0, (a, b) => a + b) /
          (pointsInMinute.where((p) => p['speed'] != null).isEmpty
              ? 1
              : pointsInMinute.where((p) => p['speed'] != null).length);
      final avgElevation =
          pointsInMinute
              .where((p) => p['elevation'] != null)
              .map((p) => (p['elevation'] as num).toDouble())
              .fold<double>(0.0, (a, b) => a + b) /
          (pointsInMinute.where((p) => p['elevation'] != null).isEmpty
              ? 1
              : pointsInMinute.where((p) => p['elevation'] != null).length);

      speedSpots.add(FlSpot(minute.toDouble(), avgSpeed));
      elevationSpots.add(FlSpot(minute.toDouble(), avgElevation));
    }

    final double firstElevation =
        elevationSpots.isNotEmpty ? elevationSpots.first.y : 0.0;

    List<FlSpot> normalizedElevationSpots = [
      for (var spot in elevationSpots) FlSpot(spot.x, spot.y - firstElevation),
    ];

    // Calculate min and max elevation for the chart Y axis, with padding
    final double minElevation =
        elevationSpots.isNotEmpty
            ? elevationSpots.map((e) => e.y).reduce((a, b) => a < b ? a : b)
            : 0.0;
    final double maxElevation =
        elevationSpots.isNotEmpty
            ? elevationSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b)
            : 0.0;
    final double yPadding = 2.0; // adjust for more/less space

    print(points);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Run Details",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        children: [
          // Map
          SizedBox(
            height: 260,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    polylinePoints.isNotEmpty
                        ? polylinePoints.first
                        : LatLng(0, 0),
                zoom: 16,
              ),
              polylines: {
                Polyline(
                  polylineId: PolylineId('route'),
                  color: AppColors.accent,
                  width: 5,
                  points: polylinePoints,
                ),
              },
              markers: {
                if (polylinePoints.isNotEmpty)
                  Marker(
                    markerId: MarkerId('start'),
                    position: polylinePoints.first,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen,
                    ),
                  ),
                if (polylinePoints.length > 1)
                  Marker(
                    markerId: MarkerId('end'),
                    position: polylinePoints.last,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
              },
              onMapCreated: (controller) {
                _mapController = controller;
                if (polylinePoints.length > 1) {
                  Future.delayed(Duration(milliseconds: 300), () {
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 40),
                    );
                  });
                }
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
            ),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  DateFormat(
                    'EEE, MMM d, yyyy – HH:mm',
                  ).format(widget.run.timestamp),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(
                      label: "Distance",
                      value: "${widget.run.distance.toStringAsFixed(2)} m",
                    ),
                    _StatBox(
                      label: "Duration",
                      value:
                          Duration(
                            seconds: widget.run.duration,
                          ).toString().split('.').first,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatBox(
                      label: "Avg Speed",
                      value: "${widget.run.speed.toStringAsFixed(2)} m/s",
                    ),
                    _StatBox(
                      label: "Elevation",
                      value: "${widget.run.elevation.toStringAsFixed(1)} m",
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Speed vs Time Graph
          if (speedSpots.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: AppColors.cardBg,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Speed vs Time",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        value.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 60, // 60 seconds = 1 minute
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        "${(value / 60).toStringAsFixed(0)}m",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
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
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: speedSpots,
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Speed (m/s) over time (minutes)",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Elevation vs Time Graph
          if (elevationSpots.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: AppColors.cardBg,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          "Elevation vs Time",
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            minY: minElevation - yPadding,
                            maxY: maxElevation + yPadding,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: true,
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        "${value.toStringAsFixed(0)} m",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 32,
                                  interval: 60, // 60 seconds = 1 minute
                                  getTitlesWidget:
                                      (value, meta) => Text(
                                        "${(value / 60).toStringAsFixed(1)}m",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
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
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: elevationSpots,
                                isCurved: true,
                                color: AppColors.secondary,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.secondary.withOpacity(0.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Elevation (m) over time (minutes)",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
