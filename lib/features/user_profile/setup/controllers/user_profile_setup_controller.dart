import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/models/user_model.dart';
import 'package:marunthon_app/core/services/user_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserProfileSetupController with ChangeNotifier {
  // Form data
  String name = '';
  String email = '';
  String profilePic = '';
  String language = 'English';
  DateTime? dob;
  String goal = '';
  DateTime? goalEventDate; // Add this property
  String metricSystem = 'metric';
  int runDaysPerWeek = 3;
  int? weight;
  int? height;
  String? gender;
  String? injuryNotes;
  String timezone = 'UTC';

  // Current step
  int _currentStep = 0;
  int get currentStep => _currentStep;

  // Total steps
  final int totalSteps = 4;

  // Firebase user
  User? _firebaseUser;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool isEditMode = false;

  // Initialize with Firebase user data
  Future<void> initialize({bool isEditMode = false}) async {
    _isLoading = true;
    this.isEditMode = isEditMode;
    notifyListeners();

    try {
      _firebaseUser = FirebaseAuth.instance.currentUser;

      if (_firebaseUser != null) {
        name = _firebaseUser!.displayName ?? '';
        email = _firebaseUser!.email ?? '';
        profilePic = _firebaseUser!.photoURL ?? '';

        if (isEditMode) {
          UserService userService = UserService();
          var userProfile = await userService.getUserProfile(
            _firebaseUser!.uid,
          );

          if (userProfile != null) {
            name = userProfile.name;
            language = userProfile.language == 'en' ? 'English' : 'Spanish';
            dob = userProfile.dob;
            goal = userProfile.goal;
            goalEventDate = userProfile.goalEventDate; // Add this line
            _selectedGoal = userProfile.goal; // Also set selectedGoal
            metricSystem = userProfile.metricSystem;
            runDaysPerWeek = userProfile.runDaysPerWeek;
            weight = userProfile.weight;
            height = userProfile.height;
            gender = userProfile.gender;
            injuryNotes = userProfile.injuryNotes;
          }
        } else {
          // For new users, set default goal and its event date
          _selectedGoal = '5K';
          goal = '5K';
          _setDefaultGoalEventDate('5K');
        }

        // Try to get timezone
        try {
          final timeZone = DateTime.now().timeZoneName;
          if (timeZone.isNotEmpty) {
            timezone = timeZone;
          }
        } catch (e) {
          timezone = 'UTC';
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error initializing user profile setup: $e');
    }
  }

  // Next step
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  // Previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      _currentStep = step;
      notifyListeners();
    }
  }

  // Add this method to skip to the last step
  void skipToLastStep() {
    _currentStep = totalSteps - 1; // Go to the last step (Health Information)
    notifyListeners();
  }

  // Save user profile - update to handle both creation and updates
  Future<bool> saveUserProfile() async {
    if (_firebaseUser == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Get app version
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      // Calculate age from DOB
      int age = 0;
      if (dob != null) {
        final now = DateTime.now();
        age = now.year - dob!.year;
        // Adjust age if birthday hasn't occurred yet this year
        if (now.month < dob!.month ||
            (now.month == dob!.month && now.day < dob!.day)) {
          age--;
        }
      }

      final userService = UserService();

      if (isEditMode) {
        // Update existing profile
        await userService.updateUserProfile(
          UserModel(
            id: _firebaseUser!.uid,
            name: name,
            email: email,
            profilePic: profilePic,
            language: language.toLowerCase() == 'english' ? 'en' : 'es',
            dob: dob,
            goal: goal,
            goalEventDate: goalEventDate, // Add this line
            metricSystem: metricSystem,
            runDaysPerWeek: runDaysPerWeek,
            weight: weight ?? 0,
            height: height ?? 0,
            gender: gender ?? '',
            injuryNotes: injuryNotes ?? '',
            lastActiveAt: DateTime.now(),
            appVersion: appVersion,
            age: age,
            timezone: timezone,
            // Don't update these fields when editing:
            joinedAt: DateTime.now(), // This will be ignored in the update
          ),
        );
      } else {
        // Create new profile
        await userService.createUserProfile(
          UserModel(
            id: _firebaseUser!.uid,
            name: name,
            email: email,
            profilePic: profilePic,
            language: language.toLowerCase() == 'english' ? 'en' : 'es',
            dob: dob,
            goal: goal,
            goalEventDate: goalEventDate, // Add this line
            metricSystem: metricSystem,
            runDaysPerWeek: runDaysPerWeek,
            weight: weight ?? 0,
            height: height ?? 0,
            gender: gender ?? '',
            injuryNotes: injuryNotes ?? '',
            joinedAt: DateTime.now(),
            lastActiveAt: DateTime.now(),
            appVersion: appVersion,
            age: age,
            timezone: timezone,
          ),
        );
      }

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

  // Validate current step
  bool validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic info step
        // Ensure all required fields are filled
        bool isValid =
            name.trim().isNotEmpty &&
            email.trim().isNotEmpty &&
            _selectedGoal.isNotEmpty;
        return isValid;

      case 1: // Date of birth & Language
        return dob != null && gender != null;
      case 2: // Training preferences
        return runDaysPerWeek > 0;
      case 3: // Optional health info
        return true; // Optional step
      default:
        return false;
    }
  }

  // Update methods
  void updateDob(DateTime? date) {
    if (date != null) {
      dob = date;
      notifyListeners();
    }
  }

  void updateLanguage(String value) {
    language = value;
    notifyListeners();
  }

  void updateRunDaysPerWeek(int value) {
    runDaysPerWeek = value;
    notifyListeners();
  }

  void updateHeight(int? value) {
    height = value;
    notifyListeners();
  }

  void updateInjuryNotes(String value) {
    injuryNotes = value;
    // Don't call notifyListeners() here since we're using a TextEditingController listener
    // This prevents the cursor from jumping around
    // notifyListeners(); // Remove this line
  }

  // Add a separate method if you need to trigger UI updates elsewhere
  void updateInjuryNotesWithNotify(String value) {
    injuryNotes = value;
    notifyListeners();
  }

  void updateUI() {
    notifyListeners();
  }

  void updateGender(String value) {
    gender = value;
    notifyListeners();
  }

  void updateMetricSystem(String value) {
    metricSystem = value;
    notifyListeners();
  }

  void updateWeight(int? value) {
    weight = value;
    notifyListeners();
  }

  // Running goals in correct order
  static const List<String> runningGoals = [
    '5K',
    '10K',
    'Half Marathon',
    'Full Marathon',
  ];

  // Initialize with default goal
  String _selectedGoal = '5K';

  String get selectedGoal => _selectedGoal;

  void setGoal(String goalValue) {
    _selectedGoal = goalValue;
    goal = goalValue; // Update the main goal property too

    // Set default goal event date based on the selected goal
    _setDefaultGoalEventDate(goalValue);
    notifyListeners(); // This should trigger UI update including button state
  }

  // Helper method to set default goal event date
  void _setDefaultGoalEventDate(String selectedGoal) {
    final now = DateTime.now();

    switch (selectedGoal) {
      case '5K':
        // 8-12 weeks training plan for 5K
        goalEventDate = now.add(Duration(days: 70)); // ~10 weeks
        break;
      case '10K':
        // 10-16 weeks training plan for 10K
        goalEventDate = now.add(Duration(days: 91)); // ~13 weeks
        break;
      case 'Half Marathon':
        // 12-20 weeks training plan for Half Marathon
        goalEventDate = now.add(Duration(days: 112)); // ~16 weeks
        break;
      case 'Full Marathon':
        // 16-24 weeks training plan for Full Marathon
        goalEventDate = now.add(Duration(days: 140)); // ~20 weeks
        break;
      default:
        // Default to 12 weeks
        goalEventDate = now.add(Duration(days: 70));
    }
  }

  // Add method to update goal event date manually if needed
  void updateGoalEventDate(DateTime? date) {
    goalEventDate = date;
    notifyListeners();
  }

  // Method to get goals in correct order
  List<String> getRunningGoals() {
    return runningGoals;
  }
}
