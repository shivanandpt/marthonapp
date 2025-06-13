import 'package:flutter/foundation.dart';

class NavigationController with ChangeNotifier {
  int _currentStep = 0;
  final int totalSteps = 4;

  int get currentStep => _currentStep;

  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void skipToLastStep() {
    _currentStep = totalSteps - 1;
    notifyListeners();
  }

  void reset() {
    _currentStep = 0;
    notifyListeners();
  }
}
