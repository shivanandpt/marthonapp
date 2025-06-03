import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/training_day_model.dart';

class TrainingDayService {
  final FirebaseFirestore _firestore;

  TrainingDayService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Helper method to get the training days collection for a specific plan
  CollectionReference<Map<String, dynamic>> _getTrainingDaysCollection(
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
      final docRef = await _getTrainingDaysCollection(
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
          await _getTrainingDaysCollection(planId).doc(dayId).get();
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

  // Get training days for a plan
  Future<List<TrainingDayModel>> getTrainingDaysForPlan(String planId) async {
    try {
      print('Fetching training days for plan: $planId');

      final querySnapshot =
          await _getTrainingDaysCollection(
            planId,
          ).orderBy('week').orderBy('dayOfWeek').get();

      final trainingDays =
          querySnapshot.docs
              .map((doc) {
                try {
                  return TrainingDayModel.fromFirestore(doc.data(), doc.id);
                } catch (e) {
                  print('Error parsing training day ${doc.id}: $e');
                  return null;
                }
              })
              .where((day) => day != null)
              .cast<TrainingDayModel>()
              .toList();

      print('Found ${trainingDays.length} training days for plan $planId');

      // Debug: Print training day details
      for (var day in trainingDays) {
        print(
          'Training Day: ${day.id}, Week: ${day.week}, Day: ${day.dayOfWeek}, Date: ${day.dateScheduled}',
        );
      }

      return trainingDays;
    } catch (e) {
      print('Error getting training days for plan: $e');
      return []; // Return empty list instead of rethrowing to prevent app crash
    }
  }

  // Get training days for a specific week in a plan
  Future<List<TrainingDayModel>> getTrainingDaysForWeek(
    String planId,
    int week,
  ) async {
    try {
      final querySnapshot =
          await _getTrainingDaysCollection(
            planId,
          ).where('week', isEqualTo: week).orderBy('dayOfWeek').get();

      return querySnapshot.docs
          .map((doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting training days for week: $e');
      return [];
    }
  }

  // Get training day for a specific date
  Future<TrainingDayModel?> getTrainingDayForDate(
    String planId,
    DateTime date,
  ) async {
    try {
      // Convert DateTime to start and end of day for comparison
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot =
          await _getTrainingDaysCollection(planId)
              .where(
                'dateScheduled',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where(
                'dateScheduled',
                isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
              )
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return TrainingDayModel.fromFirestore(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting training day for date: $e');
      return null;
    }
  }

  // Update training day
  Future<void> updateTrainingDay(String planId, TrainingDayModel day) async {
    try {
      await _getTrainingDaysCollection(
        planId,
      ).doc(day.id).update(day.toFirestore());
    } catch (e) {
      print('Error updating training day: $e');
      rethrow;
    }
  }

  // Delete training day
  Future<void> deleteTrainingDay(String planId, String dayId) async {
    try {
      await _getTrainingDaysCollection(planId).doc(dayId).delete();
    } catch (e) {
      print('Error deleting training day: $e');
      rethrow;
    }
  }

  // Delete all training days for a plan
  Future<void> deleteTrainingDaysForPlan(String planId) async {
    try {
      final querySnapshot = await _getTrainingDaysCollection(planId).get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting training days for plan: $e');
      rethrow;
    }
  }

  // Stream training days for a plan
  Stream<List<TrainingDayModel>> streamTrainingDaysForPlan(String planId) {
    return _getTrainingDaysCollection(planId)
        .orderBy('week')
        .orderBy('dayOfWeek')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id),
                  )
                  .toList(),
        );
  }

  // Get all training days across all plans for a user (if needed)
  Future<List<TrainingDayModel>> getAllTrainingDaysForUser(
    String userId,
  ) async {
    try {
      // First get all training plans for the user
      final plansSnapshot =
          await _firestore
              .collection('training_plans')
              .where('userId', isEqualTo: userId)
              .get();

      final List<TrainingDayModel> allTrainingDays = [];

      // For each plan, get its training days
      for (var planDoc in plansSnapshot.docs) {
        final trainingDays = await getTrainingDaysForPlan(planDoc.id);
        allTrainingDays.addAll(trainingDays);
      }

      return allTrainingDays;
    } catch (e) {
      print('Error getting all training days for user: $e');
      return [];
    }
  }

  // Helper method to get training day by ID without knowing the plan ID
  Future<TrainingDayModel?> findTrainingDayById(
    String trainingDayId,
    String userId,
  ) async {
    try {
      // Get all user's training plans
      final plansSnapshot =
          await _firestore
              .collection('training_plans')
              .where('userId', isEqualTo: userId)
              .get();

      // Search through each plan's training days
      for (var planDoc in plansSnapshot.docs) {
        try {
          final dayDoc =
              await _getTrainingDaysCollection(
                planDoc.id,
              ).doc(trainingDayId).get();

          if (dayDoc.exists) {
            return TrainingDayModel.fromFirestore(dayDoc.data()!, dayDoc.id);
          }
        } catch (e) {
          // Continue searching in other plans
          continue;
        }
      }

      return null;
    } catch (e) {
      print('Error finding training day by ID: $e');
      return null;
    }
  }
}
