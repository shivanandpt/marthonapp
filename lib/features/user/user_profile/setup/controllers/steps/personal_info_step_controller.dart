import 'package:flutter/foundation.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/user_model.dart';

class PersonalInfoStepController with ChangeNotifier {
  DateTime? dob;
  String? gender;
  String language = 'English';
  String timezone = 'UTC';

  void updateDob(DateTime? date) {
    dob = date;
    notifyListeners();
  }

  void updateGender(String value) {
    gender = value;
    notifyListeners();
  }

  void updateLanguage(String value) {
    language = value;
    notifyListeners();
  }

  void updateTimezone(String value) {
    timezone = value;
    notifyListeners();
  }

  int get calculatedAge {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob!.year;
    if (now.month < dob!.month ||
        (now.month == dob!.month && now.day < dob!.day)) {
      age--;
    }
    return age;
  }

  bool validate() {
    return dob != null && gender != null;
  }

  void loadFromUserModel(UserModel user) {
    dob = user.dob;
    gender = user.gender;
    language = user.language == 'en' ? 'English' : 'Spanish';
    timezone = user.timezone;
  }
}
