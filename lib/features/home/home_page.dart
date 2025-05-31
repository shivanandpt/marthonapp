import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/features/menu_drawer/presentation/menu_drawer.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/models/run_model.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/core/services/run_service.dart';
import 'package:marunthon_app/core/services/user_profile_service.dart';
import 'package:marunthon_app/features/log_run/run_tracking_pag.dart';
import 'package:marunthon_app/features/log_run/run_list.dart';
import 'package:marunthon_app/features/user_profile/user_profile_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RunService _runService = RunService();

  String userName = "User";
  double totalDistance = 0.0;
  int totalRuns = 0;
  List<RunModel> _runs = [];
  bool _isLoading = true;
  int runsThisWeek = 0;

  double lastWeekDistance = 0.0;
  int lastWeekRuns = 0;

  @override
  void initState() {
    super.initState();
    AnalyticsService.setCurrentScreen('HomePage');
    _loadUserData();
    _fetchRuns();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      var userData = await UserProfileService().fetchUserProfile(user.uid);
      if (!mounted) return;
      setState(() {
        userName = userData?.name ?? "Runner";
      });
    }
  }

  Future<void> _fetchRuns() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final runs = await _runService.fetchAllRuns(userId: userId);

    // Calculate last week's summary
    double weekDistance = 0.0;
    int weekCount = 0;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    for (var run in runs) {
      if (run.timestamp.isAfter(startOfWeek)) {
        weekDistance += run.distance;
        weekCount++;
      }
    }

    if (!mounted) return;
    setState(() {
      _runs = runs;
      lastWeekDistance = weekDistance;
      lastWeekRuns = weekCount;
      _isLoading = false;
    });
  }

  // Group runs by day (date string)
  Map<String, List<RunModel>> _groupRunsByDay() {
    Map<String, List<RunModel>> grouped = {};
    for (var run in _runs) {
      final day = DateFormat('yyyy-MM-dd').format(run.timestamp);
      grouped.putIfAbsent(day, () => []).add(run);
    }
    return grouped;
  }

  Future<void> _deleteRun(String runId) async {
    await _runService.deleteRun(runId);
    setState(() {
      _runs.removeWhere((run) => run.id == runId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupRunsByDay();
    final dayKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      drawer: MenuDrawer(),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  // --- Combined Welcome & Weekly Summary Card ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                      child: Card(
                        color: AppColors.cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 24.0,
                            horizontal: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.trophy,
                                    color: AppColors.accent,
                                    size: 40,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      "Welcome, $userName!",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "Distance",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "${(lastWeekDistance / 1000).toStringAsFixed(2)} km", // Show in km
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "Runs",
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "$lastWeekRuns",
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Center(
                              //   child: Text(
                              //     "Runs this week: $lastWeekRuns / 5",
                              //     style: TextStyle(
                              //       color: AppColors.secondary,
                              //       fontWeight: FontWeight.w700,
                              //       fontSize: 18,
                              //     ),
                              //   ),
                              // ),
                              if (lastWeekRuns >= 5)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          "Congrats! 🎉 ",
                                          style: TextStyle(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          "You smashed your goal!",
                                          style: TextStyle(
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // --- Run List grouped by day with separator and swipe-to-delete ---
                  RunList(
                    runs: _runs,
                    onDelete: (runId) async => await _deleteRun(runId),
                  ),
                ],
              ),
      // --- Full-width Log Run Button Section ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              elevation: 4,
              textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            icon: Icon(LucideIcons.plus),
            label: Text("Log Today's Run"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RunTrackingPage()),
              );
            },
          ),
        ),
      ),
    );
  }
}
