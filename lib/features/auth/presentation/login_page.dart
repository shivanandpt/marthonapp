import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/firebase_service.dart';
import 'package:marunthon_app/data/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_prefrences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
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
        Map<String, dynamic>? userDoc = await _firestoreService.getUserData(
          user.uid,
        );

        // Save user data locally and to Firestore if needed
        if (userDoc.isEmpty) {
          // New user, save to Firestore
          await _firestoreService.saveUserData(user);
        }

        // Save user data to local preferences
        await UserPreferences.saveUser(
          user.uid,
          user.displayName ?? "Runner",
          user.email ?? "",
        );

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
