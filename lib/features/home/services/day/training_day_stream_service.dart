import '../../models/training_day_model.dart';
import 'training_day_core_service.dart';

class TrainingDayStreamService {
  final TrainingDayCoreService _coreService;

  TrainingDayStreamService(this._coreService);

  // Stream training days for a plan
  Stream<List<TrainingDayModel>> streamTrainingDaysForPlan(String planId) {
    return _coreService
        .getTrainingDaysCollection(planId)
        .orderBy('identification.week')
        .orderBy('identification.dayOfWeek')
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

  // Stream training days for a specific week
  Stream<List<TrainingDayModel>> streamTrainingDaysForWeek(
    String planId,
    int week,
  ) {
    return _coreService
        .getTrainingDaysCollection(planId)
        .where('identification.week', isEqualTo: week)
        .orderBy('identification.dayOfWeek')
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

  // Stream specific training day
  Stream<TrainingDayModel?> streamTrainingDay(String planId, String dayId) {
    return _coreService
        .getTrainingDaysCollection(planId)
        .doc(dayId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.exists
                  ? TrainingDayModel.fromFirestore(
                    snapshot.data()!,
                    snapshot.id,
                  )
                  : null,
        );
  }

  // Stream completed training days
  Stream<List<TrainingDayModel>> streamCompletedTrainingDays(String planId) {
    return _coreService
        .getTrainingDaysCollection(planId)
        .where('status.completed', isEqualTo: true)
        .orderBy('identification.week')
        .orderBy('identification.dayOfWeek')
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

  // Stream available training days
  Stream<List<TrainingDayModel>> streamAvailableTrainingDays(String planId) {
    return _coreService
        .getTrainingDaysCollection(planId)
        .where('status.completed', isEqualTo: false)
        .where('status.skipped', isEqualTo: false)
        .where('status.locked', isEqualTo: false)
        .orderBy('identification.week')
        .orderBy('identification.dayOfWeek')
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

  // Stream training days by session type
  Stream<List<TrainingDayModel>> streamTrainingDaysBySessionType(
    String planId,
    String sessionType,
  ) {
    return _coreService
        .getTrainingDaysCollection(planId)
        .where('identification.sessionType', isEqualTo: sessionType)
        .orderBy('identification.week')
        .orderBy('identification.dayOfWeek')
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

  // Stream today's training day
  Stream<TrainingDayModel?> streamTodaysTrainingDay(String planId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return _coreService
        .getTrainingDaysCollection(planId)
        .where('scheduling.dateScheduled', isGreaterThanOrEqualTo: startOfDay)
        .where('scheduling.dateScheduled', isLessThanOrEqualTo: endOfDay)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.isNotEmpty
                  ? TrainingDayModel.fromFirestore(
                    snapshot.docs.first.data(),
                    snapshot.docs.first.id,
                  )
                  : null,
        );
  }

  // Stream training days with real-time status updates
  Stream<Map<String, int>> streamTrainingDayStatusCounts(String planId) {
    return _coreService.getTrainingDaysCollection(planId).snapshots().map((
      snapshot,
    ) {
      int completed = 0;
      int skipped = 0;
      int locked = 0;
      int available = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] ?? {};

        if (status['completed'] == true) {
          completed++;
        } else if (status['skipped'] == true) {
          skipped++;
        } else if (status['locked'] == true) {
          locked++;
        } else {
          available++;
        }
      }

      return {
        'total': snapshot.docs.length,
        'completed': completed,
        'skipped': skipped,
        'locked': locked,
        'available': available,
      };
    });
  }
}
