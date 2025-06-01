import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String id;
  final String userId;
  final String plan;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.active,
  });

  // Convert Firestore document to SubscriptionModel
  factory SubscriptionModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return SubscriptionModel(
      id: id,
      userId: data['userId'] ?? '',
      plan: data['plan'] ?? 'free',
      startDate:
          data['startDate'] != null
              ? (data['startDate'] as Timestamp).toDate()
              : DateTime.now(),
      endDate:
          data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : DateTime.now().add(Duration(days: 30)),
      active: data['active'] ?? false,
    );
  }

  // Convert SubscriptionModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'plan': plan,
      'startDate': startDate,
      'endDate': endDate,
      'active': active,
    };
  }

  // Create a copy of this SubscriptionModel with updated fields
  SubscriptionModel copyWith({
    String? plan,
    DateTime? startDate,
    DateTime? endDate,
    bool? active,
  }) {
    return SubscriptionModel(
      id: this.id,
      userId: this.userId,
      plan: plan ?? this.plan,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      active: active ?? this.active,
    );
  }
}
