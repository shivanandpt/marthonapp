import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/badge_model.dart';

class BadgeService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _badgesCollection;

  BadgeService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _badgesCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'badges',
      );

  // Create new badge
  Future<String> createBadge(BadgeModel badge) async {
    try {
      final docRef = await _badgesCollection.add(badge.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating badge: $e');
      rethrow;
    }
  }

  // Get badge by ID
  Future<BadgeModel?> getBadge(String badgeId) async {
    try {
      final docSnapshot = await _badgesCollection.doc(badgeId).get();
      if (docSnapshot.exists) {
        return BadgeModel.fromFirestore(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      print('Error getting badge: $e');
      rethrow;
    }
  }

  // Get all badges for a user
  Future<List<BadgeModel>> getUserBadges(String userId) async {
    try {
      final querySnapshot =
          await _badgesCollection
              .where('userId', isEqualTo: userId)
              .orderBy('earnedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => BadgeModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user badges: $e');
      rethrow;
    }
  }

  // Check if user has a specific badge
  Future<bool> userHasBadge(String userId, String badgeName) async {
    try {
      final querySnapshot =
          await _badgesCollection
              .where('userId', isEqualTo: userId)
              .where('name', isEqualTo: badgeName)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if user has badge: $e');
      rethrow;
    }
  }

  // Delete badge
  Future<void> deleteBadge(String badgeId) async {
    try {
      await _badgesCollection.doc(badgeId).delete();
    } catch (e) {
      print('Error deleting badge: $e');
      rethrow;
    }
  }

  // Stream user badges for real-time updates
  Stream<List<BadgeModel>> streamUserBadges(String userId) {
    return _badgesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('earnedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => BadgeModel.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Award a badge to a user if they don't already have it
  Future<String?> awardBadgeIfNotExists(String userId, String badgeName) async {
    try {
      // Check if user already has this badge
      bool hasBadge = await userHasBadge(userId, badgeName);

      if (!hasBadge) {
        // Create a new badge for the user
        BadgeModel badge = BadgeModel(
          id: '', // Will be set by Firestore
          userId: userId,
          name: badgeName,
          earnedAt: DateTime.now(),
        );

        String badgeId = await createBadge(badge);
        return badgeId;
      }

      return null; // User already has this badge
    } catch (e) {
      print('Error awarding badge: $e');
      rethrow;
    }
  }
}
