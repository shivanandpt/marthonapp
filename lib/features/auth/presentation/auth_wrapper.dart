import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marunthon_app/features/auth/presentation/login_page.dart';
import 'package:marunthon_app/features/home/home_page.dart';
import '../../splash_screen/presentation/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/utils/auth_utils.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    bool isLoggedIn = await isUserLoggedIn();
    if (isLoggedIn) {
      // Navigate directly to HomePage if the user is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Show splash screen for 3 seconds, then navigate to login
      Timer(Duration(seconds: 3), () {
        setState(() {
          _showSplash = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return HomePage(); // User is logged in
        }
        return LoginPage(); // Show login screen
      },
    );
  }
}
