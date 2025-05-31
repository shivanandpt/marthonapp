import 'package:flutter/material.dart';
import '../data/firebase_service.dart';
import 'package:marunthon_app/core/services/user_profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import 'package:marunthon_app/models/user_profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final UserProfileService _userService = UserProfileService();

  @override
  void initState() {
    super.initState();
    AnalyticsService.setCurrentScreen('LoginPage');
    _checkUser(); // Check if user is already logged in
  }

  void _checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user data exists locally, navigate to the home screen
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _handleSignIn() async {
    User? user = await _firebaseService.signInWithGoogle();
    if (user != null) {
      try {
        // Check if user already exists in Firestore
        var userDoc = await _userService.fetchUserProfile(user.uid);

        // Save user data locally and to Firestore if needed
        if (userDoc == null) {
          // New user, save to Firestore
          await _userService.storeUserProfile(
            user.uid,
            UserProfile(
              name: user.displayName ?? "Runner",
              email: user.email ?? "",
              profilePicPath: user.photoURL ?? "",
            ),
          );
        }
        AnalyticsService.logEvent('login', {'method': '_handleSignIn'});
        AnalyticsService.setCurrentScreen('HomePage');
        // Navigate to the home screen
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        print("Error saving user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to white
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo above the button
            SizedBox(
              width: 240, // Doubled from 120 to 240
              height: 240, // Doubled from 120 to 240
              child: Image.asset(
                'assets/app_icon/run_mate.png', // Update path if needed
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 220, // Make button a bit smaller
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
