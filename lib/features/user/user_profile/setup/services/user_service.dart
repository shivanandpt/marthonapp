import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/timestamps_model.dart';

/// User Service for all user-related operations using UserModel
class UserService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _usersCollection;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _usersCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'users',
      );

  /// Create new user profile
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).set(user.toFirestore());
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Get user profile by ID
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();

      if (!doc.exists) {
        print('User profile does not exist for: $userId');
        return null;
      }

      if (doc.data() == null) {
        print('User profile data is null for: $userId');
        return null;
      }

      return UserModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Get user by ID (alias for getUserProfile)
  Future<UserModel?> getUserById(String userId) async {
    return getUserProfile(userId);
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      // Update the updatedAt timestamp using the new modular structure
      final updatedUser = user.copyWith(
        timestamps: user.timestamps.copyWith(updatedAt: DateTime.now()),
      );
      await _usersCollection.doc(user.id).update(updatedUser.toFirestore());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Update specific fields in user profile
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Add updatedAt timestamp to updates
      updates['updatedAt'] = Timestamp.now();
      await _usersCollection.doc(userId).update(updates);
    } catch (e) {
      print('Error updating user fields: $e');
      rethrow;
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      print('Error deleting user profile: $e');
      rethrow;
    }
  }

  /// Stream user profile for real-time updates
  Stream<UserModel?> streamUserProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserModel.fromFirestore(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  /// Update user's last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastActiveAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating last active: $e');
      rethrow;
    }
  }

  /// Update user's current plan ID
  Future<void> updateCurrentPlan(String userId, String? planId) async {
    try {
      await _usersCollection.doc(userId).update({
        'currentPlanId': planId,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating current plan: $e');
      rethrow;
    }
  }

  /// Update user's subscription type
  Future<void> updateSubscription(
    String userId,
    String subscriptionType,
  ) async {
    try {
      await _usersCollection.doc(userId).update({
        'subscriptionType': subscriptionType,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  /// Update user's trial status
  Future<void> updateTrialStatus(String userId, bool isTrialExpired) async {
    try {
      await _usersCollection.doc(userId).update({
        'isTrialExpired': isTrialExpired,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating trial status: $e');
      rethrow;
    }
  }

  /// Update user's onboarding completion status
  Future<void> updateOnboardingStatus(String userId, bool hasCompleted) async {
    try {
      await _usersCollection.doc(userId).update({
        'hasCompletedOnboarding': hasCompleted,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating onboarding status: $e');
      rethrow;
    }
  }

  /// Update user's push token
  Future<void> updatePushToken(String userId, String? pushToken) async {
    try {
      await _usersCollection.doc(userId).update({
        'pushToken': pushToken,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating push token: $e');
      rethrow;
    }
  }

  /// Check if user profile exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

  /// Get all users (for admin purposes)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _usersCollection.get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all users: $e');
      rethrow;
    }
  }

  /// Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final querySnapshot =
          await _usersCollection
              .where('name', isGreaterThanOrEqualTo: query)
              .where('name', isLessThanOrEqualTo: query + '\uf8ff')
              .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      rethrow;
    }
  }

  /// Get users by subscription type
  Future<List<UserModel>> getUsersBySubscription(
    String subscriptionType,
  ) async {
    try {
      final querySnapshot =
          await _usersCollection
              .where('subscriptionType', isEqualTo: subscriptionType)
              .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting users by subscription: $e');
      rethrow;
    }
  }

  /// Get users with expired trials
  Future<List<UserModel>> getUsersWithExpiredTrials() async {
    try {
      final querySnapshot =
          await _usersCollection.where('isTrialExpired', isEqualTo: true).get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting users with expired trials: $e');
      rethrow;
    }
  }
}
