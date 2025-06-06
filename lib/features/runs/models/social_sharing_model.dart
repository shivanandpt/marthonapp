class SocialSharingModel {
  final bool shared;
  final String? shareUrl;
  final List<String> socialPlatforms; // "facebook", "instagram", "twitter"

  const SocialSharingModel({
    required this.shared,
    this.shareUrl,
    required this.socialPlatforms,
  });

  factory SocialSharingModel.fromMap(Map<String, dynamic> map) {
    return SocialSharingModel(
      shared: map['shared'] ?? false,
      shareUrl: map['shareUrl'],
      socialPlatforms: List<String>.from(map['socialPlatforms'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shared': shared,
      if (shareUrl != null) 'shareUrl': shareUrl,
      'socialPlatforms': socialPlatforms,
    };
  }
}
