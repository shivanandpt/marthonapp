import '../../models/training_day_model.dart';
import 'training_day_core_service.dart';

class TrainingDayBatchService {
  final TrainingDayCoreService _coreService;

  TrainingDayBatchService(this._coreService);

  // Batch operations
  Future<void> batchUpdateTrainingDays(
    String planId,
    List<TrainingDayModel> days,
  ) async {
    try {
      final batch = _coreService.firestore.batch();

      for (var day in days) {
        final updatedDay = day.copyWith(updatedAt: DateTime.now());
        batch.update(
          _coreService.getTrainingDaysCollection(planId).doc(day.id),
          updatedDay.toFirestore(),
        );
      }

      await batch.commit();
      print('Batch updated ${days.length} training days');
    } catch (e) {
      print('Error in batch update: $e');
      rethrow;
    }
  }

  // Batch create training days
  Future<List<String>> batchCreateTrainingDays(
    String planId,
    List<TrainingDayModel> days,
  ) async {
    try {
      final batch = _coreService.firestore.batch();
      final docRefs = <String>[];

      for (var day in days) {
        final docRef = _coreService.getTrainingDaysCollection(planId).doc();
        batch.set(docRef, day.toFirestore());
        docRefs.add(docRef.id);
      }

      await batch.commit();
      print('Batch created ${days.length} training days');
      return docRefs;
    } catch (e) {
      print('Error in batch create: $e');
      rethrow;
    }
  }

  // Batch delete training days
  Future<void> batchDeleteTrainingDays(
    String planId,
    List<String> dayIds,
  ) async {
    try {
      final batch = _coreService.firestore.batch();

      for (var dayId in dayIds) {
        batch.delete(_coreService.getTrainingDaysCollection(planId).doc(dayId));
      }

      await batch.commit();
      print('Batch deleted ${dayIds.length} training days');
    } catch (e) {
      print('Error in batch delete: $e');
      rethrow;
    }
  }

  // Generate week schedule
  Future<void> generateWeekSchedule(
    String planId,
    int week,
    List<TrainingDayModel> weekDays,
  ) async {
    try {
      await batchCreateTrainingDays(planId, weekDays);
      print('Generated schedule for week $week with ${weekDays.length} days');
    } catch (e) {
      print('Error generating week schedule: $e');
      rethrow;
    }
  }

  // Regenerate plan schedule
  Future<void> regeneratePlanSchedule(
    String planId,
    List<TrainingDayModel> newSchedule,
  ) async {
    try {
      // First delete existing days
      await _coreService.deleteTrainingDaysForPlan(planId);

      // Then create new schedule
      await batchCreateTrainingDays(planId, newSchedule);

      print('Regenerated plan schedule with ${newSchedule.length} days');
    } catch (e) {
      print('Error regenerating plan schedule: $e');
      rethrow;
    }
  }
}
