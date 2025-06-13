class PreferencesModel {
  final String language; // ISO language code
  final String timezone;
  final String reminderTime; // HH:MM format
  final bool reminderEnabled;
  final bool voiceEnabled;
  final bool vibrationOnly;

  const PreferencesModel({
    this.language = 'en',
    this.timezone = 'UTC',
    this.reminderTime = '08:00',
    this.reminderEnabled = true,
    this.voiceEnabled = false,
    this.vibrationOnly = false,
  });

  factory PreferencesModel.fromMap(Map<String, dynamic> data) {
    return PreferencesModel(
      language: data['language'] ?? 'en',
      timezone: data['timezone'] ?? 'UTC',
      reminderTime: data['reminderTime'] ?? '08:00',
      reminderEnabled: data['reminderEnabled'] ?? true,
      voiceEnabled: data['voiceEnabled'] ?? false,
      vibrationOnly: data['vibrationOnly'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'timezone': timezone,
      'reminderTime': reminderTime,
      'reminderEnabled': reminderEnabled,
      'voiceEnabled': voiceEnabled,
      'vibrationOnly': vibrationOnly,
    };
  }

  PreferencesModel copyWith({
    String? language,
    String? timezone,
    String? reminderTime,
    bool? reminderEnabled,
    bool? voiceEnabled,
    bool? vibrationOnly,
  }) {
    return PreferencesModel(
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      vibrationOnly: vibrationOnly ?? this.vibrationOnly,
    );
  }
}
