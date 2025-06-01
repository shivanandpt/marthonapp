import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/training_day_model.dart';

class TrainingDayService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _daysCollection;

  TrainingDayService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _daysCollection = (firestore ?? FirebaseFirestore.instance).collection(
        'training_days',
      );

  // Create new training day
  Future<String> createTrainingDay(TrainingDayModel day) async {
    try {
      final docRef = await _daysCollection.add(day.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating training day: $e');
      rethrow;
    }
  }

  // Get training day by ID
  Future<TrainingDayModel?> getTrainingDay(String dayId) async {
    try {
      final docSnapshot = await _daysCollection.doc(dayId).get();
      if (docSnapshot.exists) {
        return TrainingDayModel.fromFirestore(
          docSnapshot.data()!,
          docSnapshot.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting training day: $e');
      rethrow;
    }
  }

  // Get training days for a plan
  Future<List<TrainingDayModel>> getTrainingDaysForPlan(String planId) async {
    try {
      final querySnapshot =
          await _daysCollection
              .where('planId', isEqualTo: planId)
              .orderBy('week')
              .orderBy('dayOfWeek')
              .get();

      return querySnapshot.docs
          .map((doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting training days for plan: $e');
      rethrow;
    }
  }

  // Get training days for a specific week in a plan
  Future<List<TrainingDayModel>> getTrainingDaysForWeek(
    String planId,
    int week,
  ) async {
    try {
      final querySnapshot =
          await _daysCollection
              .where('planId', isEqualTo: planId)
              .where('week', isEqualTo: week)
              .orderBy('dayOfWeek')
              .get();

      return querySnapshot.docs
          .map((doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting training days for week: $e');
      rethrow;
    }
  }

  // Get training day for a specific date
  Future<TrainingDayModel?> getTrainingDayForDate(
    String planId,
    DateTime date,
  ) async {
    try {
      // Convert DateTime to Timestamp for Firestore query
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final querySnapshot =
          await _daysCollection
              .where('planId', isEqualTo: planId)
              .where('dateScheduled', isGreaterThanOrEqualTo: startOfDay)
              .where('dateScheduled', isLessThanOrEqualTo: endOfDay)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return TrainingDayModel.fromFirestore(
          querySnapshot.docs.first.data(),
          querySnapshot.docs.first.id,
        );
      }
      return null;
    } catch (e) {
      print('Error getting training day for date: $e');
      rethrow;
    }
  }

  // Update training day
  Future<void> updateTrainingDay(TrainingDayModel day) async {
    try {
      await _daysCollection.doc(day.id).update(day.toFirestore());
    } catch (e) {
      print('Error updating training day: $e');
      rethrow;
    }
  }

  // Delete training day
  Future<void> deleteTrainingDay(String dayId) async {
    try {
      await _daysCollection.doc(dayId).delete();
    } catch (e) {
      print('Error deleting training day: $e');
      rethrow;
    }
  }

  // Delete all training days for a plan
  Future<void> deleteTrainingDaysForPlan(String planId) async {
    try {
      final querySnapshot =
          await _daysCollection.where('planId', isEqualTo: planId).get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting training days for plan: $e');
      rethrow;
    }
  }

  // Stream training days for a plan
  Stream<List<TrainingDayModel>> streamTrainingDaysForPlan(String planId) {
    return _daysCollection
        .where('planId', isEqualTo: planId)
        .orderBy('week')
        .orderBy('dayOfWeek')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => TrainingDayModel.fromFirestore(doc.data(), doc.id),
                  )
                  .toList(),
        );
  }
}
