import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _subscriptionsCollection;

  SubscriptionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _subscriptionsCollection = (firestore ?? FirebaseFirestore.instance)
          .collection('subscriptions');

  // Create new subscription
  Future<String> createSubscription(SubscriptionModel subscription) async {
    try {
      final docRef = await _subscriptionsCollection.add(
        subscription.toFirestore(),
      );
      return docRef.id;
    } catch (e) {
      print('Error creating subscription: $e');
      rethrow;
    }
  }

  // Get subscription by ID
  Future<SubscriptionModel?> getSubscription(String subscriptionId) async {
    try {
      final docSnapshot =
          await _subscriptionsCollection.doc(subscriptionId).get();
      if (docSnapshot.exists) {
        return SubscriptionModel.fromFirestore(
          docSnapshot.data()!,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting subscription: $e');
      rethrow;
    }
  }

  // Get subscription by user ID
  Future<SubscriptionModel?> getSubscriptionByUserId(String userId) async {
    try {
      final querySnapshot =
          await _subscriptionsCollection
              .where('userId', isEqualTo: userId)
              .where('active', isEqualTo: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return SubscriptionModel.fromFirestore(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting subscription by user ID: $e');
      rethrow;
    }
  }

  // Update subscription
  Future<void> updateSubscription(SubscriptionModel subscription) async {
    try {
      await _subscriptionsCollection
          .doc(subscription.id)
          .update(subscription.toFirestore());
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  // Delete subscription
  Future<void> deleteSubscription(String subscriptionId) async {
    try {
      await _subscriptionsCollection.doc(subscriptionId).delete();
    } catch (e) {
      print('Error deleting subscription: $e');
      rethrow;
    }
  }

  // Deactivate subscription
  Future<void> deactivateSubscription(String subscriptionId) async {
    try {
      await _subscriptionsCollection.doc(subscriptionId).update({
        'active': false,
      });
    } catch (e) {
      print('Error deactivating subscription: $e');
      rethrow;
    }
  }

  // Stream subscription for real-time updates
  Stream<SubscriptionModel?> streamSubscription(String userId) {
    return _subscriptionsCollection
        .where('userId', isEqualTo: userId)
        .where('active', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return SubscriptionModel.fromFirestore(
              snapshot.docs.first.data(),
              snapshot.docs.first.id,
            );
          }
          return null;
        });
  }

  // Check if subscription is active
  Future<bool> isSubscriptionActive(String userId) async {
    try {
      final subscription = await getSubscriptionByUserId(userId);
      if (subscription == null) return false;

      return subscription.active &&
          subscription.endDate.isAfter(DateTime.now());
    } catch (e) {
      print('Error checking subscription status: $e');
      return false;
    }
  }
}
