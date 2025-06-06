import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/training_plan_model.dart';
import 'training_plan_core_service.dart';

class TrainingPlanQueryService {
  final TrainingPlanCoreService _coreService;

  TrainingPlanQueryService(this._coreService);

  // Get all training plans for a user
  Future<List<TrainingPlanModel>> getUserTrainingPlans(String userId) async {
    try {
      final querySnapshot =
          await _coreService.plansCollection
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TrainingPlanModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting user training plans: $e');
      return [];
    }
  }

  // Get active training plan for a user
  Future<TrainingPlanModel?> getActiveTrainingPlan(String userId) async {
    try {
      final querySnapshot =
          await _coreService.plansCollection
              .where('userId', isEqualTo: userId)
              .where(
                'isActive',
                isEqualTo: true,
              ) // Changed from 'progress.isActive'
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return TrainingPlanModel.fromFirestore(
          querySnapshot.docs.first.data() as Map<String, dynamic>,
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting active training plan: $e');
      return null;
    }
  }

  // Get training plans by goal type
  Future<List<TrainingPlanModel>> getTrainingPlansByGoal(
    String userId,
    String goalType,
  ) async {
    try {
      final querySnapshot =
          await _coreService.plansCollection
              .where('userId', isEqualTo: userId)
              .where('goalType', isEqualTo: goalType)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TrainingPlanModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting training plans by goal: $e');
      return [];
    }
  }

  // Get training plans by plan type
  Future<List<TrainingPlanModel>> getTrainingPlansByType(
    String userId,
    String planType,
  ) async {
    try {
      final querySnapshot =
          await _coreService.plansCollection
              .where('userId', isEqualTo: userId)
              .where('planType', isEqualTo: planType)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => TrainingPlanModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting training plans by type: $e');
      return [];
    }
  }

  // Search plans
  Future<List<TrainingPlanModel>> searchPlans(
    String userId,
    String searchTerm,
  ) async {
    try {
      final allPlans = await getUserTrainingPlans(userId);

      final filteredPlans =
          allPlans.where((plan) {
            final planName = plan.planName.toLowerCase();
            final description = plan.description.toLowerCase();
            final goalType = plan.goalType.toLowerCase();
            final search = searchTerm.toLowerCase();

            return planName.contains(search) ||
                description.contains(search) ||
                goalType.contains(search);
          }).toList();

      return filteredPlans;
    } catch (e) {
      print('Error searching plans: $e');
      return [];
    }
  }

  // Get plans by status
  Future<List<TrainingPlanModel>> getPlansByStatus(
    String userId, {
    bool? isActive,
    bool? isCompleted,
    bool? isOverdue,
  }) async {
    try {
      final allPlans = await getUserTrainingPlans(userId);

      return allPlans.where((plan) {
        if (isActive != null && plan.isActive != isActive) return false;
        if (isCompleted != null && plan.isCompleted != isCompleted)
          return false;
        if (isOverdue != null && plan.isOverdue != isOverdue) return false;
        return true;
      }).toList();
    } catch (e) {
      print('Error getting plans by status: $e');
      return [];
    }
  }
}
