import 'package:flutter/material.dart';
import 'package:marunthon_app/data/firebase_service.dart';
import 'package:marunthon_app/data/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is already signed in, navigate to the home screen
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            User? user = await _firebaseService.signInWithGoogle();
            if (user != null) {
              await _firestoreService.saveUserData(user);
              Navigator.pushReplacementNamed(context, '/');
            }
          },
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}
