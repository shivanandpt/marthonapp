import 'package:cloud_firestore/cloud_firestore.dart';

class BadgeModel {
  final String id;
  final String userId;
  final String name;
  final DateTime earnedAt;

  BadgeModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.earnedAt,
  });

  // Convert Firestore document to BadgeModel
  factory BadgeModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BadgeModel(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      earnedAt:
          data['earnedAt'] != null
              ? (data['earnedAt'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  // Convert BadgeModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {'userId': userId, 'name': name, 'earnedAt': earnedAt};
  }
}
