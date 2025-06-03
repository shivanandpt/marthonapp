import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/services/run_service.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class RunTrackingPage extends StatefulWidget {
  const RunTrackingPage({super.key});

  @override
  _RunTrackingPageState createState() => _RunTrackingPageState();
}

class _RunTrackingPageState extends State<RunTrackingPage> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  LatLng? _startPosition;
  LatLng? _lastPosition;
  double totalDistance = 0.0;
  StreamSubscription<LocationData>? _locationSubscription;
  final List<Map<String, dynamic>> _routePoints = [];
  bool _isPaused = false; // Store latitude, longitude, elevation, and speed
  Timer? _timer;
  int _elapsedSeconds = 0;
  int? _startTimestamp;
  int? _pauseTimestamp; // timestamp (seconds) when paused
  int _pausedDuration = 0;
  late final String imagePath;
  @override
  void initState() {
    super.initState();
    final random = Random();
    final imageIndex = random.nextInt(10) + 1; // 1 to 10
    imagePath = 'lib/assets/images/running_person$imageIndex.jpg';
    _startTracking();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted && _startTimestamp != null && !_isPaused) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        setState(() {
          _elapsedSeconds = now - _startTimestamp! - _pausedDuration;
        });
      }
    });
  }

  void _startTracking() async {
    // Request location permissions
    bool serviceEnabled = await _location.requestService();
    PermissionStatus permissionGranted = await _location.requestPermission();

    if (serviceEnabled && permissionGranted == PermissionStatus.granted) {
      _location.onLocationChanged.listen((LocationData currentLocation) {
        if (_isPaused) return;
        LatLng currentPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        double? elevation = currentLocation.altitude; // Get elevation
        double speed = 0.0; // Initialize speed

        if (_startPosition == null) {
          // Set the start position
          setState(() {
            _startPosition = currentPosition;
            _startTimestamp =
                currentLocation.time! ~/ 1000; // Use location time!
            _elapsedSeconds = 0;
            _pausedDuration = 0;
            _pauseTimestamp = null;
          });
        }

        if (_lastPosition != null) {
          // Calculate distance between last position and current position
          double distance = _calculateDistance(_lastPosition!, currentPosition);
          totalDistance += distance;

          // Calculate speed (distance/time)
          double timeElapsed =
              currentLocation.time! -
              _routePoints.last['timestamp']; // Time in milliseconds
          speed = (distance / (timeElapsed / 1000)); // Speed in meters/second
        }
        if (mounted) {
          setState(() {
            _lastPosition = currentPosition;
            _routePoints.add({
              'latitude': currentPosition.latitude,
              'longitude': currentPosition.longitude,
              'elevation': elevation ?? 0.0,
              'speed': speed,
              'timestamp': currentLocation.time!, // Time in milliseconds
            });
          });
        }

        // Update map camera position
        _mapController?.animateCamera(CameraUpdate.newLatLng(currentPosition));
      });
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // meters
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLon = _degreesToRadians(end.longitude - start.longitude);

    double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            (sin(dLon / 2) * sin(dLon / 2));

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _saveRunToFirestore() async {
    if (!mounted) return;
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        RunService runService = RunService();
        // await runService.saveRun(
        //   userId: user.uid,
        //   distance: totalDistance,
        //   routePoints:
        //       _routePoints
        //           .map(
        //             (point) => {
        //               'latitude': point['latitude'],
        //               'longitude': point['longitude'],
        //               'elevation': point['elevation'],
        //               'speed': point['speed'],
        //               'timestamp': point['timestamp'],
        //             },
        //           )
        //           .toList(),
        //   speed: _routePoints.isNotEmpty ? _routePoints.last['speed'] : 0.0,
        //   elevation:
        //       _routePoints.isNotEmpty ? _routePoints.last['elevation'] : 0.0,
        //   duration:
        //       _routePoints.isNotEmpty
        //           ? ((_routePoints.last['timestamp'] -
        //                       _routePoints.first['timestamp']) /
        //                   1000)
        //               .toInt() // Ensure duration is an int
        //           : 0, // Duration in seconds
        // );
        print("Run saved successfully!");
      } catch (e) {
        print("Error saving run________________----------------------------");
        print("Error saving run________________: $e");
        print("Error saving run________________----------------------------");
      }
    }
  }

  @override
  void dispose() {
    // Cancel location listener
    _timer?.cancel();
    _locationSubscription?.cancel();
    _locationSubscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: _elapsedSeconds);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Track Your Run",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Image.asset(
              imagePath,
              height: 340,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Text(
            duration.toString().split('.').first,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Speed: ${_routePoints.isNotEmpty ? _routePoints.last['speed'].toStringAsFixed(2) : '0.0'} m/s",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                "Elevation: ${_routePoints.isNotEmpty ? _routePoints.last['elevation'].toStringAsFixed(2) : '0.0'} m",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Spacer(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  setState(() {
                    if (!_isPaused) {
                      _pauseTimestamp =
                          DateTime.now().millisecondsSinceEpoch ~/ 1000;
                    } else {
                      if (_pauseTimestamp != null) {
                        _pausedDuration +=
                            DateTime.now().millisecondsSinceEpoch ~/ 1000 -
                            _pauseTimestamp!;
                      }
                      _pauseTimestamp = null;
                    }
                    _isPaused = !_isPaused;
                  });
                },
                child: Text(_isPaused ? "Resume" : "Pause"),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 4,
                ),
                onPressed: () async {
                  await _saveRunToFirestore();
                  Navigator.pop(context, {
                    "distance": totalDistance,
                    "routePoints": _routePoints,
                  });
                },
                child: Text("End"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
