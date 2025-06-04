import 'package:flutter/foundation.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/user_model.dart';

class BasicInfoStepController with ChangeNotifier {
  String name = '';
  String email = '';
  String profilePic = '';
  String _selectedGoal = '5K';
  DateTime? goalEventDate;

  String get selectedGoal => _selectedGoal;

  static const List<String> runningGoals = [
    '5K',
    '10K',
    'Half Marathon',
    'Full Marathon',
  ];

  void updateName(String value) {
    name = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updateProfilePic(String value) {
    profilePic = value;
    notifyListeners();
  }

  void setGoal(String goalValue) {
    _selectedGoal = goalValue;
    _setDefaultGoalEventDate(goalValue);
    notifyListeners();
  }

  void updateGoalEventDate(DateTime? date) {
    goalEventDate = date;
    notifyListeners();
  }

  void _setDefaultGoalEventDate(String selectedGoal) {
    final now = DateTime.now();

    switch (selectedGoal) {
      case '5K':
        goalEventDate = now.add(Duration(days: 70)); // ~10 weeks
        break;
      case '10K':
        goalEventDate = now.add(Duration(days: 91)); // ~13 weeks
        break;
      case 'Half Marathon':
        goalEventDate = now.add(Duration(days: 112)); // ~16 weeks
        break;
      case 'Full Marathon':
        goalEventDate = now.add(Duration(days: 140)); // ~20 weeks
        break;
      default:
        goalEventDate = now.add(Duration(days: 70));
    }
  }

  bool validate() {
    return name.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        _selectedGoal.isNotEmpty;
  }

  List<String> getRunningGoals() => runningGoals;

  void loadFromUserModel(UserModel user) {
    name = user.name;
    email = user.email;
    profilePic = user.profilePic;
    _selectedGoal = user.goal;
    goalEventDate = user.goalEventDate;
  }
}
