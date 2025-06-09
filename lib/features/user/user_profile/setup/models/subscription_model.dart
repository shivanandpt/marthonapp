import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String subscriptionType; // "free", "monthly", "yearly"
  final bool isTrialExpired;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;

  const SubscriptionModel({
    this.subscriptionType = 'free',
    this.isTrialExpired = false,
    this.trialStartDate,
    this.trialEndDate,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> data) {
    return SubscriptionModel(
      subscriptionType: data['subscriptionType'] ?? 'free',
      isTrialExpired: data['isTrialExpired'] ?? false,
      trialStartDate:
          data['trialStartDate'] != null
              ? (data['trialStartDate'] as Timestamp).toDate()
              : null,
      trialEndDate:
          data['trialEndDate'] != null
              ? (data['trialEndDate'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subscriptionType': subscriptionType,
      'isTrialExpired': isTrialExpired,
      'trialStartDate': trialStartDate,
      'trialEndDate': trialEndDate,
    };
  }

  SubscriptionModel copyWith({
    String? subscriptionType,
    bool? isTrialExpired,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
  }) {
    return SubscriptionModel(
      subscriptionType: subscriptionType ?? this.subscriptionType,
      isTrialExpired: isTrialExpired ?? this.isTrialExpired,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
    );
  }
}
