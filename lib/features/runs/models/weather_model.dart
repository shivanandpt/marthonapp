class WeatherModel {
  final double temperature; // in Celsius
  final double humidity; // percentage
  final double windSpeed; // km/h
  final String condition; // "sunny", "cloudy", "rainy", etc.

  const WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
  });

  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (map['windSpeed'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'condition': condition,
    };
  }
}
