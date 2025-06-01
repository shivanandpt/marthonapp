import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/core/widgets/app_button.dart';
import 'package:marunthon_app/features/menu_drawer/presentation/menu_drawer.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/models/run_model.dart';
import 'package:marunthon_app/models/user_model.dart';
import 'package:marunthon_app/models/training_plan_model.dart';
import 'package:marunthon_app/models/training_day_model.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/core/services/run_service.dart';
import 'package:marunthon_app/core/services/user_service.dart';
import 'package:marunthon_app/core/services/training_plan_service.dart';
import 'package:marunthon_app/core/services/training_day_service.dart';
import 'package:marunthon_app/features/log_run/run_tracking_pag.dart';

// Import components
import 'package:marunthon_app/features/home/components/welcome_card.dart';
import 'package:marunthon_app/features/home/components/training_plan_card.dart';
import 'package:marunthon_app/features/home/components/today_training_card.dart';
import 'package:marunthon_app/features/home/components/no_plan_card.dart';
import 'package:marunthon_app/features/home/components/recent_runs_section.dart';
import 'package:marunthon_app/features/home/components/upcoming_training_section.dart';
import 'package:marunthon_app/features/home/utils/date_utils.dart'
    as AppDateUtils;
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RunService _runService = RunService();
  final UserService _userService = UserService();
  final TrainingPlanService _trainingPlanService = TrainingPlanService();
  final TrainingDayService _trainingDayService = TrainingDayService();

  UserModel? _userModel;
  TrainingPlanModel? _activePlan;
  List<TrainingDayModel> _upcomingTrainingDays = [];
  List<RunModel> _recentRuns = [];
  bool _isLoading = true;

  // Training progress stats
  int _daysCompleted = 0;
  int _totalDays = 0;
  int _currentWeek = 0;
  int _totalWeeks = 0;
  TrainingDayModel? _todaysTraining;

  @override
  void initState() {
    super.initState();
    AnalyticsService.setCurrentScreen('HomePage');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current Firebase user
      User? user = _auth.currentUser;
      if (user == null) {
        context.go('/login');
        return;
      }

      // Load user model
      final userModel = await _userService.getUserProfile(user.uid);
      if (userModel == null) {
        context.go('/profile-setup');
        return;
      }

      // Load active training plan
      final activePlan = await _trainingPlanService.getActiveTrainingPlan(
        user.uid,
      );

      // Load recent runs - limit to 5
      final recentRuns = await _runService.getUserRuns(user.uid);
      recentRuns.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final limitedRuns = recentRuns.take(5).toList();

      // If there's an active plan, get upcoming training days and stats
      List<TrainingDayModel> upcomingDays = [];
      TrainingDayModel? todayTraining;
      int daysCompleted = 0;
      int totalDays = 0;
      int currentWeek = 1;
      int totalWeeks = 0;

      if (activePlan != null) {
        // Get all training days for plan
        final allTrainingDays = await _trainingDayService
            .getTrainingDaysForPlan(activePlan.id);
        totalDays = allTrainingDays.length;
        totalWeeks = activePlan.weeks;

        // Find today's date
        final today = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final tomorrow = today.add(Duration(days: 1));
        final endOfWeek = today.add(Duration(days: 7));

        // Filter for today's training
        todayTraining = allTrainingDays.firstWhere(
          (day) =>
              day.dateScheduled != null &&
              AppDateUtils.DateUtils.isSameDay(day.dateScheduled!, today),
          orElse:
              () => TrainingDayModel(
                id: '',
                planId: activePlan.id,
                week: 1,
                dayOfWeek: today.weekday,
                optional: false,
                runPhases: [],
              ),
        );

        // Get upcoming days (next 7 days including today)
        upcomingDays =
            allTrainingDays
                .where(
                  (day) =>
                      day.dateScheduled != null &&
                      day.dateScheduled!.isAfter(
                        today.subtract(Duration(days: 1)),
                      ) &&
                      day.dateScheduled!.isBefore(endOfWeek),
                )
                .toList();

        upcomingDays.sort(
          (a, b) => a.dateScheduled!.compareTo(b.dateScheduled!),
        );

        // Calculate days completed
        for (var run in recentRuns) {
          if (run.trainingDayId != null) {
            daysCompleted++;
          }
        }

        // Find current week
        if (todayTraining.id.isNotEmpty) {
          currentWeek = todayTraining.week;
        } else {
          // Calculate week based on start date
          final firstDay = allTrainingDays.firstWhere(
            (day) => day.dateScheduled != null,
            orElse:
                () => TrainingDayModel(
                  id: '',
                  planId: activePlan.id,
                  week: 1,
                  dayOfWeek: 1,
                  optional: false,
                  runPhases: [],
                ),
          );

          if (firstDay.dateScheduled != null) {
            final diff = today.difference(firstDay.dateScheduled!).inDays;
            currentWeek = (diff ~/ 7) + 1;
            if (currentWeek > totalWeeks) currentWeek = totalWeeks;
            if (currentWeek < 1) currentWeek = 1;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _userModel = userModel;
        _activePlan = activePlan;
        _recentRuns = limitedRuns;
        _upcomingTrainingDays = upcomingDays;
        _daysCompleted = daysCompleted;
        _totalDays = totalDays;
        _currentWeek = currentWeek;
        _totalWeeks = totalWeeks;
        _todaysTraining = todayTraining;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading home data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      drawer: MenuDrawer(),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _userModel == null
              // Handle case when user model is null
              ? _buildNoUserView()
              : RefreshIndicator(
                onRefresh: _loadUserData,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Card - Now safe to use _userModel!
                        WelcomeCard(userModel: _userModel!),
                        SizedBox(height: 24),

                        // Training Plan Progress Card
                        if (_activePlan != null)
                          TrainingPlanCard(
                            activePlan: _activePlan!,
                            daysCompleted: _daysCompleted,
                            totalDays: _totalDays,
                            currentWeek: _currentWeek,
                            totalWeeks: _totalWeeks,
                          ),

                        // Today's Training
                        if (_todaysTraining != null && _activePlan != null)
                          TodayTrainingCard(todaysTraining: _todaysTraining!),

                        // No Plan Card
                        if (_activePlan == null) NoPlanCard(),

                        SizedBox(height: 24),

                        // Recent Runs Section
                        RecentRunsSection(recentRuns: _recentRuns),

                        // Upcoming Training Days Section
                        if (_upcomingTrainingDays.isNotEmpty)
                          UpcomingTrainingSection(
                            upcomingDays: _upcomingTrainingDays,
                            todaysTraining: _todaysTraining,
                          ),

                        SizedBox(height: 80), // For bottom padding
                      ],
                    ),
                  ),
                ),
              ),
      // --- Run Action Button ---
      floatingActionButton:
          _userModel != null &&
                  (_todaysTraining != null && _todaysTraining!.id.isNotEmpty)
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => RunTrackingPage(
                            //trainingDayId:_todaysTraining!.id, // UNCOMMENT THIS LINE
                          ),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                icon: Icon(LucideIcons.play),
                label: Text("Start Today's Run"),
              )
              : _userModel != null
              ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RunTrackingPage()),
                  );
                },
                backgroundColor: AppColors.primary,
                icon: Icon(LucideIcons.play),
                label: Text("Quick Run"),
              )
              : null, // Don't show the FAB if userModel is null
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Add this method to handle the case when user model is null
  Widget _buildNoUserView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 80, color: AppColors.secondary),
          SizedBox(height: 16),
          Text(
            "Profile information not available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Please set up your profile to continue",
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          AppButton(
            onPressed: () {
              context.go('/profile-setup');
            },
            text: "Set Up Profile",
          ),
        ],
      ),
    );
  }
}
