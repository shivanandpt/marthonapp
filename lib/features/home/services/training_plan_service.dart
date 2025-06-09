import 'plan/training_plan_core_service.dart';
import 'plan/training_plan_query_service.dart';
import 'plan/training_plan_update_service.dart';
import 'plan/training_plan_management_service.dart';
import 'plan/training_plan_statistics_service.dart';
import 'plan/training_plan_stream_service.dart';
import '../models/training_plan_model.dart';

class TrainingPlanService {
  late final TrainingPlanCoreService _coreService;
  late final TrainingPlanQueryService _queryService;
  late final TrainingPlanUpdateService _updateService;
  late final TrainingPlanManagementService _managementService;
  late final TrainingPlanStatisticsService _statisticsService;
  late final TrainingPlanStreamService _streamService;

  TrainingPlanService() {
    _coreService = TrainingPlanCoreService();
    _queryService = TrainingPlanQueryService(_coreService);
    _updateService = TrainingPlanUpdateService(_coreService);
    _managementService = TrainingPlanManagementService(
      _coreService,
      _queryService,
    );
    _statisticsService = TrainingPlanStatisticsService(
      _coreService,
      _queryService,
    );
    _streamService = TrainingPlanStreamService(_coreService);
  }

  // Core operations
  Future<String> createTrainingPlan(TrainingPlanModel plan) =>
      _coreService.createTrainingPlan(plan);

  Future<TrainingPlanModel?> getTrainingPlan(String planId) =>
      _coreService.getTrainingPlan(planId);

  Future<void> updateTrainingPlan(TrainingPlanModel plan) =>
      _coreService.updateTrainingPlan(plan);

  Future<void> deleteTrainingPlan(String planId) =>
      _coreService.deleteTrainingPlan(planId);

  // Query operations
  Future<List<TrainingPlanModel>> getUserTrainingPlans(String userId) =>
      _queryService.getUserTrainingPlans(userId);

  Future<TrainingPlanModel?> getActiveTrainingPlan(String userId) =>
      _queryService.getActiveTrainingPlan(userId);

  Future<List<TrainingPlanModel>> searchPlans(
    String userId,
    String searchTerm,
  ) => _queryService.searchPlans(userId, searchTerm);

  // Management operations
  Future<void> markPlanAsCompleted(String planId) =>
      _managementService.markPlanAsCompleted(planId);

  Future<void> pausePlan(String planId) => _managementService.pausePlan(planId);

  Future<void> resumePlan(String planId) =>
      _managementService.resumePlan(planId);

  // Statistics operations
  Future<Map<String, dynamic>> getPlanSummary(String planId) =>
      _statisticsService.getPlanSummary(planId);

  Future<Map<String, dynamic>> getUserPlanStats(String userId) =>
      _statisticsService.getUserPlanStats(userId);

  // Stream operations
  Stream<List<TrainingPlanModel>> streamUserTrainingPlans(String userId) =>
      _streamService.streamUserTrainingPlans(userId);

  Stream<TrainingPlanModel?> streamActiveTrainingPlan(String userId) =>
      _streamService.streamActiveTrainingPlan(userId);

  // Expose sub-services for advanced usage
  TrainingPlanCoreService get core => _coreService;
  TrainingPlanQueryService get query => _queryService;
  TrainingPlanUpdateService get update => _updateService;
  TrainingPlanManagementService get management => _managementService;
  TrainingPlanStatisticsService get statistics => _statisticsService;
  TrainingPlanStreamService get stream => _streamService;
}
