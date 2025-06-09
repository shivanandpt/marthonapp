import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';
import '../models/index.dart';

class RunService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _runsCollection = FirebaseFirestore.instance
      .collection('runs');

  // Create new run
  Future<String> createRun(RunModel run) async {
    try {
      final docRef = await _runsCollection.add(run.toFirestore());
      print('Created run with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating run: $e');
      rethrow;
    }
  }

  // Get run by ID
  Future<RunModel?> getRun(String runId) async {
    try {
      final docSnapshot = await _runsCollection.doc(runId).get();
      if (docSnapshot.exists) {
        return RunModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      print('Error getting run: $e');
      rethrow;
    }
  }

  // Get all runs for a user
  Future<List<RunModel>> getUserRuns(String userId, {int? limit}) async {
    try {
      print('Fetching runs for user: $userId');

      Query query = _runsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('startTime', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      final runs =
          querySnapshot.docs
              .map((doc) {
                try {
                  return RunModel.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing run ${doc.id}: $e');
                  return null;
                }
              })
              .where((run) => run != null)
              .cast<RunModel>()
              .toList();

      print('Successfully loaded ${runs.length} runs for user $userId');
      return runs;
    } catch (e) {
      print('Error getting user runs: $e');
      return [];
    }
  }

  // Get runs with better error handling
  Future<List<RunModel>> getUserRunsSafe(String userId, {int? limit}) async {
    try {
      return await getUserRuns(userId, limit: limit);
    } catch (e) {
      print('Failed to get user runs: $e');
      return [];
    }
  }

  // Get runs by session type
  Future<List<RunModel>> getRunsBySessionType(
    String userId,
    String sessionType,
  ) async {
    try {
      final querySnapshot =
          await _runsCollection
              .where('userId', isEqualTo: userId)
              .where('sessionType', isEqualTo: sessionType)
              .orderBy('startTime', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => RunModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting runs by session type: $e');
      rethrow;
    }
  }

  // Get runs for a specific training day
  Future<List<RunModel>> getRunsForTrainingDay(String trainingDayId) async {
    try {
      final querySnapshot =
          await _runsCollection
              .where('trainingDayId', isEqualTo: trainingDayId)
              .orderBy('startTime')
              .get();

      return querySnapshot.docs
          .map((doc) => RunModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting runs for training day: $e');
      rethrow;
    }
  }

  // Get runs for a specific plan
  Future<List<RunModel>> getRunsForPlan(String planId) async {
    try {
      final querySnapshot =
          await _runsCollection
              .where('planId', isEqualTo: planId)
              .orderBy('startTime', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => RunModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting runs for plan: $e');
      rethrow;
    }
  }

  // Get runs by status
  Future<List<RunModel>> getRunsByStatus(String userId, String status) async {
    try {
      final querySnapshot =
          await _runsCollection
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: status)
              .orderBy('startTime', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => RunModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting runs by status: $e');
      rethrow;
    }
  }

  // Get completed runs for a user
  Future<List<RunModel>> getCompletedRuns(String userId, {int? limit}) async {
    return getRunsByStatus(userId, 'completed');
  }

  // Get in-progress runs for a user
  Future<List<RunModel>> getInProgressRuns(String userId) async {
    return getRunsByStatus(userId, 'in_progress');
  }

  // Update run
  Future<void> updateRun(RunModel run) async {
    try {
      // Update the updatedAt timestamp
      final updatedRun = run.copyWith(updatedAt: DateTime.now());
      await _runsCollection.doc(run.id).update(updatedRun.toFirestore());
      print('Updated run: ${run.id}');
    } catch (e) {
      print('Error updating run: $e');
      rethrow;
    }
  }

  // Update run status
  Future<void> updateRunStatus(String runId, String status) async {
    try {
      await _runsCollection.doc(runId).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated run status: $runId -> $status');
    } catch (e) {
      print('Error updating run status: $e');
      rethrow;
    }
  }

  // Add user feedback to run
  Future<void> addUserFeedback(String runId, UserFeedbackModel feedback) async {
    try {
      await _runsCollection.doc(runId).update({
        'feedback': feedback.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Added feedback to run: $runId');
    } catch (e) {
      print('Error adding user feedback: $e');
      rethrow;
    }
  }

  // Update social sharing info
  Future<void> updateSocialSharing(
    String runId,
    SocialSharingModel socialSharing,
  ) async {
    try {
      await _runsCollection.doc(runId).update({
        'socialSharing': socialSharing.toMap(),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      print('Updated social sharing for run: $runId');
    } catch (e) {
      print('Error updating social sharing: $e');
      rethrow;
    }
  }

  // Delete run
  Future<void> deleteRun(String runId) async {
    try {
      await _runsCollection.doc(runId).delete();
      print('Deleted run: $runId');
    } catch (e) {
      print('Error deleting run: $e');
      rethrow;
    }
  }

  // Get runs in date range
  Future<List<RunModel>> getRunsInDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot =
          await _runsCollection
              .where('userId', isEqualTo: userId)
              .where(
                'startTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'startTime',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .orderBy('startTime')
              .get();

      return querySnapshot.docs
          .map((doc) => RunModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting runs in date range: $e');
      rethrow;
    }
  }

  // Get runs for current week
  Future<List<RunModel>> getCurrentWeekRuns(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(
      Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    return getRunsInDateRange(userId, startOfWeek, endOfWeek);
  }

  // Get runs for current month
  Future<List<RunModel>> getCurrentMonthRuns(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(Duration(seconds: 1));

    return getRunsInDateRange(userId, startOfMonth, endOfMonth);
  }

  // Stream user runs for real-time updates
  Stream<List<RunModel>> streamUserRuns(String userId, {int? limit}) {
    Query query = _runsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) {
                try {
                  return RunModel.fromFirestore(doc);
                } catch (e) {
                  print('Error parsing run ${doc.id} in stream: $e');
                  return null;
                }
              })
              .where((run) => run != null)
              .cast<RunModel>()
              .toList(),
    );
  }

  // Stream runs by status
  Stream<List<RunModel>> streamRunsByStatus(String userId, String status) {
    return _runsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => RunModel.fromFirestore(doc)).toList(),
        );
  }

  // Get user's comprehensive stats
  Future<Map<String, dynamic>> getUserStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final runs = await getRunsInDateRange(userId, startDate, endDate);
      final completedRuns = runs.where((run) => run.isCompleted).toList();

      int totalRuns = completedRuns.length;
      double totalDistance = 0.0;
      int totalDuration = 0;
      int totalActiveDuration = 0;
      int totalCalories = 0;
      int totalSteps = 0;
      double totalElevationGain = 0.0;

      // Heart rate stats
      List<int> heartRates = [];
      Map<String, int> sessionTypes = {};

      for (var run in completedRuns) {
        totalDistance += run.totalDistance;
        totalDuration += run.duration;
        totalActiveDuration += run.activeDuration;
        totalCalories += run.calories;
        totalSteps += run.steps;
        totalElevationGain += run.elevationGain;

        // Count session types
        sessionTypes[run.sessionType] =
            (sessionTypes[run.sessionType] ?? 0) + 1;

        // Collect heart rate data
        if (run.heartRate != null) {
          heartRates.add(run.heartRate!.avg);
        }
      }

      // Calculate averages
      double avgDistance = totalRuns > 0 ? totalDistance / totalRuns : 0.0;
      double avgDuration = totalRuns > 0 ? totalDuration / totalRuns : 0.0;
      double avgPace =
          totalRuns > 0
              ? completedRuns.map((r) => r.avgPace).reduce((a, b) => a + b) /
                  totalRuns
              : 0.0;
      double avgSpeed =
          totalRuns > 0
              ? completedRuns.map((r) => r.avgSpeed).reduce((a, b) => a + b) /
                  totalRuns
              : 0.0;
      int avgHeartRate =
          heartRates.isNotEmpty
              ? heartRates.reduce((a, b) => a + b) ~/ heartRates.length
              : 0;

      // Best performances
      double bestDistance =
          completedRuns.isNotEmpty
              ? completedRuns
                  .map((r) => r.totalDistance)
                  .reduce((a, b) => a > b ? a : b)
              : 0.0;
      double bestPace =
          completedRuns.isNotEmpty
              ? completedRuns
                  .map((r) => r.bestPace)
                  .reduce((a, b) => a < b ? a : b)
              : 0.0;
      double bestSpeed =
          completedRuns.isNotEmpty
              ? completedRuns
                  .map((r) => r.maxSpeed)
                  .reduce((a, b) => a > b ? a : b)
              : 0.0;

      return {
        'totalRuns': totalRuns,
        'totalDistance': totalDistance,
        'totalDuration': totalDuration,
        'totalActiveDuration': totalActiveDuration,
        'totalCalories': totalCalories,
        'totalSteps': totalSteps,
        'totalElevationGain': totalElevationGain,
        'avgDistance': avgDistance,
        'avgDuration': avgDuration,
        'avgPace': avgPace,
        'avgSpeed': avgSpeed,
        'avgHeartRate': avgHeartRate,
        'bestDistance': bestDistance,
        'bestPace': bestPace,
        'bestSpeed': bestSpeed,
        'sessionTypes': sessionTypes,
        'runs': completedRuns,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      rethrow;
    }
  }

  // Get weekly stats
  Future<Map<String, dynamic>> getWeeklyStats(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(
      Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    return getUserStats(userId, startOfWeek, endOfWeek);
  }

  // Get monthly stats
  Future<Map<String, dynamic>> getMonthlyStats(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(Duration(seconds: 1));

    return getUserStats(userId, startOfMonth, endOfMonth);
  }

  // Get yearly stats
  Future<Map<String, dynamic>> getYearlyStats(String userId) async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    return getUserStats(userId, startOfYear, endOfYear);
  }

  // Get run count by month for charts
  Future<Map<String, int>> getRunCountByMonth(String userId, int year) async {
    try {
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

      final runs = await getRunsInDateRange(userId, startOfYear, endOfYear);
      final completedRuns = runs.where((run) => run.isCompleted).toList();

      Map<String, int> monthlyCount = {};

      for (int month = 1; month <= 12; month++) {
        final monthName = DateTime(
          year,
          month,
        ).month.toString().padLeft(2, '0');
        monthlyCount[monthName] = 0;
      }

      for (var run in completedRuns) {
        final monthKey = run.startTime.month.toString().padLeft(2, '0');
        monthlyCount[monthKey] = (monthlyCount[monthKey] ?? 0) + 1;
      }

      return monthlyCount;
    } catch (e) {
      print('Error getting run count by month: $e');
      rethrow;
    }
  }

  // Get personal records
  Future<Map<String, dynamic>> getPersonalRecords(String userId) async {
    try {
      final allRuns = await getUserRuns(userId);
      final completedRuns = allRuns.where((run) => run.isCompleted).toList();

      if (completedRuns.isEmpty) {
        return {};
      }

      // Distance records
      final longestRun = completedRuns.reduce(
        (a, b) => a.totalDistance > b.totalDistance ? a : b,
      );

      // Speed records
      final fastestRun = completedRuns.reduce(
        (a, b) => a.maxSpeed > b.maxSpeed ? a : b,
      );

      // Pace records
      final bestPaceRun = completedRuns.reduce(
        (a, b) => a.bestPace < b.bestPace ? a : b,
      );

      // Duration records
      final longestDurationRun = completedRuns.reduce(
        (a, b) => a.duration > b.duration ? a : b,
      );

      return {
        'longestDistance': {
          'value': longestRun.totalDistance,
          'run': longestRun,
        },
        'fastestSpeed': {'value': fastestRun.maxSpeed, 'run': fastestRun},
        'bestPace': {'value': bestPaceRun.bestPace, 'run': bestPaceRun},
        'longestDuration': {
          'value': longestDurationRun.duration,
          'run': longestDurationRun,
        },
      };
    } catch (e) {
      print('Error getting personal records: $e');
      rethrow;
    }
  }

  // Get next run number for user
  Future<int> getNextRunNumber(String userId) async {
    try {
      final querySnapshot =
          await _runsCollection
              .where('userId', isEqualTo: userId)
              .orderBy('runNumber', descending: true)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return 1;
      }

      final lastRun = RunModel.fromFirestore(querySnapshot.docs.first);
      return lastRun.runNumber + 1;
    } catch (e) {
      print('Error getting next run number: $e');
      return 1;
    }
  }

  // Batch operations for better performance
  Future<void> batchUpdateRuns(List<RunModel> runs) async {
    try {
      final batch = _firestore.batch();

      for (var run in runs) {
        final updatedRun = run.copyWith(updatedAt: DateTime.now());
        batch.update(_runsCollection.doc(run.id), updatedRun.toFirestore());
      }

      await batch.commit();
      print('Batch updated ${runs.length} runs');
    } catch (e) {
      print('Error in batch update: $e');
      rethrow;
    }
  }

  // Search runs by notes or other text fields
  Future<List<RunModel>> searchRuns(String userId, String searchTerm) async {
    try {
      final allRuns = await getUserRuns(userId);

      final filteredRuns =
          allRuns.where((run) {
            final notes = run.feedback?.notes.toLowerCase() ?? '';
            final sessionType = run.sessionType.toLowerCase();
            final search = searchTerm.toLowerCase();

            return notes.contains(search) || sessionType.contains(search);
          }).toList();

      return filteredRuns;
    } catch (e) {
      print('Error searching runs: $e');
      rethrow;
    }
  }

  /// Save a new run to Firestore with all required fields
  Future<String> saveRun({
    required String userId,
    required double distance,
    required int duration,
    required List<Map<String, dynamic>> routePoints,
    required DateTime startTime,
    String? planId,
    String? trainingDayId,
    String sessionType = 'free_run',
    int? pausedDuration,
    int? activeDuration,
    List<Map<String, dynamic>>? phasesCompleted,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? socialSharing,
    Map<String, dynamic>? feedback,
    Map<String, dynamic>? heartRate,
    Map<String, dynamic>? weather,
  }) async {
    try {
      // Get next run number
      final runNumber = await getNextRunNumber(userId);

      // Calculate metrics
      final actualActiveDuration = activeDuration ?? duration;
      final actualPausedDuration = pausedDuration ?? 0;
      final avgSpeed =
          actualActiveDuration > 0
              ? (distance * 1000) / actualActiveDuration
              : 0.0; // m/s
      final avgPace =
          distance > 0 ? actualActiveDuration / distance : 0.0; // s/km
      final elevationGain = _calculateElevationGain(routePoints);
      final elevationLoss = _calculateElevationLoss(routePoints);

      // Create route points
      final routePointModels =
          routePoints.map((point) {
            return RoutePointModel(
              timestamp: DateTime.fromMillisecondsSinceEpoch(
                point['timestamp'],
              ),
              latitude: point['latitude'],
              longitude: point['longitude'],
              elevation: point['elevation'] ?? 0.0,
              speed: point['speed'] ?? 0.0,
              accuracy: point['accuracy'] ?? 0.0,
            );
          }).toList();

      // Calculate max speed
      final maxSpeed =
          routePoints.isNotEmpty
              ? routePoints
                  .map((p) => p['speed'] ?? 0.0)
                  .reduce((a, b) => a > b ? a : b)
              : 0.0;

      // Calculate best pace (assume same as avg pace for now)
      final bestPace = avgPace;

      // Calculate steps and calories
      final steps = _estimateSteps(distance);
      final calories = _estimateCalories(distance, actualActiveDuration);

      // Default cadence (steps per minute)
      final cadence =
          actualActiveDuration > 0
              ? (steps / (actualActiveDuration / 60)).round()
              : 0;

      // Calculate completion rate
      final completionRate =
          phasesCompleted != null ? 1.0 : 1.0; // 100% for completed runs

      // Create the run model
      final run = RunModel(
        id: '', // Will be set by Firestore
        userId: userId,
        trainingDayId: trainingDayId,
        planId: planId,
        runNumber: runNumber,
        sessionType: sessionType,
        startTime: startTime,
        endTime: startTime.add(Duration(seconds: duration)),
        duration: duration,
        activeDuration: actualActiveDuration,
        pausedDuration: actualPausedDuration,
        totalDistance: distance,
        elevationGain: elevationGain,
        elevationLoss: elevationLoss,
        avgSpeed: avgSpeed,
        maxSpeed: maxSpeed,
        avgPace: avgPace,
        bestPace: bestPace,
        steps: steps,
        cadence: cadence,
        calories: calories,
        heartRate: heartRate != null ? HeartRateModel.fromMap(heartRate) : null,
        weather: weather != null ? WeatherModel.fromMap(weather) : null,
        routePoints: routePointModels,
        phasesCompleted:
            phasesCompleted
                ?.map((phase) => PhaseCompletionModel.fromMap(phase))
                .toList() ??
            [],
        settings:
            settings != null
                ? RunSettingsModel.fromMap(settings)
                : _getDefaultSettings(),
        socialSharing:
            socialSharing != null
                ? SocialSharingModel.fromMap(socialSharing)
                : _getDefaultSocialSharing(),
        status: 'completed',
        completionRate: completionRate,
        feedback: feedback != null ? UserFeedbackModel.fromMap(feedback) : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final docRef = await _runsCollection.add(run.toFirestore());

      print('Successfully saved run with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving run: $e');
      throw Exception('Failed to save run: $e');
    }
  }

  /// Calculate elevation loss from route points
  double _calculateElevationLoss(List<Map<String, dynamic>> routePoints) {
    if (routePoints.length < 2) return 0.0;

    double totalLoss = 0.0;
    for (int i = 1; i < routePoints.length; i++) {
      final current = routePoints[i]['elevation'] ?? 0.0;
      final previous = routePoints[i - 1]['elevation'] ?? 0.0;
      final loss =
          previous - current; // Loss is when previous is higher than current
      if (loss > 0) {
        totalLoss += loss;
      }
    }
    return totalLoss;
  }

  /// Calculate elevation gain from route points
  double _calculateElevationGain(List<Map<String, dynamic>> routePoints) {
    if (routePoints.length < 2) return 0.0;

    double totalGain = 0.0;
    for (int i = 1; i < routePoints.length; i++) {
      final current = routePoints[i]['elevation'] ?? 0.0;
      final previous = routePoints[i - 1]['elevation'] ?? 0.0;
      final gain = current - previous;
      if (gain > 0) {
        totalGain += gain;
      }
    }
    return totalGain;
  }

  /// Estimate calories burned (rough calculation)
  int _estimateCalories(double distanceKm, int durationSeconds) {
    try {
      // More accurate calorie calculation based on MET values
      // Running MET values: 8.0 for 8 km/h, 11.5 for 12 km/h, 15.0 for 16 km/h
      const double avgBodyWeight = 70.0; // kg

      if (durationSeconds == 0) return 0;

      final speedKmh = (distanceKm / durationSeconds) * 3600;
      double met = 8.0; // Default MET value

      if (speedKmh >= 16) {
        met = 15.0;
      } else if (speedKmh >= 12) {
        met = 11.5;
      } else if (speedKmh >= 8) {
        met = 8.0;
      } else {
        met = 6.0; // Walking/jogging
      }

      final durationHours = durationSeconds / 3600.0;
      final calories = met * avgBodyWeight * durationHours;

      return calories.round();
    } catch (e) {
      return 0;
    }
  }

  /// Estimate steps based on distance
  int _estimateSteps(double distanceKm) {
    try {
      // Average stride length varies by height and pace
      // Using 0.78m as average stride length for running
      const double avgStrideLengthM = 0.78;
      final distanceM = distanceKm * 1000;
      final steps = (distanceM / avgStrideLengthM).round();
      return steps;
    } catch (e) {
      return 0;
    }
  }

  /// Batch upload pending runs from local storage
  Future<List<String>> uploadPendingRuns(
    List<Map<String, dynamic>> pendingRuns,
  ) async {
    final uploadedRunIds = <String>[];

    for (final runData in pendingRuns) {
      try {
        final runId = await saveRun(
          userId: runData['userId'],
          distance: runData['distance'],
          duration: runData['duration'],
          routePoints: List<Map<String, dynamic>>.from(runData['routePoints']),
          startTime: DateTime.parse(runData['startTime']),
          planId: runData['planId'],
          trainingDayId: runData['trainingDayId'],
          sessionType: runData['sessionType'] ?? 'free_run',
        );
        uploadedRunIds.add(runData['id']); // Local ID for removal
        print('Successfully uploaded pending run: ${runData['id']}');
      } catch (e) {
        print('Failed to upload run ${runData['id']}: $e');
        // Continue with other runs even if one fails
      }
    }

    return uploadedRunIds;
  }

  /// Save run with full RunModel (alternative method)
  Future<String> saveRunModel(RunModel run) async {
    try {
      final docRef = await _runsCollection.add(run.toFirestore());
      print('Saved run model with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error saving run model: $e');
      throw Exception('Failed to save run model: $e');
    }
  }

  /// Quick save method for manual/simple runs
  Future<String> saveQuickRun({
    required String userId,
    required double distance,
    required int duration,
    DateTime? startTime,
    String sessionType = 'manual',
  }) async {
    try {
      return await saveRun(
        userId: userId,
        distance: distance,
        duration: duration,
        routePoints: [], // No GPS data for quick runs
        startTime:
            startTime ?? DateTime.now().subtract(Duration(seconds: duration)),
        sessionType: sessionType,
      );
    } catch (e) {
      print('Error saving quick run: $e');
      throw Exception('Failed to save quick run: $e');
    }
  }

  /// Get default run settings
  RunSettingsModel _getDefaultSettings() {
    return RunSettingsModel.defaultSettings();
  }

  /// Get default social sharing settings
  SocialSharingModel _getDefaultSocialSharing() {
    return SocialSharingModel.defaultSettings();
  }
}
