import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/training_plan_model.dart';

class TrainingPlanCoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _plansCollection = FirebaseFirestore.instance
      .collection('training_plans');

  // Create new training plan
  Future<String> createTrainingPlan(TrainingPlanModel plan) async {
    try {
      final docRef = await _plansCollection.add(plan.toFirestore());
      print('Created training plan with ID: ${docRef.id}');
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
          docSnapshot.data() as Map<String, dynamic>,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting training plan: $e');
      rethrow;
    }
  }

  // Update training plan
  Future<void> updateTrainingPlan(TrainingPlanModel plan) async {
    try {
      final updatedPlan = plan.copyWith(updatedAt: DateTime.now());
      await _plansCollection.doc(plan.id).update(updatedPlan.toFirestore());
      print('Updated training plan: ${plan.id}');
    } catch (e) {
      print('Error updating training plan: $e');
      rethrow;
    }
  }

  // Delete training plan
  Future<void> deleteTrainingPlan(String planId) async {
    try {
      await _plansCollection.doc(planId).delete();
      print('Deleted training plan: $planId');
    } catch (e) {
      print('Error deleting training plan: $e');
      rethrow;
    }
  }

  // Get collection reference (for other services)
  CollectionReference get plansCollection => _plansCollection;
  FirebaseFirestore get firestore => _firestore;
}
