import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/training_plan_model.dart';

class TrainingPlanService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _plansCollection;

  TrainingPlanService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _plansCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'training_plans',
      );

  // Create new training plan
  Future<String> createTrainingPlan(TrainingPlanModel plan) async {
    try {
      final docRef = await _plansCollection.add(plan.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating training plan: $e');
      rethrow;
    }
  }

  // Get training plan by ID
  Future<TrainingPlanModel?> getTrainingPlan(String planId) async {
    try {
      final docSnapshot = await _plansCollection.doc(planId).get();
      if (docSnapshot.exists) {
        return TrainingPlanModel.fromFirestore(
          docSnapshot.data()!,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting training plan: $e');
      rethrow;
    }
  }

  // Get all training plans for a user
  Future<List<TrainingPlanModel>> getUserTrainingPlans(String userId) async {
    try {
      final querySnapshot =
          await _plansCollection.where('userId', isEqualTo: userId).get();

      return querySnapshot.docs
          .map((doc) => TrainingPlanModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user training plans: $e');
      rethrow;
    }
  }

  // Get active training plan for a user
  Future<TrainingPlanModel?> getActiveTrainingPlan(String userId) async {
    try {
      final querySnapshot =
          await _plansCollection
              .where('userId', isEqualTo: userId)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return TrainingPlanModel.fromFirestore(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting active training plan: $e');
      rethrow;
    }
  }

  // Update training plan
  Future<void> updateTrainingPlan(TrainingPlanModel plan) async {
    try {
      await _plansCollection.doc(plan.id).update(plan.toFirestore());
    } catch (e) {
      print('Error updating training plan: $e');
      rethrow;
    }
  }

  // Delete training plan
  Future<void> deleteTrainingPlan(String planId) async {
    try {
      await _plansCollection.doc(planId).delete();
    } catch (e) {
      print('Error deleting training plan: $e');
      rethrow;
    }
  }

  // Set a training plan as active and deactivate others
  Future<void> setActiveTrainingPlan(String userId, String planId) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();

      // First, deactivate all plans for this user
      final plansToUpdate =
          await _plansCollection
              .where('userId', isEqualTo: userId)
              .where('isActive', isEqualTo: true)
              .get();

      for (var doc in plansToUpdate.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      // Then, activate the selected plan
      batch.update(_plansCollection.doc(planId), {'isActive': true});

      // Commit the batch
      await batch.commit();
    } catch (e) {
      print('Error setting active training plan: $e');
      rethrow;
    }
  }

  // Stream active training plan for real-time updates
  Stream<TrainingPlanModel?> streamActiveTrainingPlan(String userId) {
    return _plansCollection
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return TrainingPlanModel.fromFirestore(
              snapshot.docs.first.data(),
              snapshot.docs.first.id,
            );
          }
          return null;
        });
  }
}
