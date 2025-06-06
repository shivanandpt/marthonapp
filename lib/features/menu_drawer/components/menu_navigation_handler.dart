import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';

class MenuNavigationHandler {
  static void handleMenuItemTap(BuildContext context, String item) {
    print("Tapped on $item");

    switch (item) {
      case 'Home':
        if (context.mounted) {
          Navigator.of(context).pop(); // Close drawer
          AnalyticsService.setCurrentScreen('HomePage');
          context.go('/');
        }
        break;
      case 'Profile':
        if (context.mounted) {
          Navigator.of(context).pop(); // Close drawer
          context.go('/profile');
        }
        break;
      case 'My Runs':
        if (context.mounted) {
          Navigator.of(context).pop(); // Close drawer
          context.go('/my-runs');
        }
        break;
      case 'Settings':
        if (context.mounted) {
          Navigator.of(context).pop(); // Close drawer
          context.go('/settings');
        }
        break;
      case 'About':
        if (context.mounted) {
          Navigator.of(context).pop(); // Close drawer
          context.go('/about');
        }
        break;
      default:
        print("Unknown menu item: $item");
    }
  }
}
