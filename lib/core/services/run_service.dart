import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/run_model.dart';

class RunService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _runsCollection = FirebaseFirestore.instance
      .collection('runs');

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
        return RunModel.fromFirestore(
          docSnapshot.data()! as Map<String, dynamic>,
          docSnapshot.id,
        );
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
      print('Fetching runs for user: $userId');

      final querySnapshot =
          await _runsCollection
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();

      print('Found ${querySnapshot.docs.length} runs');

      final List<RunModel> runs = [];

      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          print('Processing run doc: ${doc.id}');

          // Validate required fields before creating model
          if (data['userId'] == null) {
            print('Warning: Run ${doc.id} has null userId, skipping');
            continue;
          }

          final run = RunModel.fromFirestore(data, doc.id);
          runs.add(run);
        } catch (e) {
          print('Error processing run document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
          // Continue processing other documents instead of failing completely
          continue;
        }
      }

      print('Successfully processed ${runs.length} runs');
      return runs;
    } catch (e) {
      print('Error getting user runs: $e');
      // Return empty list instead of throwing error to prevent app crash
      return [];
    }
  }

  // Add method to get runs with better error handling
  Future<List<RunModel>> getUserRunsSafe(String userId) async {
    try {
      return await getUserRuns(userId);
    } catch (e) {
      print('Failed to get user runs: $e');
      return []; // Return empty list on any error
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
          .map(
            (doc) => RunModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
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
          .map(
            (doc) => RunModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
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
                  .map(
                    (doc) => RunModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
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
