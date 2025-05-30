class SettingsModel {
  final bool darkMode;
  final bool notificationsEnabled;

  SettingsModel({required this.darkMode, required this.notificationsEnabled});

  // Convert Firestore document to SettingsModel
  factory SettingsModel.fromFirestore(Map<String, dynamic> data) {
    return SettingsModel(
      darkMode: data['darkMode'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }

  // Convert SettingsModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {'darkMode': darkMode, 'notificationsEnabled': notificationsEnabled};
  }
}
