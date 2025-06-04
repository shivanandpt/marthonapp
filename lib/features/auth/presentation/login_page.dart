import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Make sure this is imported
import '../data/firebase_service.dart';
import 'package:marunthon_app/features/user/user_profile/setup/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    AnalyticsService.setCurrentScreen('LoginPage');
    _checkUser(); // Check if user is already logged in
  }

  void _checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is logged in, check if profile is complete
      await _checkProfileAndNavigate(user);
    }
  }

  Future<void> _checkProfileAndNavigate(User user) async {
    try {
      // First try to get profile from the new UserService
      var userModel = await _userService.getUserProfile(user.uid);

      if (userModel != null) {
        // Profile exists in the new system, check if it's complete
        if (_isProfileComplete(userModel)) {
          // Profile is complete, navigate to home
          if (!mounted) return;
          // FIXED: Using GoRouter instead of Navigator.pushReplacementNamed
          context.go('/');
          return;
        } else {
          // Profile exists but incomplete, navigate to setup flow
          if (!mounted) return;
          _navigateToProfileSetup();
          return;
        }
      }

      // Check old user profile system as fallback
      var oldUserProfile = await _userService.getUserProfile(user.uid);
      if (oldUserProfile != null) {
        // Old profile exists but not migrated to new system
        // Either migrate first or direct to setup
        if (!mounted) return;
        _navigateToProfileSetup();
        return;
      }

      // No profile exists, navigate to profile setup
      if (!mounted) return;
      _navigateToProfileSetup();
    } catch (e) {
      print("Error checking user profile: $e");
      // On error, best to navigate to profile setup
      if (!mounted) return;
      _navigateToProfileSetup();
    }
  }

  bool _isProfileComplete(dynamic userModel) {
    // Define minimal required fields for a complete profile
    return userModel.name.isNotEmpty &&
        userModel.goal.isNotEmpty &&
        userModel.dob != null;
  }

  void _navigateToProfileSetup() {
    // FIXED: Using GoRouter instead of Navigator.pushReplacement
    context.go('/profile-setup');
  }

  Future<void> _handleSignIn() async {
    User? user = await _firebaseService.signInWithGoogle();
    if (user != null) {
      try {
        // Log analytics event
        AnalyticsService.logEvent('login', {'method': '_handleSignIn'});

        // Check if user already exists in the new system
        var userModel = await _userService.getUserProfile(user.uid);

        if (userModel != null && _isProfileComplete(userModel)) {
          // User exists with complete profile, go to home
          AnalyticsService.setCurrentScreen('HomePage');
          // FIXED: Using GoRouter instead of Navigator.pushReplacementNamed
          context.go('/');
          return;
        }

        // Regardless of old profile, direct to new profile setup
        _navigateToProfileSetup();
      } catch (e) {
        print("Error processing user data: $e");
        // On error, try to proceed to profile setup
        _navigateToProfileSetup();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Existing build method remains unchanged
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo above the button
            SizedBox(
              width: 240,
              height: 240,
              child: Image.asset(
                'assets/app_icon/run_mate.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleSignIn,
                child: const Text("Sign in with Google"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
