import '../../models/training_plan_model.dart';
import 'training_plan_core_service.dart';
import 'training_plan_query_service.dart';

class TrainingPlanManagementService {
  final TrainingPlanCoreService _coreService;
  final TrainingPlanQueryService _queryService;

  TrainingPlanManagementService(this._coreService, this._queryService);

  // Mark plan as completed
  Future<void> markPlanAsCompleted(String planId) async {
    try {
      final plan = await _coreService.getTrainingPlan(planId);
      if (plan != null) {
        final completedPlan = plan.markAsCompleted();
        await _coreService.updateTrainingPlan(completedPlan);
      }
    } catch (e) {
      print('Error marking plan as completed: $e');
      rethrow;
    }
  }

  // Pause plan
  Future<void> pausePlan(String planId) async {
    try {
      final plan = await _coreService.getTrainingPlan(planId);
      if (plan != null) {
        final pausedPlan = plan.pause();
        await _coreService.updateTrainingPlan(pausedPlan);
      }
    } catch (e) {
      print('Error pausing plan: $e');
      rethrow;
    }
  }

  // Resume plan
  Future<void> resumePlan(String planId) async {
    try {
      final plan = await _coreService.getTrainingPlan(planId);
      if (plan != null) {
        final resumedPlan = plan.resume();
        await _coreService.updateTrainingPlan(resumedPlan);
      }
    } catch (e) {
      print('Error resuming plan: $e');
      rethrow;
    }
  }

  // Restart plan (reset progress)
  Future<void> restartPlan(String planId) async {
    try {
      final plan = await _coreService.getTrainingPlan(planId);
      if (plan != null) {
        final restartedPlan = plan.copyWith(
          progress: plan.progress.copyWith(
            currentWeek: 1,
            currentDay: 1,
            completedWeeks: 0,
            completedSessions: 0,
            isActive: true,
          ),
          dates: plan.dates.copyWith(
            startDate: DateTime.now(),
            actualEndDate: null,
          ),
        );
        await _coreService.updateTrainingPlan(restartedPlan);
      }
    } catch (e) {
      print('Error restarting plan: $e');
      rethrow;
    }
  }

  // Advance to next week
  Future<void> advanceToNextWeek(String planId) async {
    try {
      final plan = await _coreService.getTrainingPlan(planId);
      if (plan != null && plan.progress.currentWeek < plan.structure.weeks) {
        final updatedPlan = plan.updateProgress(
          currentWeek: plan.progress.currentWeek + 1,
          currentDay: 1,
          completedWeeks: plan.progress.completedWeeks + 1,
        );
        await _coreService.updateTrainingPlan(updatedPlan);
      }
    } catch (e) {
      print('Error advancing to next week: $e');
      rethrow;
    }
  }

  // Complete current session
  Future<void> completeCurrentSession(String planId) async {
    try {
      final plan = await _coreService.getTrainingPlan(planId);
      if (plan != null) {
        final updatedPlan = plan.updateProgress(
          completedSessions: plan.progress.completedSessions + 1,
        );
        await _coreService.updateTrainingPlan(updatedPlan);
      }
    } catch (e) {
      print('Error completing current session: $e');
      rethrow;
    }
  }

  // Duplicate plan
  Future<String> duplicatePlan(String planId, String newPlanName) async {
    try {
      final originalPlan = await _coreService.getTrainingPlan(planId);
      if (originalPlan == null) throw Exception('Plan not found');

      final duplicatedPlan = originalPlan.copyWith(
        id: '', // Will be set by Firestore
        planName: newPlanName,
        progress: originalPlan.progress.copyWith(
          isActive: false,
          currentWeek: 1,
          currentDay: 1,
          completedWeeks: 0,
          completedSessions: 0,
        ),
        dates: originalPlan.dates.copyWith(
          startDate: DateTime.now(),
          actualEndDate: null,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await _coreService.createTrainingPlan(duplicatedPlan);
    } catch (e) {
      print('Error duplicating plan: $e');
      rethrow;
    }
  }

  // Archive completed plans
  Future<void> archiveCompletedPlans(String userId) async {
    try {
      final completedPlans = await _queryService.getPlansByStatus(
        userId,
        isCompleted: true,
      );

      for (var plan in completedPlans) {
        await _coreService.updateTrainingPlan(
          plan.copyWith(progress: plan.progress.copyWith(isActive: false)),
        );
      }
    } catch (e) {
      print('Error archiving completed plans: $e');
      rethrow;
    }
  }
}
