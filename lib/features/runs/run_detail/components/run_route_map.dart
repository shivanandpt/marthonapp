import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../models/run_model.dart';
import '../../models/route_point_model.dart';

class RunRouteMap extends StatefulWidget {
  final RunModel run;

  const RunRouteMap({Key? key, required this.run}) : super(key: key);

  @override
  State<RunRouteMap> createState() => _RunRouteMapState();
}

class _RunRouteMapState extends State<RunRouteMap> {
  GoogleMapController?
  _mapController; // Changed from _controller to _mapController
  List<LatLng> polylinePoints = []; // Changed to match working code
  LatLngBounds? bounds; // Add bounds variable
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  void _initializeMapData() async {
    try {
      polylinePoints = _extractRoutePoints();
      print('Route points extracted: ${polylinePoints.length}');

      if (polylinePoints.length > 1) {
        bounds = _calculateBounds(polylinePoints);
        print('Bounds calculated: $bounds');
      }

      print('Polyline points ready: ${polylinePoints.length}');
    } catch (e) {
      print('Error initializing map data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<LatLng> _extractRoutePoints() {
    try {
      List<RoutePointModel> points = [];

      print('Route points type: ${widget.run.routePoints.runtimeType}');
      print('Route points count: ${widget.run.routePoints?.length ?? 0}');

      // Handle both List<RoutePointModel> and List<dynamic> cases
      if (widget.run.routePoints is List<RoutePointModel>) {
        points = widget.run.routePoints as List<RoutePointModel>;
        print('Direct RoutePointModel list with ${points.length} points');
      } else if (widget.run.routePoints is List<dynamic>) {
        final dynamicList = widget.run.routePoints as List<dynamic>;
        print('Dynamic list with ${dynamicList.length} items');

        points =
            dynamicList
                .where((point) {
                  if (point is Map<String, dynamic>) {
                    return point['latitude'] != null &&
                        point['longitude'] != null;
                  }
                  return false;
                })
                .map((point) {
                  try {
                    return RoutePointModel.fromMap(
                      point as Map<String, dynamic>,
                    );
                  } catch (e) {
                    print('Error creating RoutePointModel: $e');
                    return null;
                  }
                })
                .where((point) => point != null)
                .cast<RoutePointModel>()
                .toList();

        print('Converted to ${points.length} RoutePointModel objects');
      }

      // Filter out invalid coordinates and convert to LatLng
      final validLatLngs =
          points
              .where((point) {
                final isValid =
                    point.latitude != 0.0 &&
                    point.longitude != 0.0 &&
                    point.latitude.abs() <= 90 &&
                    point.longitude.abs() <= 180;
                if (!isValid) {
                  print(
                    'Invalid point: lat=${point.latitude}, lng=${point.longitude}',
                  );
                }
                return isValid;
              })
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

      print('Valid LatLng points: ${validLatLngs.length}');
      if (validLatLngs.isNotEmpty) {
        print('First point: ${validLatLngs.first}');
        print('Last point: ${validLatLngs.last}');
      }

      return validLatLngs;
    } catch (e) {
      print('Error extracting route points: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: EdgeInsets.all(16),
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 8),
              Text(
                'Loading map...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (polylinePoints.isEmpty) {
      return Container(
        margin: EdgeInsets.all(16),
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
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
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Route points: ${widget.run.routePoints?.length ?? 0}',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target:
                polylinePoints.isNotEmpty ? polylinePoints.first : LatLng(0, 0),
            zoom: 16,
          ),
          polylines: {
            Polyline(
              polylineId: PolylineId('route'),
              color:
                  AppColors
                      .primary, // Using primary color like working code uses accent
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
            if (polylinePoints.length > 1 && bounds != null) {
              Future.delayed(Duration(milliseconds: 300), () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngBounds(bounds!, 40),
                );
              });
            }
          },
          zoomControlsEnabled: true, // Enable for testing
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
        ),
      ),
    );
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
    }

    if (points.length == 1) {
      // For single point, create small bounds around it
      final point = points.first;
      const double padding = 0.001; // About 100 meters
      return LatLngBounds(
        southwest: LatLng(point.latitude - padding, point.longitude - padding),
        northeast: LatLng(point.latitude + padding, point.longitude + padding),
      );
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  // Custom zoom methods for the floating action buttons
  void _zoomIn() async {
    try {
      if (_mapController != null) {
        print('Zooming in...');
        await _mapController!.animateCamera(CameraUpdate.zoomIn());
        print('Zoom in completed');
      } else {
        print('Controller is null, cannot zoom in');
      }
    } catch (e) {
      print('Error zooming in: $e');
    }
  }

  void _zoomOut() async {
    try {
      if (_mapController != null) {
        print('Zooming out...');
        await _mapController!.animateCamera(CameraUpdate.zoomOut());
        print('Zoom out completed');
      } else {
        print('Controller is null, cannot zoom out');
      }
    } catch (e) {
      print('Error zooming out: $e');
    }
  }

  void _fitMapToRoute() async {
    if (polylinePoints.isEmpty || _mapController == null) {
      print(
        'Cannot fit map to route: points=${polylinePoints.length}, controller=${_mapController != null}',
      );
      return;
    }

    try {
      if (polylinePoints.length == 1) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(polylinePoints.first, 16),
        );
      } else if (bounds != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds!, 40),
        );
      }
    } catch (e) {
      print('Error fitting map to route: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
