class SocialSharingModel {
  final bool shared; // Keep existing for backward compatibility
  final bool isShared;
  final String? shareUrl;
  final List<String>
  socialPlatforms; // Keep existing for backward compatibility
  final List<String> platforms;
  final DateTime? sharedAt;
  final String visibility;
  final bool allowComments;
  final bool allowLikes;
  final bool shareImage;
  final bool shareRoute;
  final bool shareStats;
  final String? customMessage;
  final List<String> hashtags;
  final List<String> mentions;

  const SocialSharingModel({
    required this.shared,
    required this.isShared,
    this.shareUrl,
    required this.socialPlatforms,
    required this.platforms,
    this.sharedAt,
    required this.visibility,
    required this.allowComments,
    required this.allowLikes,
    required this.shareImage,
    required this.shareRoute,
    required this.shareStats,
    this.customMessage,
    required this.hashtags,
    required this.mentions,
  });

  factory SocialSharingModel.fromMap(Map<String, dynamic> map) {
    return SocialSharingModel(
      shared: map['shared'] ?? map['isShared'] ?? false,
      isShared: map['isShared'] ?? map['shared'] ?? false,
      shareUrl: map['shareUrl'],
      socialPlatforms: List<String>.from(
        map['socialPlatforms'] ?? map['platforms'] ?? [],
      ),
      platforms: List<String>.from(
        map['platforms'] ?? map['socialPlatforms'] ?? [],
      ),
      sharedAt:
          map['sharedAt'] != null ? DateTime.parse(map['sharedAt']) : null,
      visibility: map['visibility'] ?? 'private',
      allowComments: map['allowComments'] ?? false,
      allowLikes: map['allowLikes'] ?? false,
      shareImage: map['shareImage'] ?? false,
      shareRoute: map['shareRoute'] ?? false,
      shareStats: map['shareStats'] ?? false,
      customMessage: map['customMessage'],
      hashtags: List<String>.from(map['hashtags'] ?? []),
      mentions: List<String>.from(map['mentions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shared': shared,
      'isShared': isShared,
      if (shareUrl != null) 'shareUrl': shareUrl,
      'socialPlatforms': socialPlatforms,
      'platforms': platforms,
      if (sharedAt != null) 'sharedAt': sharedAt!.toIso8601String(),
      'visibility': visibility,
      'allowComments': allowComments,
      'allowLikes': allowLikes,
      'shareImage': shareImage,
      'shareRoute': shareRoute,
      'shareStats': shareStats,
      if (customMessage != null) 'customMessage': customMessage,
      'hashtags': hashtags,
      'mentions': mentions,
    };
  }

  // Add a copyWith method for easy updates
  SocialSharingModel copyWith({
    bool? shared,
    bool? isShared,
    String? shareUrl,
    List<String>? socialPlatforms,
    List<String>? platforms,
    DateTime? sharedAt,
    String? visibility,
    bool? allowComments,
    bool? allowLikes,
    bool? shareImage,
    bool? shareRoute,
    bool? shareStats,
    String? customMessage,
    List<String>? hashtags,
    List<String>? mentions,
  }) {
    return SocialSharingModel(
      shared: shared ?? this.shared,
      isShared: isShared ?? this.isShared,
      shareUrl: shareUrl ?? this.shareUrl,
      socialPlatforms: socialPlatforms ?? this.socialPlatforms,
      platforms: platforms ?? this.platforms,
      sharedAt: sharedAt ?? this.sharedAt,
      visibility: visibility ?? this.visibility,
      allowComments: allowComments ?? this.allowComments,
      allowLikes: allowLikes ?? this.allowLikes,
      shareImage: shareImage ?? this.shareImage,
      shareRoute: shareRoute ?? this.shareRoute,
      shareStats: shareStats ?? this.shareStats,
      customMessage: customMessage ?? this.customMessage,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
    );
  }

  // Add a default factory constructor
  factory SocialSharingModel.defaultSettings() {
    return const SocialSharingModel(
      shared: false,
      isShared: false,
      shareUrl: null,
      socialPlatforms: [],
      platforms: [],
      sharedAt: null,
      visibility: 'private',
      allowComments: false,
      allowLikes: false,
      shareImage: false,
      shareRoute: false,
      shareStats: false,
      customMessage: null,
      hashtags: [],
      mentions: [],
    );
  }

  // Helper methods
  bool get hasBeenShared => shared || isShared;

  List<String> get allPlatforms =>
      [...socialPlatforms, ...platforms].toSet().toList();

  bool get isPublic => visibility == 'public';

  bool get allowsInteraction => allowComments || allowLikes;
}
