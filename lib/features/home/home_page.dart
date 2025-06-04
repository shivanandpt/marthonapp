import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/core/widgets/app_button.dart';
import 'package:marunthon_app/features/menu_drawer/presentation/menu_drawer.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/services/run_service.dart';
import 'package:marunthon_app/features/user/user_profile/setup/services/user_service.dart';
import 'package:marunthon_app/features/home/services/training_plan_service.dart';
import 'package:marunthon_app/features/home/services/training_day_service.dart';
import 'package:marunthon_app/features/runs/run_tracking_pag.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Import components
import 'package:marunthon_app/features/home/components/welcome_card.dart';
import 'package:marunthon_app/features/home/components/training_plan_card.dart';
import 'package:marunthon_app/features/home/components/today_training_card.dart';
import 'package:marunthon_app/features/home/components/no_plan_card.dart';
import 'package:marunthon_app/features/home/components/recent_runs_section.dart';
import 'package:marunthon_app/features/home/components/upcoming_training_section.dart';

// Import BLoC
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => HomeBloc(
            auth: FirebaseAuth.instance,
            userService: UserService(),
            trainingPlanService: TrainingPlanService(),
            trainingDayService: TrainingDayService(),
            runService: RunService(),
          )..add(const LoadHomeData()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.setCurrentScreen('HomePage');
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
      drawer: const MenuDrawer(),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeProfileNotFound) {
            context.go('/profile-setup');
          } else if (state is HomeError &&
              state.message.contains('not authenticated')) {
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return _buildLoadingView();
          }

          if (state is HomeProfileNotFound) {
            return _buildNoUserView(context);
          }

          if (state is HomeError) {
            return _buildErrorView(context, state.message);
          }

          if (state is HomeLoaded) {
            return _buildHomeContent(context, state);
          }

          return _buildLoadingView();
        },
      ),
      floatingActionButton: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoaded) {
            if (state.todaysTraining != null &&
                state.todaysTraining!.id.isNotEmpty) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => const RunTrackingPage(
                            //trainingDayId: state.todaysTraining!.id, // UNCOMMENT THIS LINE
                          ),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(LucideIcons.play),
                label: const Text("Start Today's Run"),
              );
            }
          }
          return const SizedBox.shrink(); // No button when loading or error
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your dashboard...'),
        ],
      ),
    );
  }

  // Update the _buildHomeContent method to handle empty data gracefully
  Widget _buildHomeContent(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(const RefreshHomeData());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              WelcomeCard(userModel: state.userModel),
              const SizedBox(height: 24),

              // Training Plan Progress Card
              if (state.activePlan != null)
                TrainingPlanCard(
                  activePlan: state.activePlan!,
                  daysCompleted: state.daysCompleted,
                  totalDays: state.totalDays,
                  currentWeek: state.currentWeek,
                  totalWeeks: state.totalWeeks,
                ),

              // Today's Training
              if (state.todaysTraining != null &&
                  state.todaysTraining!.id.isNotEmpty &&
                  state.activePlan != null)
                TodayTrainingCard(todaysTraining: state.todaysTraining!),

              // No Plan Card
              if (state.activePlan == null) const NoPlanCard(),

              const SizedBox(height: 24),

              // Recent Runs Section - Only show if we have runs
              if (state.recentRuns.isNotEmpty)
                RecentRunsSection(recentRuns: state.recentRuns)
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_run,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No runs yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start your first run to see your progress here',
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

              // Upcoming Training Days Section
              if (state.upcomingTrainingDays.isNotEmpty)
                UpcomingTrainingSection(
                  upcomingDays: state.upcomingTrainingDays,
                  todaysTraining: state.todaysTraining,
                ),

              const SizedBox(height: 80), // For bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoUserView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 80, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text(
            "Profile Setup Required",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Please set up your profile to continue",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
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

  Widget _buildErrorView(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            "Unable to Load Dashboard",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const LoadHomeData());
                },
                text: "Retry",
                width: 120,
              ),
              const SizedBox(width: 16),
              AppButton(
                onPressed: () {
                  context.go('/profile-setup');
                },
                text: "Setup Profile",
                backgroundColor: Colors.grey[600],
                width: 140,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
