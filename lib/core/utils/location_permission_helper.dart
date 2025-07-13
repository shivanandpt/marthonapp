import 'package:geolocator/geolocator.dart';

/// Helper class for managing location permissions and services
class LocationPermissionHelper {
  /// Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  /// Check current location permission status
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }
  
  /// Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }
  
  /// Check if we have sufficient permission to track location
  static Future<bool> hasLocationPermission() async {
    final permission = await checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }
  
  /// Open device settings for location permissions
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
  
  /// Open app-specific settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
  
  /// Get a user-friendly permission status message
  static String getPermissionMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission was denied. Please enable location access to track your runs.';
      case LocationPermission.deniedForever:
        return 'Location permissions are permanently denied. Please go to app settings to enable location access.';
      case LocationPermission.whileInUse:
        return 'Location permission granted for app usage.';
      case LocationPermission.always:
        return 'Location permission granted for background tracking.';
      case LocationPermission.unableToDetermine:
        return 'Unable to determine location permission status.';
    }
  }
  
  /// Comprehensive permission check and request flow
  static Future<LocationPermissionResult> checkAndRequestPermission() async {
    // Check if location services are enabled
    if (!await isLocationServiceEnabled()) {
      return LocationPermissionResult(
        isGranted: false,
        message: 'Location services are disabled. Please enable location services in your device settings.',
        action: LocationPermissionAction.enableLocationServices,
      );
    }
    
    // Check current permission
    LocationPermission permission = await checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await requestPermission();
    }
    
    if (permission == LocationPermission.denied) {
      return LocationPermissionResult(
        isGranted: false,
        message: 'Location permission was denied. Please enable location access in your device settings.',
        action: LocationPermissionAction.openAppSettings,
      );
    }
    
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionResult(
        isGranted: false,
        message: 'Location permissions are permanently denied. Please go to app settings to enable location access.',
        action: LocationPermissionAction.openAppSettings,
      );
    }
    
    // Test if we can actually get location
    try {
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      return LocationPermissionResult(
        isGranted: true,
        message: 'Location permission granted successfully.',
        action: LocationPermissionAction.none,
      );
    } catch (e) {
      return LocationPermissionResult(
        isGranted: false,
        message: 'Unable to get your current location. Please check that location services are enabled and try again.',
        action: LocationPermissionAction.enableLocationServices,
      );
    }
  }
}

/// Result of location permission check
class LocationPermissionResult {
  final bool isGranted;
  final String message;
  final LocationPermissionAction action;
  
  const LocationPermissionResult({
    required this.isGranted,
    required this.message,
    required this.action,
  });
}

/// Actions that can be taken for location permissions
enum LocationPermissionAction {
  none,
  enableLocationServices,
  openAppSettings,
}
