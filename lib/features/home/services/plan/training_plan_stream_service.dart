import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/training_plan_model.dart';
import 'training_plan_core_service.dart';

class TrainingPlanStreamService {
  final TrainingPlanCoreService _coreService;

  TrainingPlanStreamService(this._coreService);

  // Stream training plans for real-time updates
  Stream<List<TrainingPlanModel>> streamUserTrainingPlans(String userId) {
    return _coreService.plansCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => TrainingPlanModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList(),
        );
  }

  // Stream active training plan
  Stream<TrainingPlanModel?> streamActiveTrainingPlan(String userId) {
    return _coreService.plansCollection
        .where('userId', isEqualTo: userId)
        .where('progress.isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.isNotEmpty
                  ? TrainingPlanModel.fromFirestore(
                    snapshot.docs.first.data() as Map<String, dynamic>,
                    snapshot.docs.first.id,
                  )
                  : null,
        );
  }

  // Stream specific training plan
  Stream<TrainingPlanModel?> streamTrainingPlan(String planId) {
    return _coreService.plansCollection
        .doc(planId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.exists
                  ? TrainingPlanModel.fromFirestore(
                    snapshot.data() as Map<String, dynamic>,
                    snapshot.id,
                  )
                  : null,
        );
  }

  // Stream plans by goal type
  Stream<List<TrainingPlanModel>> streamTrainingPlansByGoal(
    String userId,
    String goalType,
  ) {
    return _coreService.plansCollection
        .where('userId', isEqualTo: userId)
        .where('goalType', isEqualTo: goalType)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => TrainingPlanModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList(),
        );
  }

  // Stream plans by status
  Stream<List<TrainingPlanModel>> streamActiveTrainingPlans(String userId) {
    return _coreService.plansCollection
        .where('userId', isEqualTo: userId)
        .where('progress.isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => TrainingPlanModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList(),
        );
  }
}
