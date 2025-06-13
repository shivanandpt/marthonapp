import 'package:cloud_firestore/cloud_firestore.dart';

class TimestampsModel {
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimestampsModel({
    required this.joinedAt,
    required this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimestampsModel.fromMap(Map<String, dynamic> data) {
    final now = DateTime.now();
    return TimestampsModel(
      joinedAt:
          data['joinedAt'] != null
              ? (data['joinedAt'] as Timestamp).toDate()
              : now,
      lastActiveAt:
          data['lastActiveAt'] != null
              ? (data['lastActiveAt'] as Timestamp).toDate()
              : now,
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : now,
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'joinedAt': joinedAt,
      'lastActiveAt': lastActiveAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  TimestampsModel copyWith({
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimestampsModel(
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
