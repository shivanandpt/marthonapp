class PhysicalAttributesModel {
  final String metricSystem; // "metric" or "imperial"
  final int weight; // in grams for metric, ounces for imperial
  final int height; // in cm for metric, inches for imperial

  const PhysicalAttributesModel({
    this.metricSystem = 'metric',
    this.weight = 0,
    this.height = 0,
  });

  factory PhysicalAttributesModel.fromMap(Map<String, dynamic> data) {
    return PhysicalAttributesModel(
      metricSystem: data['metricSystem'] ?? 'metric',
      weight: data['weight'] ?? 0,
      height: data['height'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'metricSystem': metricSystem, 'weight': weight, 'height': height};
  }

  PhysicalAttributesModel copyWith({
    String? metricSystem,
    int? weight,
    int? height,
  }) {
    return PhysicalAttributesModel(
      metricSystem: metricSystem ?? this.metricSystem,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }
}
