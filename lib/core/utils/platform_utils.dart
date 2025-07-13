import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Utility class for platform-specific functionality
class PlatformUtils {
  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  /// Check if running on mobile (iOS or Android)
  static bool get isMobile => isIOS || isAndroid;
  
  /// Check if running on web
  static bool get isWeb => kIsWeb;
  
  /// Get platform name as string
  static String get platformName {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
  
  /// Get platform-specific padding for status bar
  static double get statusBarPadding {
    if (isIOS) return 44.0; // iOS status bar height
    if (isAndroid) return 24.0; // Android status bar height
    return 0.0;
  }
  
  /// Get platform-specific bottom safe area padding
  static double get bottomSafeAreaPadding {
    if (isIOS) return 34.0; // iOS home indicator
    return 0.0; // Android handles this automatically
  }
  
  /// Check if device supports haptic feedback
  static bool get supportsHapticFeedback => isMobile;
  
  /// Check if device supports background app refresh
  static bool get supportsBackgroundRefresh => isMobile;
  
  /// Get platform-specific scroll physics
  static ScrollPhysics get scrollPhysics {
    if (isIOS) {
      return const BouncingScrollPhysics();
    } else {
      return const ClampingScrollPhysics();
    }
  }
}
