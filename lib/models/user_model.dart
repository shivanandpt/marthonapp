import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String metricSystem;
  final int weight;
  final int height;
  final String injuryNotes;
  final String goal;
  final DateTime? goalEventDate;
  final int runDaysPerWeek;
  final int age;
  final String gender;
  final String language;
  final String timezone;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final String appVersion;
  final bool isTrialExpired;
  final String subscriptionType;
  final String reminderTime;
  final DateTime? dob;
  final String profilePic;
  final String currentPlanId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.metricSystem = 'metric',
    this.weight = 0,
    this.height = 0,
    this.injuryNotes = '',
    this.goal = '5K',
    this.goalEventDate,
    this.runDaysPerWeek = 3,
    this.age = 0,
    this.gender = '',
    this.language = 'en',
    this.timezone = 'UTC',
    required this.joinedAt,
    required this.lastActiveAt,
    this.appVersion = '',
    this.isTrialExpired = false,
    this.subscriptionType = 'free',
    this.reminderTime = '08:00',
    this.dob,
    this.profilePic = '',
    this.currentPlanId = '',
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      metricSystem: data['metricSystem'] ?? 'metric',
      weight: data['weight'] ?? 0,
      height: data['height'] ?? 0,
      injuryNotes: data['injuryNotes'] ?? '',
      goal: data['goal'] ?? '5K',
      goalEventDate:
          data['goalEventDate'] != null
              ? (data['goalEventDate'] as Timestamp).toDate()
              : null,
      runDaysPerWeek: data['runDaysPerWeek'] ?? 3,
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      language: data['language'] ?? 'en',
      timezone: data['timezone'] ?? 'UTC',
      joinedAt:
          data['joinedAt'] != null
              ? (data['joinedAt'] as Timestamp).toDate()
              : DateTime.now(),
      lastActiveAt:
          data['lastActiveAt'] != null
              ? (data['lastActiveAt'] as Timestamp).toDate()
              : DateTime.now(),
      appVersion: data['appVersion'] ?? '',
      isTrialExpired: data['isTrialExpired'] ?? false,
      subscriptionType: data['subscriptionType'] ?? 'free',
      reminderTime: data['reminderTime'] ?? '08:00',
      dob: data['dob'] != null ? (data['dob'] as Timestamp).toDate() : null,
      profilePic: data['profilePic'] ?? '',
      currentPlanId: data['currentPlanId'] ?? '',
    );
  }

  // Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'metricSystem': metricSystem,
      'weight': weight,
      'height': height,
      'injuryNotes': injuryNotes,
      'goal': goal,
      'goalEventDate': goalEventDate,
      'runDaysPerWeek': runDaysPerWeek,
      'age': age,
      'gender': gender,
      'language': language,
      'timezone': timezone,
      'joinedAt': joinedAt,
      'lastActiveAt': lastActiveAt,
      'appVersion': appVersion,
      'isTrialExpired': isTrialExpired,
      'subscriptionType': subscriptionType,
      'reminderTime': reminderTime,
      'dob': dob,
      'profilePic': profilePic,
      'currentPlanId': currentPlanId,
    };
  }

  // Create a copy of this UserModel with updated fields
  UserModel copyWith({
    String? name,
    String? email,
    String? metricSystem,
    int? weight,
    int? height,
    String? injuryNotes,
    String? goal,
    DateTime? goalEventDate,
    int? runDaysPerWeek,
    int? age,
    String? gender,
    String? language,
    String? timezone,
    DateTime? lastActiveAt,
    String? appVersion,
    bool? isTrialExpired,
    String? subscriptionType,
    String? reminderTime,
    DateTime? dob,
    String? profilePic,
    String? currentPlanId,
  }) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      metricSystem: metricSystem ?? this.metricSystem,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      injuryNotes: injuryNotes ?? this.injuryNotes,
      goal: goal ?? this.goal,
      goalEventDate: goalEventDate ?? this.goalEventDate,
      runDaysPerWeek: runDaysPerWeek ?? this.runDaysPerWeek,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      joinedAt: this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      appVersion: appVersion ?? this.appVersion,
      isTrialExpired: isTrialExpired ?? this.isTrialExpired,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      reminderTime: reminderTime ?? this.reminderTime,
      dob: dob ?? this.dob,
      profilePic: profilePic ?? this.profilePic,
      currentPlanId: currentPlanId ?? this.currentPlanId,
    );
  }
}
