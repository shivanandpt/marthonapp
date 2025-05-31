import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marunthon_app/features/auth/presentation/login_page.dart';
import 'package:marunthon_app/features/home/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
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
