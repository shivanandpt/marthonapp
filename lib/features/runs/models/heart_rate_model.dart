class HeartRateZones {
  final int zone1; // seconds in each heart rate zone
  final int zone2;
  final int zone3;
  final int zone4;
  final int zone5;

  const HeartRateZones({
    required this.zone1,
    required this.zone2,
    required this.zone3,
    required this.zone4,
    required this.zone5,
  });

  factory HeartRateZones.fromMap(Map<String, dynamic> map) {
    return HeartRateZones(
      zone1: (map['zone1'] as num?)?.toInt() ?? 0,
      zone2: (map['zone2'] as num?)?.toInt() ?? 0,
      zone3: (map['zone3'] as num?)?.toInt() ?? 0,
      zone4: (map['zone4'] as num?)?.toInt() ?? 0,
      zone5: (map['zone5'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'zone1': zone1,
      'zone2': zone2,
      'zone3': zone3,
      'zone4': zone4,
      'zone5': zone5,
    };
  }
}

class HeartRateModel {
  final int avg;
  final int max;
  final int min;
  final HeartRateZones zones;

  const HeartRateModel({
    required this.avg,
    required this.max,
    required this.min,
    required this.zones,
  });

  factory HeartRateModel.fromMap(Map<String, dynamic> map) {
    return HeartRateModel(
      avg: (map['avg'] as num?)?.toInt() ?? 0,
      max: (map['max'] as num?)?.toInt() ?? 0,
      min: (map['min'] as num?)?.toInt() ?? 0,
      zones: HeartRateZones.fromMap(map['zones'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {'avg': avg, 'max': max, 'min': min, 'zones': zones.toMap()};
  }
}
