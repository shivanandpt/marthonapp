import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/training_day_model.dart';
import 'training_day_core_service.dart';

class TrainingDayQueryService {
  final TrainingDayCoreService _coreService;

  TrainingDayQueryService(this._coreService);

  // Get training days for a plan
  Future<List<TrainingDayModel>> getTrainingDaysForPlan(String planId) async {
    try {
      print('Fetching training days for plan: $planId');

      final querySnapshot =
          await _coreService
              .getTrainingDaysCollection(planId)
              .orderBy('identification.week')
              .orderBy('identification.dayOfWeek')
              .get();

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
          await _coreService
              .getTrainingDaysCollection(planId)
              .where('identification.week', isEqualTo: week)
              .orderBy('identification.dayOfWeek')
              .get();

      return querySnapshot.docs
          .map((doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting training days for week: $e');
      return [];
    }
  }

  // Get training days by session type
  Future<List<TrainingDayModel>> getTrainingDaysBySessionType(
    String planId,
    String sessionType,
  ) async {
    try {
      final querySnapshot =
          await _coreService
              .getTrainingDaysCollection(planId)
              .where('identification.sessionType', isEqualTo: sessionType)
              .orderBy('identification.week')
              .orderBy('identification.dayOfWeek')
              .get();

      return querySnapshot.docs
          .map((doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting training days by session type: $e');
      return [];
    }
  }

  // Get training days by status
  Future<List<TrainingDayModel>> getTrainingDaysByStatus(
    String planId, {
    bool? completed,
    bool? skipped,
    bool? locked,
  }) async {
    try {
      Query query = _coreService.getTrainingDaysCollection(planId);

      if (completed != null) {
        query = query.where('status.completed', isEqualTo: completed);
      }
      if (skipped != null) {
        query = query.where('status.skipped', isEqualTo: skipped);
      }
      if (locked != null) {
        query = query.where('status.locked', isEqualTo: locked);
      }

      final querySnapshot =
          await query
              .orderBy('identification.week')
              .orderBy('identification.dayOfWeek')
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TrainingDayModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting training days by status: $e');
      return [];
    }
  }

  // Get completed training days
  Future<List<TrainingDayModel>> getCompletedTrainingDays(String planId) async {
    return getTrainingDaysByStatus(planId, completed: true);
  }

  // Get available training days (not completed, not skipped, not locked)
  Future<List<TrainingDayModel>> getAvailableTrainingDays(String planId) async {
    return getTrainingDaysByStatus(
      planId,
      completed: false,
      skipped: false,
      locked: false,
    );
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
          await _coreService
              .getTrainingDaysCollection(planId)
              .where(
                'scheduling.dateScheduled',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where(
                'scheduling.dateScheduled',
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

  // Get today's training day
  Future<TrainingDayModel?> getTodaysTrainingDay(String planId) async {
    return getTrainingDayForDate(planId, DateTime.now());
  }

  // Get all training days across all plans for a user
  Future<List<TrainingDayModel>> getAllTrainingDaysForUser(
    String userId,
  ) async {
    try {
      // First get all training plans for the user
      final plansSnapshot =
          await _coreService.firestore
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
          await _coreService.firestore
              .collection('training_plans')
              .where('userId', isEqualTo: userId)
              .get();

      // Search through each plan's training days
      for (var planDoc in plansSnapshot.docs) {
        try {
          final dayDoc =
              await _coreService
                  .getTrainingDaysCollection(planDoc.id)
                  .doc(trainingDayId)
                  .get();

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

  // Get training days by difficulty
  Future<List<TrainingDayModel>> getTrainingDaysByDifficulty(
    String planId,
    String difficulty,
  ) async {
    try {
      final querySnapshot =
          await _coreService
              .getTrainingDaysCollection(planId)
              .where('configuration.difficulty', isEqualTo: difficulty)
              .orderBy('identification.week')
              .orderBy('identification.dayOfWeek')
              .get();

      return querySnapshot.docs
          .map((doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting training days by difficulty: $e');
      return [];
    }
  }

  // Get rest days
  Future<List<TrainingDayModel>> getRestDays(String planId) async {
    try {
      final querySnapshot =
          await _coreService
              .getTrainingDaysCollection(planId)
              .where('configuration.restDay', isEqualTo: true)
              .orderBy('identification.week')
              .orderBy('identification.dayOfWeek')
              .get();

      return querySnapshot.docs
          .map((doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting rest days: $e');
      return [];
    }
  }

  // Get workout days
  Future<List<TrainingDayModel>> getWorkoutDays(String planId) async {
    try {
      final querySnapshot =
          await _coreService
              .getTrainingDaysCollection(planId)
              .where('configuration.restDay', isEqualTo: false)
              .orderBy('identification.week')
              .orderBy('identification.dayOfWeek')
              .get();

      return querySnapshot.docs
          .map((doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting workout days: $e');
      return [];
    }
  }
}
