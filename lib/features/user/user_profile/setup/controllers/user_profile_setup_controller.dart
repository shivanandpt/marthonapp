import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_data_service.dart';
import 'navigation_controller.dart';
import 'steps/basic_info_step_controller.dart';
import 'steps/personal_info_step_controller.dart';
import 'steps/physical_attributes_step_controller.dart';
import 'steps/health_info_step_controller.dart';

class UserProfileSetupController with ChangeNotifier {
  // Sub-controllers
  final NavigationController navigationController = NavigationController();
  final BasicInfoStepController basicInfoController = BasicInfoStepController();
  final PersonalInfoStepController personalInfoController =
      PersonalInfoStepController();
  final PhysicalAttributesStepController physicalAttributesController =
      PhysicalAttributesStepController();
  final HealthInfoStepController healthInfoController =
      HealthInfoStepController();

  // Services
  final UserDataService _userDataService = UserDataService();

  // Firebase user
  User? _firebaseUser;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isEditMode = false;

  UserProfileSetupController() {
    // Listen to sub-controllers
    navigationController.addListener(() => notifyListeners());
    basicInfoController.addListener(() => notifyListeners());
    personalInfoController.addListener(() => notifyListeners());
    physicalAttributesController.addListener(() => notifyListeners());
    healthInfoController.addListener(() => notifyListeners());
  }

  @override
  void dispose() {
    navigationController.dispose();
    basicInfoController.dispose();
    personalInfoController.dispose();
    physicalAttributesController.dispose();
    healthInfoController.dispose();
    super.dispose();
  }

  Future<void> initialize({bool isEditMode = false}) async {
    _isLoading = true;
    this.isEditMode = isEditMode;
    notifyListeners();

    try {
      _firebaseUser = FirebaseAuth.instance.currentUser;

      if (_firebaseUser != null) {
        // Initialize basic info from Firebase user
        basicInfoController.updateName(_firebaseUser!.displayName ?? '');
        basicInfoController.updateEmail(_firebaseUser!.email ?? '');
        basicInfoController.updateProfilePic(_firebaseUser!.photoURL ?? '');

        if (isEditMode) {
          // Load existing user profile
          final userProfile = await _userDataService.loadUserProfile(
            _firebaseUser!.uid,
          );
          if (userProfile != null) {
            _loadDataFromUserModel(userProfile);
          }
        } else {
          // Set defaults for new users
          basicInfoController.setGoal('5K');
        }

        // Set timezone
        _initializeTimezone();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error initializing user profile setup: $e');
    }
  }

  void _loadDataFromUserModel(UserModel user) {
    basicInfoController.loadFromUserModel(user);
    personalInfoController.loadFromUserModel(user);
    physicalAttributesController.loadFromUserModel(user);
    healthInfoController.loadFromUserModel(user);
  }

  void _initializeTimezone() {
    try {
      final timeZone = DateTime.now().timeZoneName;
      if (timeZone.isNotEmpty) {
        personalInfoController.updateTimezone(timeZone);
      }
    } catch (e) {
      personalInfoController.updateTimezone('UTC');
    }
  }

  Future<bool> saveUserProfile() async {
    if (_firebaseUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      UserModel? existingUser;
      if (isEditMode) {
        existingUser = await _userDataService.loadUserProfile(
          _firebaseUser!.uid,
        );
      }

      final userModel = await _userDataService.createUserModel(
        userId: _firebaseUser!.uid,
        name: basicInfoController.name,
        email: basicInfoController.email,
        profilePic: basicInfoController.profilePic,
        language: personalInfoController.language,
        dob: personalInfoController.dob,
        goal: basicInfoController.selectedGoal,
        goalEventDate: basicInfoController.goalEventDate,
        metricSystem: physicalAttributesController.metricSystem,
        runDaysPerWeek: physicalAttributesController.runDaysPerWeek,
        weight: physicalAttributesController.weight,
        height: physicalAttributesController.height,
        gender: personalInfoController.gender,
        injuryNotes: healthInfoController.injuryNotes,
        experience: healthInfoController.experience,
        timezone: personalInfoController.timezone,
        isEditMode: isEditMode,
        existingUser: existingUser,
      );

      await _userDataService.saveUserProfile(userModel, isEditMode: isEditMode);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error saving user profile: $e');
      return false;
    }
  }

  bool validateCurrentStep() {
    switch (navigationController.currentStep) {
      case 0:
        return basicInfoController.validate();
      case 1:
        return personalInfoController.validate();
      case 2:
        return physicalAttributesController.validate();
      case 3:
        return healthInfoController.validate();
      default:
        return false;
    }
  }

  // Convenience getters for accessing sub-controllers
  int get currentStep => navigationController.currentStep;
  int get totalSteps => navigationController.totalSteps;

  void nextStep() => navigationController.nextStep();
  void previousStep() => navigationController.previousStep();
  void goToStep(int step) => navigationController.goToStep(step);
  void skipToLastStep() => navigationController.skipToLastStep();
}
