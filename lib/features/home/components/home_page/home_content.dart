import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/home_bloc.dart';
import '../../bloc/home_event.dart';
import '../../bloc/home_state.dart';
import '../welcome_card.dart';
import '../training_plan_card.dart';
import '../today_training_card.dart';
import '../no_plan_card.dart';
import '../../../runs/recent_runs_section/screens/recent_runs_section.dart';
import '../upcoming_training_section.dart';
import 'no_runs_card.dart';
import 'quick_start_menu.dart';
import 'start_run_fab.dart';

class HomeContent extends StatelessWidget {
  final HomeLoaded state;

  const HomeContent({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

              // Quick Start Menu Card - Show after no plan or with active plan
              const QuickStartMenu(),

              const SizedBox(height: 24),

              // Recent Runs Section - Only show if we have runs
              if (state.recentRuns.isNotEmpty)
                RecentRunsSection(
                  recentRuns: state.recentRuns,
                  allRuns: state.allRuns,
                  onDelete: (String runId) {
                    // Handle run deletion via bloc
                    //context.read<HomeBloc>().add(DeleteRunEvent(runId));
                  },
                )
              else
                const NoRunsCard(),

              // Upcoming Training Days Section
              if (state.upcomingTrainingDays.isNotEmpty)
                UpcomingTrainingSection(
                  upcomingDays: state.upcomingTrainingDays,
                  todaysTraining: state.todaysTraining,
                ),

              // Start Free Run Button at bottom
              const StartRunFAB(),
            ],
          ),
        ),
      ),
    );
  }
}
