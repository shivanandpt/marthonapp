import 'package:flutter/foundation.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/user_model.dart';

class HealthInfoStepController with ChangeNotifier {
  String? injuryNotes;
  String? experience;

  void updateInjuryNotes(String value) {
    injuryNotes = value;
    // Don't notify listeners to prevent cursor jumping
  }

  void updateInjuryNotesWithNotify(String value) {
    injuryNotes = value;
    notifyListeners();
  }

  void updateExperience(String value) {
    experience = value;
    notifyListeners();
  }

  bool validate() {
    return true; // Optional step
  }

  void loadFromUserModel(UserModel user) {
    injuryNotes = user.injuryNotes;
    experience = user.experience;
  }
}
