// lib/features/home/bloc/home_state.dart
import 'package:equatable/equatable.dart';
import 'package:marunthon_app/features/user/user_profile/setup/models/user_model.dart';
import 'package:marunthon_app/features/home/models/training_plan_model.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeProfileNotFound extends HomeState {
  const HomeProfileNotFound();
}

class HomeLoaded extends HomeState {
  final UserModel userModel;
  final TrainingPlanModel? activePlan;
  final List<RunModel> recentRuns;
  final List<RunModel> allRuns; // Add this line for all runs
  final List<TrainingDayModel> allTrainingDays; // Add all training days
  final List<TrainingDayModel> upcomingTrainingDays;
  final TrainingDayModel? todaysTraining;
  final int daysCompleted;
  final int totalDays;
  final int currentWeek;
  final int totalWeeks;

  const HomeLoaded({
    required this.userModel,
    this.activePlan,
    required this.recentRuns,
    required this.allRuns, // Add this parameter
    required this.allTrainingDays, // Add all training days parameter
    required this.upcomingTrainingDays,
    this.todaysTraining,
    required this.daysCompleted,
    required this.totalDays,
    required this.currentWeek,
    required this.totalWeeks,
  });

  @override
  List<Object?> get props => [
    userModel,
    activePlan,
    recentRuns,
    allRuns, // Add to props
    allTrainingDays, // Add all training days to props
    upcomingTrainingDays,
    todaysTraining,
    daysCompleted,
    totalDays,
    currentWeek,
    totalWeeks,
  ];

  // Add copyWith method for easy state updates
  HomeLoaded copyWith({
    UserModel? userModel,
    TrainingPlanModel? activePlan,
    List<RunModel>? recentRuns,
    List<RunModel>? allRuns,
    List<TrainingDayModel>? allTrainingDays,
    List<TrainingDayModel>? upcomingTrainingDays,
    TrainingDayModel? todaysTraining,
    int? daysCompleted,
    int? totalDays,
    int? currentWeek,
    int? totalWeeks,
  }) {
    return HomeLoaded(
      userModel: userModel ?? this.userModel,
      activePlan: activePlan ?? this.activePlan,
      recentRuns: recentRuns ?? this.recentRuns,
      allRuns: allRuns ?? this.allRuns,
      allTrainingDays: allTrainingDays ?? this.allTrainingDays,
      upcomingTrainingDays: upcomingTrainingDays ?? this.upcomingTrainingDays,
      todaysTraining: todaysTraining ?? this.todaysTraining,
      daysCompleted: daysCompleted ?? this.daysCompleted,
      totalDays: totalDays ?? this.totalDays,
      currentWeek: currentWeek ?? this.currentWeek,
      totalWeeks: totalWeeks ?? this.totalWeeks,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
