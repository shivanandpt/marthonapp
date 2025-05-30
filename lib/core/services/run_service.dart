import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/run_model.dart';

class RunService {
  final _runsRef = FirebaseFirestore.instance.collection('runs');

  /// Save run data
  Future<void> saveRun({
    required String userId,
    required double distance,
    required double speed,
    required double elevation,
    required int duration,
    required List<Map<String, dynamic>> routePoints, // Include route points
  }) async {
    try {
      await _runsRef.add({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'distance': distance,
        'speed': speed,
        'elevation': elevation,
        'duration': duration,
        'routePoints': routePoints, // Save route points
      });
      print("Run saved successfully!");
    } catch (e) {
      print("Error saving run: $e");
    }
  }

  /// Get runs for a specific user
  Future<List<Map<String, dynamic>>> getUserRuns(String userId) async {
    try {
      QuerySnapshot snapshot =
          await _runsRef
              .where('userId', isEqualTo: userId)
              .orderBy('timestamp', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Error fetching runs: $e");
      return [];
    }
  }

  Future<List<RunModel>> fetchRuns({
    required String userId,
    DocumentSnapshot? startAfter,
    int limit = 10,
  }) async {
    Query query = _runsRef
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => RunModel.fromFirestore(doc)).toList();
  }

  Future<List<RunModel>> fetchAllRuns({required String userId}) async {
    final snapshot =
        await _runsRef
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();

    return snapshot.docs.map((doc) => RunModel.fromFirestore(doc)).toList();
  }

  // Delete a specific run
  Future<void> deleteRun(String runId) async {
    try {
      await _runsRef.doc(runId).delete();
      print("Run deleted successfully!");
    } catch (e) {
      print("Error deleting run: $e");
    }
  }
}
