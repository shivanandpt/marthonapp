import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marunthon_app/models/setting_model.dart';

class SettingsService {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _settingsCollection;

  SettingsService({FirebaseFirestore? firestore}) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _settingsCollection = (firestore ?? FirebaseFirestore.instance).collection('settings');

  // Get settings for a user
  Future<SettingsModel> getUserSettings(String userId) async {
    try {
      final docSnapshot = await _settingsCollection.doc(userId).get();
      if (docSnapshot.exists) {
        return SettingsModel.fromFirestore(docSnapshot.data()!);
      }
      
      // Return default settings if not found
      return SettingsModel(darkMode: false, notificationsEnabled: true);
    } catch (e) {
      print('Error getting user settings: $e');
      // Return default settings on error
      return SettingsModel(darkMode: false, notificationsEnabled: true);
    }
  }

  // Save settings for a user
  Future<void> saveUserSettings(String userId, SettingsModel settings) async {
    try {
      await _settingsCollection.doc(userId).set(settings.toFirestore());
    } catch (e) {
      print('Error saving user settings: $e');
      rethrow;
    }
  }

  // Update specific settings for a user
  Future<void> updateUserSettings(String userId, Map<String, dynamic> updates) async {
    try {
      await _settingsCollection.doc(userId).update(updates);
    } catch (e) {
      // If document doesn't exist, create it
      if (e is FirebaseException && e.code == 'not-found') {
        await _settingsCollection.doc(userId).set(updates);
      } else {
        print('Error updating user settings: $e');
        rethrow;
      }
    }
  }

  // Toggle dark mode
  Future<void> toggleDarkMode(String userId, bool darkMode) async {
    try {
      await _settingsCollection.doc(userId).update({'darkMode': darkMode});
    } catch (e) {
      // If document doesn't exist, create it
      if (e is FirebaseException && e.code == 'not-found') {
        await _settingsCollection.doc(userId).set({
          'darkMode': darkMode,
          'notificationsEnabled': true
        });
      } else {
        print('Error toggling dark mode: $e');
        rethrow;
      }
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications(String userId, bool enabled) async {
    try {
      await _settingsCollection.doc(userId).update({'notificationsEnabled': enabled});
    } catch (e) {
      // If document doesn't exist, create it
      if (e is FirebaseException && e.code == 'not-found') {
        await _settingsCollection.doc(userId).set({
          'darkMode': false,
          'notificationsEnabled': enabled
        });
      } else {
        print('Error toggling notifications: $e');
        rethrow;
      }
    }
  }

  // Stream user settings for real-time updates
  Stream<SettingsModel> streamUserSettings(String userId) {
    return _settingsCollection.doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return SettingsModel.fromFirestore(snapshot.data()!);
      }
      return SettingsModel(darkMode: false, notificationsEnabled: true);
    });
  }
}