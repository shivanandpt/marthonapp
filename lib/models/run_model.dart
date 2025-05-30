import 'package:cloud_firestore/cloud_firestore.dart';

class RunModel {
  final String id;
  final String userId;
  final double distance;
  final double speed;
  final double elevation;
  final int duration;
  final List<Map<String, dynamic>> routePoints;
  final DateTime timestamp;

  RunModel({
    required this.id,
    required this.userId,
    required this.distance,
    required this.speed,
    required this.elevation,
    required this.duration,
    required this.routePoints,
    required this.timestamp,
  });

  // Convert Firestore document to RunModel
  factory RunModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RunModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      distance: (data['distance'] ?? 0.0).toDouble(),
      speed: (data['speed'] ?? 0.0).toDouble(),
      elevation: (data['elevation'] ?? 0.0).toDouble(),
      duration: (data['duration'] ?? 0).toInt(),
      routePoints: List<Map<String, dynamic>>.from(data['routePoints'] ?? []),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert RunModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'distance': distance,
      'speed': speed,
      'elevation': elevation,
      'duration': duration,
      'routePoints': routePoints,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
