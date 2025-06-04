import 'package:flutter/foundation.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/user_model.dart';

class PhysicalAttributesStepController with ChangeNotifier {
  String metricSystem = 'metric';
  int? weight;
  int? height;
  int runDaysPerWeek = 3;

  void updateMetricSystem(String value) {
    metricSystem = value;
    notifyListeners();
  }

  void updateWeight(int? value) {
    weight = value;
    notifyListeners();
  }

  void updateHeight(int? value) {
    height = value;
    notifyListeners();
  }

  void updateRunDaysPerWeek(int value) {
    runDaysPerWeek = value;
    notifyListeners();
  }

  bool validate() {
    return runDaysPerWeek > 0;
  }

  void loadFromUserModel(UserModel user) {
    metricSystem = user.metricSystem;
    weight = user.weight;
    height = user.height;
    runDaysPerWeek = user.runDaysPerWeek;
  }
}
