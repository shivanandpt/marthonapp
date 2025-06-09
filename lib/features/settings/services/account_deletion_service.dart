import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AccountDeletionService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AccountDeletionService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Deletes all user data and the user account
  Future<void> deleteUserAccount(String userId) async {
    try {
      // Step 1: Delete all user data from Firestore collections
      await _deleteAllUserData(userId);

      // Step 2: Sign out from all sessions
      await _signOutFromAllSessions();

      // Step 3: Delete the Firebase Auth account
      await _deleteFirebaseAuthAccount();
    } catch (e) {
      print('Error during account deletion: $e');
      rethrow;
    }
  }

  /// Deletes all user data from Firebase collections
  Future<void> _deleteAllUserData(String userId) async {
    final batch = _firestore.batch();

    try {
      // Delete from users collection
      await _deleteUserProfile(userId, batch);

      // Delete from runs collection
      await _deleteUserRuns(userId, batch);

      // Delete from training_plans collection
      await _deleteUserTrainingPlans(userId, batch);

      // Delete from settings collection
      await _deleteUserSettings(userId, batch);

      // Execute all deletions in a single batch
      await batch.commit();
      print('Successfully deleted all user data for user: $userId');
    } catch (e) {
      print('Error deleting user data: $e');
      rethrow;
    }
  }

  /// Delete user profile from users collection
  Future<void> _deleteUserProfile(String userId, WriteBatch batch) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      batch.delete(userDoc);
      print('Scheduled deletion of user profile for user: $userId');
    } catch (e) {
      print('Error scheduling user profile deletion: $e');
      rethrow;
    }
  }

  /// Delete all user runs from runs collection
  Future<void> _deleteUserRuns(String userId, WriteBatch batch) async {
    try {
      final runsQuery =
          await _firestore
              .collection('runs')
              .where('userId', isEqualTo: userId)
              .get();

      for (final doc in runsQuery.docs) {
        batch.delete(doc.reference);
      }

      print(
        'Scheduled deletion of ${runsQuery.docs.length} runs for user: $userId',
      );
    } catch (e) {
      print('Error scheduling runs deletion: $e');
      rethrow;
    }
  }

  /// Delete all user training plans and their subcollections
  Future<void> _deleteUserTrainingPlans(String userId, WriteBatch batch) async {
    try {
      final trainingPlansQuery =
          await _firestore
              .collection('training_plans')
              .where('userId', isEqualTo: userId)
              .get();

      for (final planDoc in trainingPlansQuery.docs) {
        // Delete training_days subcollection
        await _deleteTrainingDays(planDoc.reference, batch);

        // Delete the training plan document
        batch.delete(planDoc.reference);
      }

      print(
        'Scheduled deletion of ${trainingPlansQuery.docs.length} training plans for user: $userId',
      );
    } catch (e) {
      print('Error scheduling training plans deletion: $e');
      rethrow;
    }
  }

  /// Delete training days subcollection for a training plan
  Future<void> _deleteTrainingDays(
    DocumentReference planRef,
    WriteBatch batch,
  ) async {
    try {
      final trainingDaysQuery = await planRef.collection('training_days').get();

      for (final dayDoc in trainingDaysQuery.docs) {
        batch.delete(dayDoc.reference);
      }

      print(
        'Scheduled deletion of ${trainingDaysQuery.docs.length} training days',
      );
    } catch (e) {
      print('Error scheduling training days deletion: $e');
      rethrow;
    }
  }

  /// Delete user settings from settings collection
  Future<void> _deleteUserSettings(String userId, WriteBatch batch) async {
    try {
      final settingsDoc = _firestore.collection('settings').doc(userId);
      batch.delete(settingsDoc);
      print('Scheduled deletion of user settings for user: $userId');
    } catch (e) {
      print('Error scheduling user settings deletion: $e');
      rethrow;
    }
  }

  /// Sign out from all sessions
  Future<void> _signOutFromAllSessions() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
      print('Signed out from Google');

      // Sign out from Firebase Auth (this will trigger auth state listeners)
      await _auth.signOut();
      print('Signed out from Firebase Auth');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  /// Delete the Firebase Auth account
  Future<void> _deleteFirebaseAuthAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        print('Successfully deleted Firebase Auth account');
      } else {
        print('No current user to delete');
      }
    } catch (e) {
      print('Error deleting Firebase Auth account: $e');
      // If user needs to re-authenticate, throw a specific error
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        throw FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'Please sign in again to delete your account',
        );
      }
      rethrow;
    }
  }

  /// Re-authenticate user before account deletion (if needed)
  Future<void> reauthenticateUser() async {
    try {
      // Prompt user to sign in again with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Re-authentication cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
      print('User re-authenticated successfully');
    } catch (e) {
      print('Error during re-authentication: $e');
      rethrow;
    }
  }

  /// Check if user needs re-authentication
  bool _isRecentLoginRequired(FirebaseAuthException e) {
    return e.code == 'requires-recent-login';
  }

  /// Delete user account with re-authentication handling
  Future<void> deleteUserAccountWithReauth(String userId) async {
    try {
      await deleteUserAccount(userId);
    } on FirebaseAuthException catch (e) {
      if (_isRecentLoginRequired(e)) {
        // User needs to re-authenticate
        await reauthenticateUser();
        // Try deletion again
        await deleteUserAccount(userId);
      } else {
        rethrow;
      }
    }
  }
}
