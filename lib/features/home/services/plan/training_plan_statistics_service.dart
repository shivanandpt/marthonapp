import 'training_plan_core_service.dart';
import 'training_plan_query_service.dart';

class TrainingPlanStatisticsService {
  final TrainingPlanCoreService _coreService;
  final TrainingPlanQueryService _queryService;

  TrainingPlanStatisticsService(this._coreService, this._queryService);

  // Get plan summary statistics
  Future<Map<String, dynamic>> getPlanSummary(String planId) async {
    try {
      final plan = await _coreService.getTrainingPlan(planId);
      if (plan == null) return {};

      return {
        'totalWeeks': plan.structure.weeks,
        'runDaysPerWeek': plan.structure.runDaysPerWeek,
        'totalSessions': plan.structure.totalSessions,
        'currentWeek': plan.progress.currentWeek,
        'currentDay': plan.progress.currentDay,
        'completedWeeks': plan.progress.completedWeeks,
        'completedSessions': plan.progress.completedSessions,
        'completionPercentage': plan.completionPercentage,
        'daysRemaining': plan.daysRemaining,
        'weeksRemaining': plan.weeksRemaining,
        'isActive': plan.isActive,
        'isCompleted': plan.isCompleted,
        'isOverdue': plan.isOverdue,
        'goalType': plan.goalType,
        'difficulty': plan.settings.difficulty,
        'totalPlannedDistance': plan.statistics.totalPlannedDistance,
        'totalPlannedDuration': plan.statistics.totalPlannedDuration,
        'averageSessionDuration': plan.statistics.averageSessionDuration,
      };
    } catch (e) {
      print('Error getting plan summary: $e');
      return {};
    }
  }

  // Get user's plan statistics
  Future<Map<String, dynamic>> getUserPlanStats(String userId) async {
    try {
      final plans = await _queryService.getUserTrainingPlans(userId);

      int totalPlans = plans.length;
      int activePlans = plans.where((p) => p.isActive).length;
      int completedPlans = plans.where((p) => p.isCompleted).length;
      int overduePlans = plans.where((p) => p.isOverdue).length;

      // Calculate total statistics
      double totalDistance = 0;
      int totalDuration = 0;
      int totalSessions = 0;

      for (var plan in plans) {
        totalDistance += plan.statistics.totalPlannedDistance;
        totalDuration += plan.statistics.totalPlannedDuration;
        totalSessions += plan.structure.totalSessions;
      }

      return {
        'totalPlans': totalPlans,
        'activePlans': activePlans,
        'completedPlans': completedPlans,
        'overduePlans': overduePlans,
        'totalPlannedDistance': totalDistance,
        'totalPlannedDuration': totalDuration,
        'totalPlannedSessions': totalSessions,
        'plans': plans,
      };
    } catch (e) {
      print('Error getting user plan stats: $e');
      return {};
    }
  }

  // Get plan completion trends
  Future<Map<String, dynamic>> getPlanCompletionTrends(String userId) async {
    try {
      final plans = await _queryService.getUserTrainingPlans(userId);

      // Group by goal type
      Map<String, Map<String, int>> goalTypeStats = {};

      // Group by difficulty
      Map<String, Map<String, int>> difficultyStats = {};

      // Group by month (completion trends)
      Map<String, int> monthlyCompletions = {};

      for (var plan in plans) {
        // Goal type stats
        final goalType = plan.goalType;
        if (!goalTypeStats.containsKey(goalType)) {
          goalTypeStats[goalType] = {'total': 0, 'completed': 0, 'active': 0};
        }
        goalTypeStats[goalType]!['total'] =
            goalTypeStats[goalType]!['total']! + 1;
        if (plan.isCompleted)
          goalTypeStats[goalType]!['completed'] =
              goalTypeStats[goalType]!['completed']! + 1;
        if (plan.isActive)
          goalTypeStats[goalType]!['active'] =
              goalTypeStats[goalType]!['active']! + 1;

        // Difficulty stats
        final difficulty = plan.settings.difficulty;
        if (!difficultyStats.containsKey(difficulty)) {
          difficultyStats[difficulty] = {
            'total': 0,
            'completed': 0,
            'active': 0,
          };
        }
        difficultyStats[difficulty]!['total'] =
            difficultyStats[difficulty]!['total']! + 1;
        if (plan.isCompleted)
          difficultyStats[difficulty]!['completed'] =
              difficultyStats[difficulty]!['completed']! + 1;
        if (plan.isActive)
          difficultyStats[difficulty]!['active'] =
              difficultyStats[difficulty]!['active']! + 1;

        // Monthly completions
        if (plan.isCompleted && plan.dates.actualEndDate != null) {
          final monthKey =
              '${plan.dates.actualEndDate!.year}-${plan.dates.actualEndDate!.month.toString().padLeft(2, '0')}';
          monthlyCompletions[monthKey] =
              (monthlyCompletions[monthKey] ?? 0) + 1;
        }
      }

      return {
        'goalTypeStats': goalTypeStats,
        'difficultyStats': difficultyStats,
        'monthlyCompletions': monthlyCompletions,
      };
    } catch (e) {
      print('Error getting plan completion trends: $e');
      return {};
    }
  }

  // Get performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics(String userId) async {
    try {
      final plans = await _queryService.getUserTrainingPlans(userId);
      final completedPlans = plans.where((p) => p.isCompleted).toList();

      if (completedPlans.isEmpty) {
        return {
          'averageCompletionTime': 0,
          'successRate': 0.0,
          'totalDistance': 0.0,
          'totalDuration': 0,
          'averagePlanDuration': 0,
        };
      }

      // Calculate averages
      int totalCompletionTime = 0;
      double totalDistance = 0;
      int totalDuration = 0;

      for (var plan in completedPlans) {
        if (plan.dates.actualEndDate != null) {
          final completionTime =
              plan.dates.actualEndDate!.difference(plan.dates.startDate).inDays;
          totalCompletionTime += completionTime;
        }
        totalDistance += plan.statistics.totalPlannedDistance;
        totalDuration += plan.statistics.totalPlannedDuration;
      }

      return {
        'averageCompletionTime':
            completedPlans.isNotEmpty
                ? totalCompletionTime / completedPlans.length
                : 0,
        'successRate':
            plans.isNotEmpty
                ? (completedPlans.length / plans.length) * 100
                : 0.0,
        'totalDistance': totalDistance,
        'totalDuration': totalDuration,
        'averagePlanDuration':
            completedPlans.isNotEmpty
                ? totalDuration / completedPlans.length
                : 0,
        'completedPlansCount': completedPlans.length,
        'totalPlansCount': plans.length,
      };
    } catch (e) {
      print('Error getting performance metrics: $e');
      return {};
    }
  }
}
