import 'package:cloud_firestore/cloud_firestore.dart';

class RoutePointModel {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double elevation;
  final double speed;
  final double accuracy; // GPS accuracy in meters

  const RoutePointModel({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.speed,
    required this.accuracy,
  });

  factory RoutePointModel.fromMap(Map<String, dynamic> map) {
    return RoutePointModel(
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      elevation: (map['elevation'] as num?)?.toDouble() ?? 0.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'speed': speed,
      'accuracy': accuracy,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'speed': speed,
      'accuracy': accuracy,
    };
  }

  factory RoutePointModel.fromFirestore(Map<String, dynamic> data) {
    return RoutePointModel(
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      latitude: data['latitude']?.toDouble() ?? 0.0,
      longitude: data['longitude']?.toDouble() ?? 0.0,
      elevation: data['elevation']?.toDouble() ?? 0.0,
      speed: data['speed']?.toDouble() ?? 0.0,
      accuracy: data['accuracy']?.toDouble() ?? 0.0,
    );
  }
}
