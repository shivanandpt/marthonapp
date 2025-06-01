import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _usersCollection;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _usersCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'users',
      );

  // Create new user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toFirestore());
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile by ID
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();
      if (docSnapshot.exists) {
        return UserModel.fromFirestore(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toFirestore());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      rethrow;
    }
  }

  // Stream user profile for real-time updates
  Stream<UserModel?> streamUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return UserModel.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  // Update user's last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last active: $e');
      rethrow;
    }
  }

  // Update user's current plan ID
  Future<void> updateCurrentPlan(String userId, String planId) async {
    try {
      await _usersCollection.doc(userId).update({'currentPlanId': planId});
    } catch (e) {
      print('Error updating current plan: $e');
      rethrow;
    }
  }
}
