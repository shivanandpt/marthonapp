import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/training_day_model.dart';

class TrainingDayCoreService {
  final FirebaseFirestore _firestore;

  TrainingDayCoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Helper method to get the training days collection for a specific plan
  CollectionReference<Map<String, dynamic>> getTrainingDaysCollection(
    String planId,
  ) {
    return _firestore
        .collection('training_plans')
        .doc(planId)
        .collection('training_days');
  }

  // Create new training day
  Future<String> createTrainingDay(String planId, TrainingDayModel day) async {
    try {
      print('Creating training day for plan: $planId');
      final docRef = await getTrainingDaysCollection(
        planId,
      ).add(day.toFirestore());
      print('Training day created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating training day: $e');
      rethrow;
    }
  }

  // Get training day by ID
  Future<TrainingDayModel?> getTrainingDay(String planId, String dayId) async {
    try {
      final docSnapshot =
          await getTrainingDaysCollection(planId).doc(dayId).get();
      if (docSnapshot.exists) {
        return TrainingDayModel.fromFirestore(
          docSnapshot.data()!,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting training day: $e');
      rethrow;
    }
  }

  // Update training day
  Future<void> updateTrainingDay(String planId, TrainingDayModel day) async {
    try {
      final updatedDay = day.copyWith(updatedAt: DateTime.now());
      await getTrainingDaysCollection(
        planId,
      ).doc(day.id).update(updatedDay.toFirestore());
      print('Updated training day: ${day.id}');
    } catch (e) {
      print('Error updating training day: $e');
      rethrow;
    }
  }

  // Delete training day
  Future<void> deleteTrainingDay(String planId, String dayId) async {
    try {
      await getTrainingDaysCollection(planId).doc(dayId).delete();
      print('Deleted training day: $dayId');
    } catch (e) {
      print('Error deleting training day: $e');
      rethrow;
    }
  }

  // Delete all training days for a plan
  Future<void> deleteTrainingDaysForPlan(String planId) async {
    try {
      final querySnapshot = await getTrainingDaysCollection(planId).get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Deleted all training days for plan: $planId');
    } catch (e) {
      print('Error deleting training days for plan: $e');
      rethrow;
    }
  }

  // Get firestore instance
  FirebaseFirestore get firestore => _firestore;
}
