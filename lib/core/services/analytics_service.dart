import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log a custom event
  static Future<void> logEvent(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters as Map<String, Object>?,
      );
      print("Event logged: $eventName");
    } catch (e) {
      print("Error logging event: $e");
    }
  }

  /// Set user properties
  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      print("User property set: $name = $value");
    } catch (e) {
      print("Error setting user property: $e");
    }
  }

  /// Track screen views
  static Future<void> setCurrentScreen(String screenName) async {
    try {
      await _analytics.logEvent(
        name: 'screen_view',
        parameters: {'screen_name': screenName},
      );
      print("Screen view logged: $screenName");
    } catch (e) {
      print("Error logging screen view: $e");
    }
  }

  /// Set user ID
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      print("User ID set: $userId");
    } catch (e) {
      print("Error setting user ID: $e");
    }
  }
}
