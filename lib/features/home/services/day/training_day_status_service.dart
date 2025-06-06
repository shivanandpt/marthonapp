import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/day_status_model.dart';
import 'training_day_core_service.dart';

class TrainingDayStatusService {
  final TrainingDayCoreService _coreService;

  TrainingDayStatusService(this._coreService);

  // Update training day status
  Future<void> updateTrainingDayStatus(
    String planId,
    String dayId,
    DayStatusModel status,
  ) async {
    try {
      await _coreService.getTrainingDaysCollection(planId).doc(dayId).update({
        'status': status.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated training day status: $dayId');
    } catch (e) {
      print('Error updating training day status: $e');
      rethrow;
    }
  }

  // Mark training day as completed
  Future<void> markTrainingDayAsCompleted(
    String planId,
    String dayId, {
    int? actualDuration,
    double? actualDistance,
  }) async {
    try {
      final day = await _coreService.getTrainingDay(planId, dayId);
      if (day != null) {
        final completedDay = day.markAsCompleted(
          actualDuration: actualDuration,
          actualDistance: actualDistance,
        );
        await _coreService.updateTrainingDay(planId, completedDay);
      }
    } catch (e) {
      print('Error marking training day as completed: $e');
      rethrow;
    }
  }

  // Mark training day as skipped
  Future<void> markTrainingDayAsSkipped(String planId, String dayId) async {
    try {
      final day = await _coreService.getTrainingDay(planId, dayId);
      if (day != null) {
        final skippedDay = day.markAsSkipped();
        await _coreService.updateTrainingDay(planId, skippedDay);
      }
    } catch (e) {
      print('Error marking training day as skipped: $e');
      rethrow;
    }
  }

  // Lock training day
  Future<void> lockTrainingDay(String planId, String dayId) async {
    try {
      final day = await _coreService.getTrainingDay(planId, dayId);
      if (day != null) {
        final lockedDay = day.lock();
        await _coreService.updateTrainingDay(planId, lockedDay);
      }
    } catch (e) {
      print('Error locking training day: $e');
      rethrow;
    }
  }

  // Unlock training day
  Future<void> unlockTrainingDay(String planId, String dayId) async {
    try {
      final day = await _coreService.getTrainingDay(planId, dayId);
      if (day != null) {
        final unlockedDay = day.unlock();
        await _coreService.updateTrainingDay(planId, unlockedDay);
      }
    } catch (e) {
      print('Error unlocking training day: $e');
      rethrow;
    }
  }

  // Reset training day status
  Future<void> resetTrainingDayStatus(String planId, String dayId) async {
    try {
      final resetStatus = DayStatusModel(
        completed: false,
        skipped: false,
        locked: false,
      );
      await updateTrainingDayStatus(planId, dayId, resetStatus);
    } catch (e) {
      print('Error resetting training day status: $e');
      rethrow;
    }
  }

  // Batch status updates
  Future<void> batchUpdateStatus(
    String planId,
    List<Map<String, dynamic>> statusUpdates,
  ) async {
    try {
      final batch = _coreService.firestore.batch();

      for (var update in statusUpdates) {
        final dayId = update['dayId'] as String;
        final status = update['status'] as DayStatusModel;

        batch.update(
          _coreService.getTrainingDaysCollection(planId).doc(dayId),
          {
            'status': status.toMap(),
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
        );
      }

      await batch.commit();
      print('Batch updated ${statusUpdates.length} training day statuses');
    } catch (e) {
      print('Error in batch status update: $e');
      rethrow;
    }
  }

  // Mark multiple days as completed
  Future<void> markMultipleDaysAsCompleted(
    String planId,
    List<String> dayIds,
  ) async {
    try {
      final batch = _coreService.firestore.batch();

      for (var dayId in dayIds) {
        final completedStatus = DayStatusModel(
          completed: true,
          skipped: false,
          locked: false,
        );

        batch
            .update(_coreService.getTrainingDaysCollection(planId).doc(dayId), {
              'status': completedStatus.toMap(),
              'completionData.completedAt': Timestamp.fromDate(DateTime.now()),
              'updatedAt': Timestamp.fromDate(DateTime.now()),
            });
      }

      await batch.commit();
      print('Batch marked ${dayIds.length} days as completed');
    } catch (e) {
      print('Error in batch completion: $e');
      rethrow;
    }
  }

  // Auto-lock future days based on current progress
  Future<void> autoLockFutureDays(
    String planId,
    int currentWeek,
    int currentDay,
  ) async {
    try {
      final batch = _coreService.firestore.batch();

      // Get all days after current position
      final querySnapshot =
          await _coreService
              .getTrainingDaysCollection(planId)
              .where('identification.week', isGreaterThan: currentWeek)
              .get();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'status.locked': true,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      // Also lock days in current week after current day
      final currentWeekSnapshot =
          await _coreService
              .getTrainingDaysCollection(planId)
              .where('identification.week', isEqualTo: currentWeek)
              .where('identification.dayOfWeek', isGreaterThan: currentDay)
              .get();

      for (var doc in currentWeekSnapshot.docs) {
        batch.update(doc.reference, {
          'status.locked': true,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
      print('Auto-locked future days from week $currentWeek, day $currentDay');
    } catch (e) {
      print('Error auto-locking future days: $e');
      rethrow;
    }
  }
}
