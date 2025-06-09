class AppInfoModel {
  final String appVersion;
  final String deviceType; // "ios", "android"
  final String? pushToken;
  final String? currentPlanId;
  final bool hasCompletedOnboarding;

  const AppInfoModel({
    this.appVersion = '',
    this.deviceType = 'android',
    this.pushToken,
    this.currentPlanId,
    this.hasCompletedOnboarding = false,
  });

  factory AppInfoModel.fromMap(Map<String, dynamic> data) {
    return AppInfoModel(
      appVersion: data['appVersion'] ?? '',
      deviceType: data['deviceType'] ?? 'android',
      pushToken: data['pushToken'],
      currentPlanId: data['currentPlanId'],
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appVersion': appVersion,
      'deviceType': deviceType,
      'pushToken': pushToken,
      'currentPlanId': currentPlanId,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  AppInfoModel copyWith({
    String? appVersion,
    String? deviceType,
    String? pushToken,
    String? currentPlanId,
    bool? hasCompletedOnboarding,
  }) {
    return AppInfoModel(
      appVersion: appVersion ?? this.appVersion,
      deviceType: deviceType ?? this.deviceType,
      pushToken: pushToken ?? this.pushToken,
      currentPlanId: currentPlanId ?? this.currentPlanId,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
