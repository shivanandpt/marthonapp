class RunSettingsModel {
  final bool voiceEnabled;
  final bool vibrationOnly;
  final bool musicPlayed;
  final int pauseCount;
  final bool autoLap;
  final double lapDistance;
  final bool gpsEnabled;
  final bool audioEnabled;
  final bool voiceGuidance;
  final bool screenAlwaysOn;
  final bool pauseOnStop;
  final String unitSystem;
  final String distanceUnit;
  final String paceUnit;
  final String temperatureUnit;
  final bool notifications;
  final bool vibration;
  final bool coaching;
  final bool autoStart;
  final bool autoPause;
  final int countdownDuration;
  final double? targetPace;
  final List<double> powerZones;
  final List<String> customFields;
  final String privacy;
  final bool dataSharing;

  const RunSettingsModel({
    required this.voiceEnabled,
    required this.vibrationOnly,
    required this.musicPlayed,
    required this.pauseCount,
    required this.autoLap,
    required this.lapDistance,
    required this.gpsEnabled,
    required this.audioEnabled,
    required this.voiceGuidance,
    required this.screenAlwaysOn,
    required this.pauseOnStop,
    required this.unitSystem,
    required this.distanceUnit,
    required this.paceUnit,
    required this.temperatureUnit,
    required this.notifications,
    required this.vibration,
    required this.coaching,
    required this.autoStart,
    required this.autoPause,
    required this.countdownDuration,
    this.targetPace,
    required this.powerZones,
    required this.customFields,
    required this.privacy,
    required this.dataSharing,
  });

  factory RunSettingsModel.fromMap(Map<String, dynamic> map) {
    return RunSettingsModel(
      voiceEnabled: map['voiceEnabled'] ?? true,
      vibrationOnly: map['vibrationOnly'] ?? false,
      musicPlayed: map['musicPlayed'] ?? false,
      pauseCount: (map['pauseCount'] as num?)?.toInt() ?? 0,
      autoLap: map['autoLap'] ?? false,
      lapDistance: (map['lapDistance'] as num?)?.toDouble() ?? 1.0,
      gpsEnabled: map['gpsEnabled'] ?? true,
      audioEnabled: map['audioEnabled'] ?? true,
      voiceGuidance: map['voiceGuidance'] ?? true,
      screenAlwaysOn: map['screenAlwaysOn'] ?? true,
      pauseOnStop: map['pauseOnStop'] ?? true,
      unitSystem: map['unitSystem'] ?? 'metric',
      distanceUnit: map['distanceUnit'] ?? 'km',
      paceUnit: map['paceUnit'] ?? 'min/km',
      temperatureUnit: map['temperatureUnit'] ?? 'celsius',
      notifications: map['notifications'] ?? true,
      vibration: map['vibration'] ?? true,
      coaching: map['coaching'] ?? false,
      autoStart: map['autoStart'] ?? false,
      autoPause: map['autoPause'] ?? true,
      countdownDuration: (map['countdownDuration'] as num?)?.toInt() ?? 3,
      targetPace: (map['targetPace'] as num?)?.toDouble(),
      powerZones:
          map['powerZones'] != null
              ? List<double>.from(
                map['powerZones'].map((x) => (x as num).toDouble()),
              )
              : const [],
      customFields:
          map['customFields'] != null
              ? List<String>.from(map['customFields'])
              : const [],
      privacy: map['privacy'] ?? 'private',
      dataSharing: map['dataSharing'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'voiceEnabled': voiceEnabled,
      'vibrationOnly': vibrationOnly,
      'musicPlayed': musicPlayed,
      'pauseCount': pauseCount,
      'autoLap': autoLap,
      'lapDistance': lapDistance,
      'gpsEnabled': gpsEnabled,
      'audioEnabled': audioEnabled,
      'voiceGuidance': voiceGuidance,
      'screenAlwaysOn': screenAlwaysOn,
      'pauseOnStop': pauseOnStop,
      'unitSystem': unitSystem,
      'distanceUnit': distanceUnit,
      'paceUnit': paceUnit,
      'temperatureUnit': temperatureUnit,
      'notifications': notifications,
      'vibration': vibration,
      'coaching': coaching,
      'autoStart': autoStart,
      'autoPause': autoPause,
      'countdownDuration': countdownDuration,
      'targetPace': targetPace,
      'powerZones': powerZones,
      'customFields': customFields,
      'privacy': privacy,
      'dataSharing': dataSharing,
    };
  }

  // Add a copyWith method for easy updates
  RunSettingsModel copyWith({
    bool? voiceEnabled,
    bool? vibrationOnly,
    bool? musicPlayed,
    int? pauseCount,
    bool? autoLap,
    double? lapDistance,
    bool? gpsEnabled,
    bool? audioEnabled,
    bool? voiceGuidance,
    bool? screenAlwaysOn,
    bool? pauseOnStop,
    String? unitSystem,
    String? distanceUnit,
    String? paceUnit,
    String? temperatureUnit,
    bool? notifications,
    bool? vibration,
    bool? coaching,
    bool? autoStart,
    bool? autoPause,
    int? countdownDuration,
    double? targetPace,
    List<double>? powerZones,
    List<String>? customFields,
    String? privacy,
    bool? dataSharing,
  }) {
    return RunSettingsModel(
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      vibrationOnly: vibrationOnly ?? this.vibrationOnly,
      musicPlayed: musicPlayed ?? this.musicPlayed,
      pauseCount: pauseCount ?? this.pauseCount,
      autoLap: autoLap ?? this.autoLap,
      lapDistance: lapDistance ?? this.lapDistance,
      gpsEnabled: gpsEnabled ?? this.gpsEnabled,
      audioEnabled: audioEnabled ?? this.audioEnabled,
      voiceGuidance: voiceGuidance ?? this.voiceGuidance,
      screenAlwaysOn: screenAlwaysOn ?? this.screenAlwaysOn,
      pauseOnStop: pauseOnStop ?? this.pauseOnStop,
      unitSystem: unitSystem ?? this.unitSystem,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      paceUnit: paceUnit ?? this.paceUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      notifications: notifications ?? this.notifications,
      vibration: vibration ?? this.vibration,
      coaching: coaching ?? this.coaching,
      autoStart: autoStart ?? this.autoStart,
      autoPause: autoPause ?? this.autoPause,
      countdownDuration: countdownDuration ?? this.countdownDuration,
      targetPace: targetPace ?? this.targetPace,
      powerZones: powerZones ?? this.powerZones,
      customFields: customFields ?? this.customFields,
      privacy: privacy ?? this.privacy,
      dataSharing: dataSharing ?? this.dataSharing,
    );
  }

  // Add a default factory constructor
  factory RunSettingsModel.defaultSettings() {
    return const RunSettingsModel(
      voiceEnabled: true,
      vibrationOnly: false,
      musicPlayed: false,
      pauseCount: 0,
      autoLap: false,
      lapDistance: 1.0,
      gpsEnabled: true,
      audioEnabled: true,
      voiceGuidance: true,
      screenAlwaysOn: true,
      pauseOnStop: true,
      unitSystem: 'metric',
      distanceUnit: 'km',
      paceUnit: 'min/km',
      temperatureUnit: 'celsius',
      notifications: true,
      vibration: true,
      coaching: false,
      autoStart: false,
      autoPause: true,
      countdownDuration: 3,
      targetPace: null,
      powerZones: [],
      customFields: [],
      privacy: 'private',
      dataSharing: false,
    );
  }
}
