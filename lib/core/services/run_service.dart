import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/run_model.dart';

class RunService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _runsCollection;

  RunService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _runsCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'runs',
      );

  // Create new run
  Future<String> createRun(RunModel run) async {
    try {
      final docRef = await _runsCollection.add(run.toFirestore());
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
        return RunModel.fromFirestore(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      print('Error getting run: $e');
      rethrow;
    }
  }

  // Get all runs for a user
  Future<List<RunModel>> getUserRuns(String userId) async {
    try {
      final querySnapshot =
          await _runsCollection
              .where('userId', isEqualTo: userId)
              .orderBy('startTime', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => RunModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user runs: $e');
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
          .map((doc) => RunModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting runs for training day: $e');
      rethrow;
    }
  }

  // Update run
  Future<void> updateRun(RunModel run) async {
    try {
      await _runsCollection.doc(run.id).update(run.toFirestore());
    } catch (e) {
      print('Error updating run: $e');
      rethrow;
    }
  }

  // Delete run
  Future<void> deleteRun(String runId) async {
    try {
      await _runsCollection.doc(runId).delete();
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
              .where('startTime', isGreaterThanOrEqualTo: startDate)
              .where('startTime', isLessThanOrEqualTo: endDate)
              .orderBy('startTime')
              .get();

      return querySnapshot.docs
          .map((doc) => RunModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting runs in date range: $e');
      rethrow;
    }
  }

  // Stream user runs for real-time updates
  Stream<List<RunModel>> streamUserRuns(String userId) {
    return _runsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => RunModel.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Get user's stats (total distance, runs, time) for a date range
  Future<Map<String, dynamic>> getUserStats(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final runs = await getRunsInDateRange(userId, startDate, endDate);

      int totalRuns = runs.length;
      double totalDistance = 0.0;
      int totalDuration = 0;

      for (var run in runs) {
        totalDistance += run.totalDistance;
        totalDuration += run.duration;
      }

      return {
        'totalRuns': totalRuns,
        'totalDistance': totalDistance,
        'totalDuration': totalDuration,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      rethrow;
    }
  }
}
