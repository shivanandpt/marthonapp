// lib/features/home/bloc/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/features/user/user_profile/setup/services/user_service.dart';
import 'package:marunthon_app/features/home/services/training_plan_service.dart';
import 'package:marunthon_app/features/home/services/training_day_service.dart';
import 'package:marunthon_app/features/runs/services/run_service.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'package:marunthon_app/features/home/models/training_plan_model.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FirebaseAuth _auth;
  final UserService _userService;
  final TrainingPlanService _trainingPlanService;
  final TrainingDayService _trainingDayService;
  final RunService _runService;

  HomeBloc({
    required FirebaseAuth auth,
    required UserService userService,
    required TrainingPlanService trainingPlanService,
    required TrainingDayService trainingDayService,
    required RunService runService,
  }) : _auth = auth,
       _userService = userService,
       _trainingPlanService = trainingPlanService,
       _trainingDayService = trainingDayService,
       _runService = runService,
       super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      // Get current Firebase user
      final User? user = _auth.currentUser;
      if (user == null) {
        emit(const HomeError('User not authenticated'));
        return;
      }

      // Load user model
      final userModel = await _userService.getUserProfile(user.uid);
      if (userModel == null) {
        emit(const HomeProfileNotFound());
        return;
      }

      // Load active training plan
      final activePlan = await _trainingPlanService.getActiveTrainingPlan(
        user.uid,
      );

      // Load ALL runs for calculation (not limited)
      List<RunModel> allRuns = [];
      try {
        allRuns = await _runService.getUserRuns(user.uid);
      } catch (e) {
        print('Failed to load runs: $e');
        allRuns = [];
      }

      // Calculate training data using ALL runs
      final trainingData = await _calculateTrainingData(
        activePlan,
        allRuns,
        user.uid,
      );

      // Get only recent runs for display (separate from calculation)
      final recentRuns = allRuns.take(5).toList();
      recentRuns.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      emit(
        HomeLoaded(
          userModel: userModel,
          activePlan: activePlan,
          allRuns: allRuns,
          allTrainingDays: trainingData.allTrainingDays,
          recentRuns: recentRuns, // Only for display
          upcomingTrainingDays: trainingData.upcomingDays,
          todaysTraining: trainingData.todaysTraining,
          daysCompleted: trainingData.daysCompleted,
          totalDays: trainingData.totalDays,
          currentWeek: trainingData.currentWeek,
          totalWeeks: trainingData.totalWeeks,
        ),
      );
    } catch (e) {
      print('Error in _loadData: $e');
      emit(HomeError('Failed to load data: ${e.toString()}'));
    }
  }

  Future<_TrainingData> _calculateTrainingData(
    TrainingPlanModel? activePlan,
    List<RunModel> allRuns,
    String userId,
  ) async {
    try {
      if (activePlan == null) {
        print('No active training plan found');
        return _TrainingData(
          allTrainingDays: [],
          upcomingDays: [],
          todaysTraining: null,
          daysCompleted: 0,
          totalDays: 0,
          currentWeek: 1,
          totalWeeks: 0,
        );
      }

      print('Calculating training data for plan: ${activePlan.goalType}');

      // Get all training days for plan
      final allTrainingDays = await _trainingDayService.getTrainingDaysForPlan(
        activePlan
            .id!, // Force unwrap since we know activePlan is not null here
      );
      final totalDays = allTrainingDays.length;
      final totalWeeks = activePlan.weeks;

      print('Total training days in plan: $totalDays');
      print('Total runs available for calculation: ${allRuns.length}');

      // Create a set of all training day IDs from the plan
      final allTrainingDayIds =
          allTrainingDays
              .map((day) => day.id)
              .where((id) => id!.isNotEmpty)
              .toSet();

      print('All training day IDs in plan: $allTrainingDayIds');

      // Find runs that have valid training day IDs
      final runsWithTrainingDayIds =
          allRuns
              .where(
                (run) =>
                    run.trainingDayId != null && run.trainingDayId!.isNotEmpty,
              )
              .toList();

      print('Runs with training day IDs: ${runsWithTrainingDayIds.length}');

      // Create a set of completed training day IDs from runs
      final completedTrainingDayIds =
          runsWithTrainingDayIds
              .map((run) => run.trainingDayId!)
              .where((id) => allTrainingDayIds.contains(id))
              .toSet();

      print('Valid completed training day IDs: $completedTrainingDayIds');

      // Calculate progress
      final daysCompleted = completedTrainingDayIds.length;
      final daysRemaining = totalDays - daysCompleted;

      print('=== TRAINING PROGRESS CALCULATION ===');
      print('Total training days in plan: $totalDays');
      print('Days completed: $daysCompleted');
      print('Days remaining: $daysRemaining');
      print(
        'Progress: ${totalDays > 0 ? (daysCompleted / totalDays * 100).toInt() : 0}%',
      );

      // Debug: Print detailed run analysis
      print('\n=== RUN ANALYSIS ===');
      for (var run in allRuns) {
        final isTrainingRun =
            run.trainingDayId != null && run.trainingDayId!.isNotEmpty;
        final isValidTrainingRun =
            isTrainingRun && allTrainingDayIds.contains(run.trainingDayId);

        print('Run ${run.id}:');
        print(
          '  Date: ${run.timestamp.day}/${run.timestamp.month}/${run.timestamp.year}',
        );
        print('  Training Day ID: ${run.trainingDayId ?? 'None'}');
        print('  Is Training Run: $isTrainingRun');
        print('  Is Valid Training Run: $isValidTrainingRun');
        print('  ---');
      }

      // Find today's date
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Declare these variables OUTSIDE the loop
      TrainingDayModel? todaysTraining;
      final List<TrainingDayModel> upcomingDays = [];

      // Find today's training and upcoming days
      for (var day in allTrainingDays) {
        final dayDate = DateTime(
          day.scheduling.dateScheduled.year,
          day.scheduling.dateScheduled.month,
          day.scheduling.dateScheduled.day,
        );

        // Check if it's today's training
        if (dayDate.isAtSameMomentAs(todayDate)) {
          todaysTraining = day;
          print(
            'Found today\'s training: ${day.identification.sessionType} on ${dayDate}',
          );
        }

        // Add to upcoming days (next 7 days including today)
        // Only include days that haven't been completed yet
        final difference = dayDate.difference(todayDate).inDays;
        if (difference >= 0 &&
            difference <= 7 &&
            upcomingDays.length < 7 &&
            !completedTrainingDayIds.contains(day.id)) {
          upcomingDays.add(day);
          print(
            'Added upcoming day: ${day.identification.sessionType} on ${dayDate} (${difference} days from today)',
          );
        }
      }

      // Sort upcoming days by date
      upcomingDays.sort((a, b) {
        return a.scheduling.dateScheduled.compareTo(b.scheduling.dateScheduled);
      });

      // Calculate current week
      int currentWeek = 1;
      if (todaysTraining != null) {
        currentWeek = todaysTraining.week;
      } else if (daysCompleted > 0) {
        // Find the latest completed training day to determine current week
        TrainingDayModel? latestCompletedDay;
        DateTime? latestCompletedDate;

        for (var day in allTrainingDays) {
          if (completedTrainingDayIds.contains(day.id)) {
            if (latestCompletedDate == null ||
                day.scheduling.dateScheduled.isAfter(latestCompletedDate)) {
              latestCompletedDate = day.scheduling.dateScheduled;
              latestCompletedDay = day;
            }
          }
        }

        if (latestCompletedDay != null) {
          currentWeek = latestCompletedDay.identification.week;
          // If all days in current week are completed, move to next week
          final currentWeekDays =
              allTrainingDays
                  .where((day) => day.identification.week == currentWeek)
                  .toList();
          final completedCurrentWeekDays =
              currentWeekDays
                  .where((day) => completedTrainingDayIds.contains(day.id))
                  .length;

          if (completedCurrentWeekDays == currentWeekDays.length &&
              currentWeek < totalWeeks) {
            currentWeek++;
          }
        }
      }

      // Ensure current week is within bounds
      if (currentWeek > totalWeeks) currentWeek = totalWeeks;
      if (currentWeek < 1) currentWeek = 1;

      print('Current week: $currentWeek/$totalWeeks');
      print('Upcoming training days: ${upcomingDays.length}');

      return _TrainingData(
        allTrainingDays: allTrainingDays,
        upcomingDays: upcomingDays,
        todaysTraining: todaysTraining,
        daysCompleted: daysCompleted,
        totalDays: totalDays,
        currentWeek: currentWeek,
        totalWeeks: totalWeeks,
      );
    } catch (e) {
      print('Error calculating training data: $e');
      // Return safe defaults
      return _TrainingData(
        allTrainingDays: [],
        upcomingDays: [],
        todaysTraining: null,
        daysCompleted: 0,
        totalDays: 0,
        currentWeek: 1,
        totalWeeks: 0,
      );
    }
  }
}

class _TrainingData {
  final List<TrainingDayModel> allTrainingDays;
  final List<TrainingDayModel> upcomingDays;
  final TrainingDayModel? todaysTraining;
  final int daysCompleted;
  final int totalDays;
  final int currentWeek;
  final int totalWeeks;

  _TrainingData({
    required this.allTrainingDays,
    required this.upcomingDays,
    this.todaysTraining,
    required this.daysCompleted,
    required this.totalDays,
    required this.currentWeek,
    required this.totalWeeks,
  });
}
