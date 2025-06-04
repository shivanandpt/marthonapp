import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingPlanModel {
  final String id;
  final String userId;
  final String goalType;
  final DateTime createdAt;
  final bool custom;
  final int weeks;
  final bool isActive;

  TrainingPlanModel({
    required this.id,
    required this.userId,
    required this.goalType,
    required this.createdAt,
    required this.custom,
    required this.weeks,
    required this.isActive,
  });

  // Convert Firestore document to TrainingPlanModel
  factory TrainingPlanModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return TrainingPlanModel(
      id: id,
      userId: data['userId'] ?? '',
      goalType: data['goalType'] ?? 'general',
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      custom: data['custom'] ?? false,
      weeks: data['weeks'] ?? 12,
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert TrainingPlanModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'goalType': goalType,
      'createdAt': createdAt,
      'custom': custom,
      'weeks': weeks,
      'isActive': isActive,
    };
  }

  // Create a copy of this TrainingPlanModel with updated fields
  TrainingPlanModel copyWith({
    String? goalType,
    DateTime? createdAt,
    bool? custom,
    int? weeks,
    bool? isActive,
  }) {
    return TrainingPlanModel(
      id: this.id,
      userId: this.userId,
      goalType: goalType ?? this.goalType,
      createdAt: createdAt ?? this.createdAt,
      custom: custom ?? this.custom,
      weeks: weeks ?? this.weeks,
      isActive: isActive ?? this.isActive,
    );
  }
}
