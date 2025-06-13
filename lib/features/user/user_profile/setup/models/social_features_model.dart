class SocialFeaturesModel {
  final bool shareRuns;
  final bool allowFriends;
  final bool publicProfile;

  const SocialFeaturesModel({
    this.shareRuns = false,
    this.allowFriends = true,
    this.publicProfile = false,
  });

  factory SocialFeaturesModel.fromMap(Map<String, dynamic> data) {
    return SocialFeaturesModel(
      shareRuns: data['shareRuns'] ?? false,
      allowFriends: data['allowFriends'] ?? true,
      publicProfile: data['publicProfile'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shareRuns': shareRuns,
      'allowFriends': allowFriends,
      'publicProfile': publicProfile,
    };
  }

  SocialFeaturesModel copyWith({
    bool? shareRuns,
    bool? allowFriends,
    bool? publicProfile,
  }) {
    return SocialFeaturesModel(
      shareRuns: shareRuns ?? this.shareRuns,
      allowFriends: allowFriends ?? this.allowFriends,
      publicProfile: publicProfile ?? this.publicProfile,
    );
  }
}
