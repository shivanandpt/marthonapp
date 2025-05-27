import 'package:firebase_auth/firebase_auth.dart';

/// Utility function to check if a user is logged in.
Future<bool> isUserLoggedIn() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}
