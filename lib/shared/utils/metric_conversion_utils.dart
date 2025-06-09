class MetricConversionUtils {
  /// Convert seconds to formatted time string
  static String formatDuration(int seconds, {bool showSeconds = true}) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return showSeconds
          ? '${hours}h ${minutes}m ${remainingSeconds}s'
          : '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return showSeconds ? '${minutes}m ${remainingSeconds}s' : '${minutes}m';
    } else {
      return '${remainingSeconds}s';
    }
  }

  /// Convert meters to appropriate distance format based on metric system
  static String formatDistance(double meters, String metricSystem) {
    if (metricSystem == 'imperial') {
      // Convert to miles
      final miles = meters * 0.000621371;
      if (miles >= 1.0) {
        return '${miles.toStringAsFixed(2)} mi';
      } else {
        // Show in feet for shorter distances
        final feet = meters * 3.28084;
        return '${feet.toStringAsFixed(0)} ft';
      }
    } else {
      // Metric system
      if (meters >= 1000) {
        final km = meters / 1000;
        return '${km.toStringAsFixed(2)} km';
      } else {
        return '${meters.toStringAsFixed(0)} m';
      }
    }
  }

  /// Convert m/s to appropriate speed format based on metric system
  static String formatSpeed(double metersPerSecond, String metricSystem) {
    if (metricSystem == 'imperial') {
      // Convert to mph (miles per hour)
      final mph = metersPerSecond * 2.23694;
      return '${mph.toStringAsFixed(1)} mph';
    } else {
      // Convert to km/h
      final kmh = metersPerSecond * 3.6;
      return '${kmh.toStringAsFixed(1)} km/h';
    }
  }

  /// Convert m/s to pace format (min/km or min/mile) based on metric system
  static String formatPace(double metersPerSecond, String metricSystem) {
    if (metersPerSecond <= 0) return '0:00';

    if (metricSystem == 'imperial') {
      // Convert to min/mile
      final milesPerSecond = metersPerSecond * 0.000621371;
      final secondsPerMile = 1 / milesPerSecond;
      final minutes = (secondsPerMile / 60).floor();
      final seconds = (secondsPerMile % 60).round();
      return '${minutes}:${seconds.toString().padLeft(2, '0')}/mi';
    } else {
      // Convert to min/km
      final kmPerSecond = metersPerSecond / 1000;
      final secondsPerKm = 1 / kmPerSecond;
      final minutes = (secondsPerKm / 60).floor();
      final seconds = (secondsPerKm % 60).round();
      return '${minutes}:${seconds.toString().padLeft(2, '0')}/km';
    }
  }

  /// Get distance unit string based on metric system
  static String getDistanceUnit(String metricSystem, {bool short = false}) {
    if (metricSystem == 'imperial') {
      return short ? 'mi' : 'miles';
    } else {
      return short ? 'km' : 'kilometers';
    }
  }

  /// Get speed unit string based on metric system
  static String getSpeedUnit(String metricSystem) {
    if (metricSystem == 'imperial') {
      return 'mph';
    } else {
      return 'km/h';
    }
  }

  /// Get pace unit string based on metric system
  static String getPaceUnit(String metricSystem) {
    if (metricSystem == 'imperial') {
      return 'min/mi';
    } else {
      return 'min/km';
    }
  }

  /// Convert meters to miles
  static double metersToMiles(double meters) {
    return meters * 0.000621371;
  }

  /// Convert meters to kilometers
  static double metersToKilometers(double meters) {
    return meters / 1000;
  }

  /// Convert meters per second to kilometers per hour
  static double mpsToKmh(double metersPerSecond) {
    return metersPerSecond * 3.6;
  }

  /// Convert meters per second to miles per hour
  static double mpsToMph(double metersPerSecond) {
    return metersPerSecond * 2.23694;
  }

  /// Calculate pace from speed (returns seconds per unit distance)
  static double speedToPace(double metersPerSecond, String metricSystem) {
    if (metersPerSecond <= 0) return 0;

    if (metricSystem == 'imperial') {
      // Seconds per mile
      final milesPerSecond = metersPerSecond * 0.000621371;
      return 1 / milesPerSecond;
    } else {
      // Seconds per kilometer
      final kmPerSecond = metersPerSecond / 1000;
      return 1 / kmPerSecond;
    }
  }

  /// Format weight based on metric system
  static String formatWeight(double weightKg, String metricSystem) {
    if (metricSystem == 'imperial') {
      final lbs = weightKg * 2.20462;
      return '${lbs.toStringAsFixed(1)} lbs';
    } else {
      return '${weightKg.toStringAsFixed(1)} kg';
    }
  }

  /// Format height based on metric system
  static String formatHeight(double heightCm, String metricSystem) {
    if (metricSystem == 'imperial') {
      final totalInches = heightCm / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return '${feet}\'${inches}"';
    } else {
      return '${heightCm.toStringAsFixed(0)} cm';
    }
  }
}
