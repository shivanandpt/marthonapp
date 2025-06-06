import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import 'package:marunthon_app/features/runs/services/run_service.dart';
import 'package:marunthon_app/features/runs/run_list/run_list_screen.dart';

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
          _navigateToMyRuns(context);
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

  static Future<void> _navigateToMyRuns(BuildContext context) async {
    BuildContext? dialogContext;

    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not authenticated');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to view your runs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator and store the context returned from showDialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          dialogContext = ctx;
          return const Dialog(
            backgroundColor: Colors.transparent,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );

      // Fetch user runs
      final runService = RunService();
      final runs = await runService.getUserRuns(user.uid);

      // Hide loading indicator using the stored dialog context
      print('dialogContext mounted: ${dialogContext?.mounted}');
      print('original context mounted: ${context.mounted}');

      if (dialogContext != null && dialogContext!.mounted) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
        print('Dialog dismissed successfully');
      } else {
        print('Warning: Dialog context is null or not mounted');
        // Fallback: try to dismiss using the original context
        if (context.mounted) {
          try {
            Navigator.of(context, rootNavigator: true).pop();
            print('Dialog dismissed using fallback method');
          } catch (e) {
            print('Failed to dismiss dialog with fallback: $e');
          }
        }
      }

      // Small delay to ensure dialog is properly dismissed
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate to run list screen using dialog context if original context is not mounted
      BuildContext? navContext = context.mounted ? context : dialogContext;

      print(
        'Attempting navigation with context mounted: ${navContext?.mounted}',
      );

      if (navContext != null && navContext.mounted) {
        print('Navigating to RunListScreen with ${runs.length} runs');
        Navigator.push(
          navContext,
          MaterialPageRoute(
            builder:
                (context) => RunListScreen(
                  runs: runs,
                  onDelete: (String runId) async {
                    try {
                      await runService.deleteRun(runId);
                      print('Run deleted: $runId');
                      // Optionally refresh the screen or show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Run deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      print('Error deleting run: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete run: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
          ),
        );
      } else {
        print('Error: No valid context available for navigation');
      }
    } catch (e) {
      print('Error navigating to My Runs: $e');

      // Hide loading indicator if still showing
      if (dialogContext != null && dialogContext!.mounted) {
        try {
          Navigator.of(dialogContext!, rootNavigator: true).pop();
        } catch (popError) {
          print('Error dismissing dialog: $popError');
        }
      } else if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (popError) {
          print('Error dismissing dialog with fallback: $popError');
        }
      }

      // Show error message using any available context
      BuildContext? errorContext = context.mounted ? context : dialogContext;
      if (errorContext != null && errorContext.mounted) {
        ScaffoldMessenger.of(errorContext).showSnackBar(
          SnackBar(
            content: Text('Failed to load runs: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
