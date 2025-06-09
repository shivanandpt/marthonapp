import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/training_plan_model.dart';
import '../../models/training_day_model.dart';
import '../../services/ai_training_plan_service.dart';
import '../../services/training_plan_service.dart';
import '../../services/training_day_service.dart';
import '../../../user/user_profile/setup/models/user_model.dart';

// Events
abstract class AIPlanCreationEvent extends Equatable {
  const AIPlanCreationEvent();

  @override
  List<Object?> get props => [];
}

class GeneratePlanEvent extends AIPlanCreationEvent {
  final UserModel user;

  const GeneratePlanEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class ApprovePlanEvent extends AIPlanCreationEvent {
  final TrainingPlanModel trainingPlan;
  final List<TrainingDayModel> trainingDays;

  const ApprovePlanEvent(this.trainingPlan, this.trainingDays);

  @override
  List<Object?> get props => [trainingPlan, trainingDays];
}

class ResetCreationEvent extends AIPlanCreationEvent {
  const ResetCreationEvent();
}

// States
abstract class AIPlanCreationState extends Equatable {
  const AIPlanCreationState();

  @override
  List<Object?> get props => [];
}

class AIPlanCreationInitial extends AIPlanCreationState {}

class AIPlanCreationLoading extends AIPlanCreationState {}

class AIPlanCreationGenerated extends AIPlanCreationState {
  final TrainingPlanModel trainingPlan;
  final List<TrainingDayModel> trainingDays;

  const AIPlanCreationGenerated(this.trainingPlan, this.trainingDays);

  @override
  List<Object?> get props => [trainingPlan, trainingDays];
}

class AIPlanCreationSuccess extends AIPlanCreationState {}

class AIPlanCreationError extends AIPlanCreationState {
  final String message;

  const AIPlanCreationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AIPlanCreationBloc
    extends Bloc<AIPlanCreationEvent, AIPlanCreationState> {
  final TrainingPlanService _trainingPlanService = TrainingPlanService();
  final TrainingDayService _trainingDayService = TrainingDayService();

  AIPlanCreationBloc() : super(AIPlanCreationInitial()) {
    on<GeneratePlanEvent>(_onGeneratePlan);
    on<ApprovePlanEvent>(_onApprovePlan);
    on<ResetCreationEvent>(_onResetCreation);
  }

  Future<void> _onGeneratePlan(
    GeneratePlanEvent event,
    Emitter<AIPlanCreationState> emit,
  ) async {
    emit(AIPlanCreationLoading());

    try {
      // Generate training plan using AI
      final result = await AITrainingPlanService.generateTrainingPlan(
        user: event.user,
      );

      final trainingPlan = result['plan'] as TrainingPlanModel;
      final trainingDays = result['trainingDays'] as List<TrainingDayModel>;

      emit(AIPlanCreationGenerated(trainingPlan, trainingDays));
    } catch (e) {
      emit(
        AIPlanCreationError(
          'Failed to generate training plan: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onApprovePlan(
    ApprovePlanEvent event,
    Emitter<AIPlanCreationState> emit,
  ) async {
    emit(AIPlanCreationLoading());

    try {
      // Save the approved training plan to Firebase
      String planId = await _trainingPlanService.createTrainingPlan(
        event.trainingPlan,
      );

      // Also create the individual training days
      for (final trainingDay in event.trainingDays) {
        await _trainingDayService.createTrainingDay(planId, trainingDay);
      }

      emit(AIPlanCreationSuccess());
    } catch (e) {
      emit(
        AIPlanCreationError('Failed to save training plan: ${e.toString()}'),
      );
    }
  }

  void _onResetCreation(
    ResetCreationEvent event,
    Emitter<AIPlanCreationState> emit,
  ) {
    emit(AIPlanCreationInitial());
  }
}
