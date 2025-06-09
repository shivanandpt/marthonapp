// lib/features/runs/components/run_map.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class RunMap extends StatefulWidget {
  final RunModel run;

  const RunMap({super.key, required this.run});

  @override
  State<RunMap> createState() => _RunMapState();
}

class _RunMapState extends State<RunMap> {
  GoogleMapController? _mapController;
  bool _isMapReady = false;

  LatLngBounds _getBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    // Add some padding to ensure all points are visible
    double latPadding = (maxLat - minLat) * 0.1; // 10% padding
    double lngPadding = (maxLng - minLng) * 0.1; // 10% padding

    // Minimum padding in case the route is very small
    latPadding = latPadding < 0.001 ? 0.001 : latPadding;
    lngPadding = lngPadding < 0.001 ? 0.001 : lngPadding;

    return LatLngBounds(
      southwest: LatLng(minLat - latPadding, minLng - lngPadding),
      northeast: LatLng(maxLat + latPadding, maxLng + lngPadding),
    );
  }

  void _fitBounds(List<LatLng> points) {
    if (_mapController == null || points.isEmpty || !_isMapReady) return;

    try {
      final bounds = _getBounds(points);
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          100.0, // Padding in pixels
        ),
      );
    } catch (e) {
      print('Error fitting bounds: $e');
      // Fallback to center on first point
      if (points.isNotEmpty) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: points.first, zoom: 15.0),
          ),
        );
      }
    }
  }

  // If the above doesn't work, try this simpler approach
  void _fitBoundsSimple(List<LatLng> points) {
    if (_mapController == null || points.isEmpty) return;

    // Calculate center point
    double centerLat =
        points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    double centerLng =
        points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;

    // Calculate distance span
    double minLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = points
        .map((p) => p.latitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = points
        .map((p) => p.longitude)
        .reduce((a, b) => a > b ? a : b);

    double latSpan = maxLat - minLat;
    double lngSpan = maxLng - minLng;

    // Determine appropriate zoom level
    double zoom = 15.0;
    if (latSpan > 0.01 || lngSpan > 0.01) zoom = 13.0;
    if (latSpan > 0.05 || lngSpan > 0.05) zoom = 11.0;
    if (latSpan > 0.1 || lngSpan > 0.1) zoom = 9.0;

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(centerLat, centerLng), zoom: zoom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> points =
        widget.run.routePoints.cast<Map<String, dynamic>>();

    // Filter out invalid points and convert to LatLng
    final List<LatLng> polylinePoints =
        points
            .where(
              (p) =>
                  p['latitude'] != null &&
                  p['longitude'] != null &&
                  p['latitude'] is num &&
                  p['longitude'] is num,
            )
            .map(
              (p) => LatLng(
                (p['latitude'] as num).toDouble(),
                (p['longitude'] as num).toDouble(),
              ),
            )
            .toList();

    print('RoutePoints count: ${polylinePoints.length}');
    if (polylinePoints.isNotEmpty) {
      print('First point: ${polylinePoints.first}');
      print('Last point: ${polylinePoints.last}');
    }

    if (polylinePoints.isEmpty) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: 8),
              Text(
                'No route data available',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 300,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: polylinePoints.first,
              zoom: 15, // Start with a reasonable zoom
            ),
            polylines: {
              Polyline(
                polylineId: PolylineId('route'),
                color: AppColors.primary,
                width: 4,
                points: polylinePoints,
                patterns: [], // Solid line
              ),
            },
            markers: {
              // Start marker
              Marker(
                markerId: MarkerId('start'),
                position: polylinePoints.first,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
                infoWindow: InfoWindow(
                  title: 'Start',
                  snippet: 'Run started here',
                ),
              ),
              // End marker (only if different from start)
              if (polylinePoints.length > 1 &&
                  polylinePoints.first != polylinePoints.last)
                Marker(
                  markerId: MarkerId('end'),
                  position: polylinePoints.last,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Finish',
                    snippet: 'Run ended here',
                  ),
                ),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _isMapReady = true;

              // Fit bounds after map is created and a short delay
              Future.delayed(Duration(milliseconds: 1000), () {
                _fitBounds(polylinePoints);
              });
            },
            onCameraIdle: () {
              // Ensure bounds are fitted when camera stops moving
              if (_isMapReady && polylinePoints.length > 1) {
                // Only fit bounds once when map is first loaded
                Future.delayed(Duration(milliseconds: 100), () {
                  if (mounted) {
                    _fitBounds(polylinePoints);
                  }
                });
              }
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            buildingsEnabled: true,
            compassEnabled: false,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: false,
            zoomGesturesEnabled: true,
            mapToolbarEnabled: false,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
