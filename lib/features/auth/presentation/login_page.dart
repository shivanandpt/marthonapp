import 'package:flutter/material.dart';
import '../data/firebase_service.dart';
import 'package:marunthon_app/core/services/user_profile_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_prefrences.dart';
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
    String? userId = await UserPreferences.getUserId();
    if (userId != null) {
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

        // Save user data to local preferences
        await UserPreferences.saveUser(
          user.uid,
          user.displayName ?? "Runner",
          user.email ?? "",
        );
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
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}
