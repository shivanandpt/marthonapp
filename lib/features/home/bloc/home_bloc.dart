// lib/features/home/bloc/home_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/services/user_service.dart';
import 'package:marunthon_app/core/services/training_plan_service.dart';
import 'package:marunthon_app/core/services/training_day_service.dart';
import 'package:marunthon_app/core/services/run_service.dart';
import 'package:marunthon_app/features/home/utils/date_utils.dart'
    as AppDateUtils;
import 'package:marunthon_app/models/run_model.dart';
import 'package:marunthon_app/models/training_day_model.dart';
import 'package:marunthon_app/models/training_plan_model.dart';

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

      print('Loading data for user: ${user.uid}');

      // Load user model
      final userModel = await _userService.getUserProfile(user.uid);
      if (userModel == null) {
        emit(const HomeProfileNotFound());
        return;
      }

      print('User profile loaded: ${userModel.name}');

      // Load active training plan
      final activePlan = await _trainingPlanService.getActiveTrainingPlan(
        user.uid,
      );
      print('Active plan loaded: ${activePlan?.goalType ?? 'No active plan'}');

      // Load recent runs with better error handling
      List<RunModel> recentRuns = [];
      try {
        final allRuns = await _runService.getUserRuns(user.uid);
        allRuns.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        recentRuns = allRuns.take(5).toList();
        print('Loaded ${recentRuns.length} recent runs');
      } catch (e) {
        print('Failed to load runs, continuing with empty list: $e');
        // Continue with empty runs list instead of failing
        recentRuns = [];
      }

      // Calculate training data
      final trainingData = await _calculateTrainingData(
        activePlan,
        recentRuns,
        user.uid,
      );

      emit(
        HomeLoaded(
          userModel: userModel,
          activePlan: activePlan,
          recentRuns: recentRuns,
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
    List<RunModel> recentRuns,
    String userId,
  ) async {
    try {
      if (activePlan == null) {
        return _TrainingData(
          upcomingDays: [],
          todaysTraining: null,
          daysCompleted: 0,
          totalDays: 0,
          currentWeek: 1,
          totalWeeks: 0,
        );
      }

      // Get all training days for plan
      final allTrainingDays = await _trainingDayService.getTrainingDaysForPlan(
        activePlan.id,
      );
      final totalDays = allTrainingDays.length;
      final totalWeeks = activePlan.weeks;

      // Find today's date
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Filter training days safely
      TrainingDayModel? todayTraining;
      final List<TrainingDayModel> upcomingDays = [];

      for (var day in allTrainingDays) {
        if (day.dateScheduled != null) {
          final dayDate = DateTime(
            day.dateScheduled!.year,
            day.dateScheduled!.month,
            day.dateScheduled!.day,
          );

          // Check if it's today's training
          if (dayDate.isAtSameMomentAs(todayDate)) {
            todayTraining = day;
          }

          // Add to upcoming days (next 7 days including today)
          final difference = dayDate.difference(todayDate).inDays;
          if (difference >= 0 && difference <= 7 && upcomingDays.length < 7) {
            upcomingDays.add(day);
          }
        }
      }

      // Sort upcoming days by date
      upcomingDays.sort((a, b) {
        if (a.dateScheduled == null || b.dateScheduled == null) return 0;
        return a.dateScheduled!.compareTo(b.dateScheduled!);
      });

      // Calculate days completed based on runs with training day IDs
      int daysCompleted =
          recentRuns
              .where(
                (run) =>
                    run.trainingDayId != null && run.trainingDayId!.isNotEmpty,
              )
              .length;

      // Calculate current week
      int currentWeek = 1;
      if (todayTraining != null) {
        currentWeek = todayTraining.week;
      } else if (allTrainingDays.isNotEmpty) {
        // Find the week based on the closest training day
        final sortedDays =
            allTrainingDays.where((day) => day.dateScheduled != null).toList()
              ..sort((a, b) => a.dateScheduled!.compareTo(b.dateScheduled!));

        for (var day in sortedDays) {
          final dayDate = DateTime(
            day.dateScheduled!.year,
            day.dateScheduled!.month,
            day.dateScheduled!.day,
          );
          if (dayDate.isAfter(todayDate) ||
              dayDate.isAtSameMomentAs(todayDate)) {
            currentWeek = day.week;
            break;
          }
        }
      }

      return _TrainingData(
        upcomingDays: upcomingDays,
        todaysTraining: todayTraining,
        daysCompleted: daysCompleted,
        totalDays: totalDays,
        currentWeek: currentWeek,
        totalWeeks: totalWeeks,
      );
    } catch (e) {
      print('Error calculating training data: $e');
      // Return safe defaults
      return _TrainingData(
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
  final List<TrainingDayModel> upcomingDays;
  final TrainingDayModel? todaysTraining;
  final int daysCompleted;
  final int totalDays;
  final int currentWeek;
  final int totalWeeks;

  _TrainingData({
    required this.upcomingDays,
    this.todaysTraining,
    required this.daysCompleted,
    required this.totalDays,
    required this.currentWeek,
    required this.totalWeeks,
  });
}
