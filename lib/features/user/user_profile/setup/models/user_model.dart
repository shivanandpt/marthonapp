import 'package:cloud_firestore/cloud_firestore.dart';
import 'basic_info_model.dart';
import 'physical_attributes_model.dart';
import 'preferences_model.dart';
import 'training_preferences_model.dart';
import 'subscription_model.dart';
import 'social_features_model.dart';
import 'app_info_model.dart';
import 'timestamps_model.dart';

class UserModel {
  final String id;
  final BasicInfoModel basicInfo;
  final PhysicalAttributesModel physicalAttributes;
  final PreferencesModel preferences;
  final TrainingPreferencesModel trainingPreferences;
  final SubscriptionModel subscription;
  final SocialFeaturesModel socialFeatures;
  final AppInfoModel appInfo;
  final TimestampsModel timestamps;

  const UserModel({
    required this.id,
    required this.basicInfo,
    required this.physicalAttributes,
    required this.preferences,
    required this.trainingPreferences,
    required this.subscription,
    required this.socialFeatures,
    required this.appInfo,
    required this.timestamps,
  });

  // Convenience getters for backward compatibility
  String get name => basicInfo.name;
  String get email => basicInfo.email;
  DateTime? get dob => basicInfo.dob;
  int get age => basicInfo.age;
  String get gender => basicInfo.gender;
  String get profilePic => basicInfo.profilePic;
  String get metricSystem => physicalAttributes.metricSystem;
  int get weight => physicalAttributes.weight;
  int get height => physicalAttributes.height;
  String get language => preferences.language;
  String get timezone => preferences.timezone;
  String get reminderTime => preferences.reminderTime;
  bool get reminderEnabled => preferences.reminderEnabled;
  bool get voiceEnabled => preferences.voiceEnabled;
  bool get vibrationOnly => preferences.vibrationOnly;
  String get injuryNotes => trainingPreferences.injuryNotes;
  String get goal => trainingPreferences.goal;
  DateTime? get goalEventDate => trainingPreferences.goalEventDate;
  int get runDaysPerWeek => trainingPreferences.runDaysPerWeek;
  String get experience => trainingPreferences.experience;
  String get subscriptionType => subscription.subscriptionType;
  bool get isTrialExpired => subscription.isTrialExpired;
  DateTime? get trialStartDate => subscription.trialStartDate;
  DateTime? get trialEndDate => subscription.trialEndDate;
  String? get currentPlanId => appInfo.currentPlanId;
  bool get hasCompletedOnboarding => appInfo.hasCompletedOnboarding;
  bool get shareRuns => socialFeatures.shareRuns;
  bool get allowFriends => socialFeatures.allowFriends;
  bool get publicProfile => socialFeatures.publicProfile;
  String get appVersion => appInfo.appVersion;
  String get deviceType => appInfo.deviceType;
  String? get pushToken => appInfo.pushToken;
  DateTime get joinedAt => timestamps.joinedAt;
  DateTime get lastActiveAt => timestamps.lastActiveAt;
  DateTime get createdAt => timestamps.createdAt;
  DateTime get updatedAt => timestamps.updatedAt;

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      basicInfo: BasicInfoModel.fromMap(data),
      physicalAttributes: PhysicalAttributesModel.fromMap(data),
      preferences: PreferencesModel.fromMap(data),
      trainingPreferences: TrainingPreferencesModel.fromMap(data),
      subscription: SubscriptionModel.fromMap(data),
      socialFeatures: SocialFeaturesModel.fromMap(data),
      appInfo: AppInfoModel.fromMap(data),
      timestamps: TimestampsModel.fromMap(data),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      ...basicInfo.toMap(),
      ...physicalAttributes.toMap(),
      ...preferences.toMap(),
      ...trainingPreferences.toMap(),
      ...subscription.toMap(),
      ...socialFeatures.toMap(),
      ...appInfo.toMap(),
      ...timestamps.toMap(),
    };
  }

  UserModel copyWith({
    BasicInfoModel? basicInfo,
    PhysicalAttributesModel? physicalAttributes,
    PreferencesModel? preferences,
    TrainingPreferencesModel? trainingPreferences,
    SubscriptionModel? subscription,
    SocialFeaturesModel? socialFeatures,
    AppInfoModel? appInfo,
    TimestampsModel? timestamps,
  }) {
    return UserModel(
      id: id,
      basicInfo: basicInfo ?? this.basicInfo,
      physicalAttributes: physicalAttributes ?? this.physicalAttributes,
      preferences: preferences ?? this.preferences,
      trainingPreferences: trainingPreferences ?? this.trainingPreferences,
      subscription: subscription ?? this.subscription,
      socialFeatures: socialFeatures ?? this.socialFeatures,
      appInfo: appInfo ?? this.appInfo,
      timestamps: timestamps ?? this.timestamps,
    );
  }

  // Convenience copyWith methods for individual fields
  UserModel copyWithBasicInfo({
    String? name,
    String? email,
    DateTime? dob,
    int? age,
    String? gender,
    String? profilePic,
  }) {
    return copyWith(
      basicInfo: basicInfo.copyWith(
        name: name,
        email: email,
        dob: dob,
        age: age,
        gender: gender,
        profilePic: profilePic,
      ),
    );
  }

  UserModel copyWithUpdatedAt(DateTime updatedAt) {
    return copyWith(timestamps: timestamps.copyWith(updatedAt: updatedAt));
  }
}
