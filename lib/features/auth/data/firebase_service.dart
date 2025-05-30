import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/auth_repository.dart';

class FirebaseService implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign in with Google
  @override
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Sign out
  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current user
  @override
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
