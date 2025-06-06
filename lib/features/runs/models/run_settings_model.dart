class RunSettingsModel {
  final bool voiceEnabled;
  final bool vibrationOnly;
  final bool musicPlayed;
  final int pauseCount;

  const RunSettingsModel({
    required this.voiceEnabled,
    required this.vibrationOnly,
    required this.musicPlayed,
    required this.pauseCount,
  });

  factory RunSettingsModel.fromMap(Map<String, dynamic> map) {
    return RunSettingsModel(
      voiceEnabled: map['voiceEnabled'] ?? true,
      vibrationOnly: map['vibrationOnly'] ?? false,
      musicPlayed: map['musicPlayed'] ?? false,
      pauseCount: (map['pauseCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'voiceEnabled': voiceEnabled,
      'vibrationOnly': vibrationOnly,
      'musicPlayed': musicPlayed,
      'pauseCount': pauseCount,
    };
  }
}
