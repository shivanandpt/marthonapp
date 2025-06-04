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
    upcomingTrainingDays,
    todaysTraining,
    daysCompleted,
    totalDays,
    currentWeek,
    totalWeeks,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
