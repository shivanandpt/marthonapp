import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<User?> signInWithGoogle();
  User? getCurrentUser();
  Future<void> signOut();
}
