// This file is now obsolete. UserProfileService is in lib/features/user_profile/user_profile_service.dart
// Please use UserProfileService directly for user profile operations.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/user_profile.dart';

class UserProfileService {
  final CollectionReference<Map<String, dynamic>> _userref = FirebaseFirestore
      .instance
      .collection('users');

  /// Save user data after login
  Future<void> storeUserProfile(String userId, UserProfile profile) async {
    try {
      await _userref.doc(userId).set(profile.toMap(), SetOptions(merge: true));
      print("User data saved successfully!");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  Future<UserProfile?> fetchUserProfile(String uid) async {
    try {
      DocumentSnapshot userDoc = await _userref.doc(uid).get();
      final data = userDoc.data();
      if (userDoc.exists && data != null && data is Map<String, dynamic>) {
        return UserProfile.fromMap(data);
      } else {
        print('User profile not found for uid: $uid');
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    await _userref.doc(userId).update(updates);
  }

  Future<void> deleteUserProfile(String userId) async {
    await _userref.doc(userId).delete();
  }
}
