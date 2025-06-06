import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/features/home/models/plan/plan_structure_model.dart';
import '../../models/plan/plan_dates_model.dart';
import '../../models/plan/plan_progress_model.dart';
import '../../models/plan/plan_settings_model.dart';
import '../../models/plan/plan_statistics_model.dart';
import 'training_plan_core_service.dart';

class TrainingPlanUpdateService {
  final TrainingPlanCoreService _coreService;

  TrainingPlanUpdateService(this._coreService);

  // Update plan progress
  Future<void> updatePlanProgress(
    String planId,
    PlanProgressModel progress,
  ) async {
    try {
      await _coreService.plansCollection.doc(planId).update({
        'progress': progress.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated plan progress: $planId');
    } catch (e) {
      print('Error updating plan progress: $e');
      rethrow;
    }
  }

  // Update plan structure
  Future<void> updatePlanStructure(
    String planId,
    PlanStructureModel structure,
  ) async {
    try {
      await _coreService.plansCollection.doc(planId).update({
        'structure': structure.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated plan structure: $planId');
    } catch (e) {
      print('Error updating plan structure: $e');
      rethrow;
    }
  }

  // Update plan dates
  Future<void> updatePlanDates(String planId, PlanDatesModel dates) async {
    try {
      await _coreService.plansCollection.doc(planId).update({
        'dates': dates.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated plan dates: $planId');
    } catch (e) {
      print('Error updating plan dates: $e');
      rethrow;
    }
  }

  // Update plan settings
  Future<void> updatePlanSettings(
    String planId,
    PlanSettingsModel settings,
  ) async {
    try {
      await _coreService.plansCollection.doc(planId).update({
        'settings': settings.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated plan settings: $planId');
    } catch (e) {
      print('Error updating plan settings: $e');
      rethrow;
    }
  }

  // Update plan statistics
  Future<void> updatePlanStatistics(
    String planId,
    PlanStatisticsModel statistics,
  ) async {
    try {
      await _coreService.plansCollection.doc(planId).update({
        'statistics': statistics.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated plan statistics: $planId');
    } catch (e) {
      print('Error updating plan statistics: $e');
      rethrow;
    }
  }

  // Batch operations
  Future<void> batchUpdatePlans(List<Map<String, dynamic>> updates) async {
    try {
      final batch = _coreService.firestore.batch();

      for (var update in updates) {
        final planId = update['planId'] as String;
        final data = update['data'] as Map<String, dynamic>;
        data['updatedAt'] = Timestamp.fromDate(DateTime.now());

        batch.update(_coreService.plansCollection.doc(planId), data);
      }

      await batch.commit();
      print('Batch updated ${updates.length} plans');
    } catch (e) {
      print('Error in batch update: $e');
      rethrow;
    }
  }

  // Update specific fields
  Future<void> updatePlanField(
    String planId,
    String fieldPath,
    dynamic value,
  ) async {
    try {
      await _coreService.plansCollection.doc(planId).update({
        fieldPath: value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated plan field $fieldPath: $planId');
    } catch (e) {
      print('Error updating plan field: $e');
      rethrow;
    }
  }
}
