import 'day/training_day_core_service.dart';
import 'day/training_day_query_service.dart';
import 'day/training_day_status_service.dart';
import 'day/training_day_stream_service.dart';
import 'day/training_day_statistics_service.dart';
import 'day/training_day_batch_service.dart';
import '../models/training_day_model.dart';

class TrainingDayService {
  late final TrainingDayCoreService _coreService;
  late final TrainingDayQueryService _queryService;
  late final TrainingDayStatusService _statusService;
  late final TrainingDayStreamService _streamService;
  late final TrainingDayStatisticsService _statisticsService;
  late final TrainingDayBatchService _batchService;

  TrainingDayService() {
    _coreService = TrainingDayCoreService();
    _queryService = TrainingDayQueryService(_coreService);
    _statusService = TrainingDayStatusService(_coreService);
    _streamService = TrainingDayStreamService(_coreService);
    _statisticsService = TrainingDayStatisticsService(_queryService);
    _batchService = TrainingDayBatchService(_coreService);
  }

  // Core operations
  Future<String> createTrainingDay(String planId, TrainingDayModel day) =>
      _coreService.createTrainingDay(planId, day);

  Future<TrainingDayModel?> getTrainingDay(String planId, String dayId) =>
      _coreService.getTrainingDay(planId, dayId);

  Future<void> updateTrainingDay(String planId, TrainingDayModel day) =>
      _coreService.updateTrainingDay(planId, day);

  Future<void> deleteTrainingDay(String planId, String dayId) =>
      _coreService.deleteTrainingDay(planId, dayId);

  // Query operations
  Future<List<TrainingDayModel>> getTrainingDaysForPlan(String planId) =>
      _queryService.getTrainingDaysForPlan(planId);

  Future<List<TrainingDayModel>> getTrainingDaysForWeek(
    String planId,
    int week,
  ) => _queryService.getTrainingDaysForWeek(planId, week);

  Future<TrainingDayModel?> getTodaysTrainingDay(String planId) =>
      _queryService.getTodaysTrainingDay(planId);

  // Status operations
  Future<void> markTrainingDayAsCompleted(
    String planId,
    String dayId, {
    int? actualDuration,
    double? actualDistance,
  }) => _statusService.markTrainingDayAsCompleted(
    planId,
    dayId,
    actualDuration: actualDuration,
    actualDistance: actualDistance,
  );

  Future<void> markTrainingDayAsSkipped(String planId, String dayId) =>
      _statusService.markTrainingDayAsSkipped(planId, dayId);

  Future<void> lockTrainingDay(String planId, String dayId) =>
      _statusService.lockTrainingDay(planId, dayId);

  // Statistics operations
  Future<Map<String, dynamic>> getTrainingDayStats(String planId) =>
      _statisticsService.getTrainingDayStats(planId);

  Future<Map<String, dynamic>> getWeeklyStats(String planId, int week) =>
      _statisticsService.getWeeklyStats(planId, week);

  // Stream operations
  Stream<List<TrainingDayModel>> streamTrainingDaysForPlan(String planId) =>
      _streamService.streamTrainingDaysForPlan(planId);

  Stream<TrainingDayModel?> streamTodaysTrainingDay(String planId) =>
      _streamService.streamTodaysTrainingDay(planId);

  // Batch operations
  Future<void> batchUpdateTrainingDays(
    String planId,
    List<TrainingDayModel> days,
  ) => _batchService.batchUpdateTrainingDays(planId, days);

  // Expose sub-services for advanced usage
  TrainingDayCoreService get core => _coreService;
  TrainingDayQueryService get query => _queryService;
  TrainingDayStatusService get status => _statusService;
  TrainingDayStreamService get stream => _streamService;
  TrainingDayStatisticsService get statistics => _statisticsService;
  TrainingDayBatchService get batch => _batchService;
}
