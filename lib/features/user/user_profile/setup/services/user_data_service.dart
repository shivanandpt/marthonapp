import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/user_model.dart';
import '../models/basic_info_model.dart';
import '../models/physical_attributes_model.dart';
import '../models/preferences_model.dart';
import '../models/training_preferences_model.dart';
import '../models/subscription_model.dart';
import '../models/social_features_model.dart';
import '../models/app_info_model.dart';
import '../models/timestamps_model.dart';
import 'user_service.dart';

class UserDataService {
  final UserService _userService = UserService();

  Future<UserModel> createUserModel({
    required String userId,
    required String name,
    required String email,
    required String profilePic,
    required String language,
    required DateTime? dob,
    required String goal,
    required DateTime? goalEventDate,
    required String metricSystem,
    required int runDaysPerWeek,
    required int? weight,
    required int? height,
    required String? gender,
    required String? injuryNotes,
    required String? experience,
    required String timezone,
    bool isEditMode = false,
    UserModel? existingUser,
  }) async {
    // Get app version
    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    // Calculate age from DOB
    int calculatedAge = 0;
    if (dob != null) {
      final now = DateTime.now();
      calculatedAge = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        calculatedAge--;
      }
    }

    final now = DateTime.now();

    if (isEditMode && existingUser != null) {
      // Update existing user
      return UserModel(
        id: userId,
        basicInfo: BasicInfoModel(
          name: name,
          email: email,
          profilePic: profilePic,
          dob: dob,
          age: calculatedAge,
          gender: gender ?? '',
        ),
        physicalAttributes: PhysicalAttributesModel(
          metricSystem: metricSystem,
          weight: weight ?? 0,
          height: height ?? 0,
        ),
        preferences: PreferencesModel(
          language: language.toLowerCase() == 'english' ? 'en' : 'es',
          timezone: timezone,
          reminderTime: existingUser.reminderTime,
          reminderEnabled: existingUser.reminderEnabled,
          voiceEnabled: existingUser.voiceEnabled,
          vibrationOnly: existingUser.vibrationOnly,
        ),
        trainingPreferences: TrainingPreferencesModel(
          goal: goal,
          goalEventDate: goalEventDate,
          runDaysPerWeek: runDaysPerWeek,
          injuryNotes: injuryNotes ?? '',
          experience: experience ?? 'beginner',
        ),
        subscription: SubscriptionModel(
          subscriptionType: existingUser.subscriptionType,
          isTrialExpired: existingUser.isTrialExpired,
          trialStartDate: existingUser.trialStartDate,
          trialEndDate: existingUser.trialEndDate,
        ),
        socialFeatures: SocialFeaturesModel(
          shareRuns: existingUser.shareRuns,
          allowFriends: existingUser.allowFriends,
          publicProfile: existingUser.publicProfile,
        ),
        appInfo: AppInfoModel(
          appVersion: appVersion,
          deviceType: existingUser.deviceType,
          pushToken: existingUser.pushToken,
          currentPlanId: existingUser.currentPlanId,
          hasCompletedOnboarding: existingUser.hasCompletedOnboarding,
        ),
        timestamps: TimestampsModel(
          joinedAt: existingUser.joinedAt,
          createdAt: existingUser.createdAt,
          lastActiveAt: now,
          updatedAt: now,
        ),
      );
    } else {
      // Create new user
      return UserModel(
        id: userId,
        basicInfo: BasicInfoModel(
          name: name,
          email: email,
          profilePic: profilePic,
          dob: dob,
          age: calculatedAge,
          gender: gender ?? '',
        ),
        physicalAttributes: PhysicalAttributesModel(
          metricSystem: metricSystem,
          weight: weight ?? 0,
          height: height ?? 0,
        ),
        preferences: PreferencesModel(
          language: language.toLowerCase() == 'english' ? 'en' : 'es',
          timezone: timezone,
          reminderTime: "07:00",
          reminderEnabled: true,
          voiceEnabled: true,
          vibrationOnly: false,
        ),
        trainingPreferences: TrainingPreferencesModel(
          goal: goal,
          goalEventDate: goalEventDate,
          runDaysPerWeek: runDaysPerWeek,
          injuryNotes: injuryNotes ?? '',
          experience: experience ?? 'beginner',
        ),
        subscription: SubscriptionModel(
          subscriptionType: "free",
          isTrialExpired: false,
          trialStartDate: now,
          trialEndDate: now.add(Duration(days: 14)),
        ),
        socialFeatures: SocialFeaturesModel(
          shareRuns: true,
          allowFriends: true,
          publicProfile: false,
        ),
        appInfo: AppInfoModel(
          appVersion: appVersion,
          deviceType: "android",
          pushToken: null,
          currentPlanId: null,
          hasCompletedOnboarding: false,
        ),
        timestamps: TimestampsModel(
          joinedAt: now,
          createdAt: now,
          lastActiveAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<UserModel?> loadUserProfile(String userId) async {
    return await _userService.getUserProfile(userId);
  }

  Future<void> saveUserProfile(
    UserModel user, {
    bool isEditMode = false,
  }) async {
    if (isEditMode) {
      await _userService.updateUserProfile(user);
    } else {
      await _userService.createUserProfile(user);
    }
  }
}
