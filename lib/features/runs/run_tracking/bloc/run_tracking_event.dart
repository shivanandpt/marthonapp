import 'package:equatable/equatable.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';

abstract class RunTrackingEvent extends Equatable {
  const RunTrackingEvent();

  @override
  List<Object?> get props => [];
}

class StartRun extends RunTrackingEvent {
  final List<RunPhaseModel>? phases;

  const StartRun({this.phases});

  @override
  List<Object?> get props => [phases];
}

class PauseRun extends RunTrackingEvent {
  const PauseRun();
}

class ResumeRun extends RunTrackingEvent {
  const ResumeRun();
}

class EndRun extends RunTrackingEvent {
  const EndRun();
}

class NextPhase extends RunTrackingEvent {
  const NextPhase();
}

class PreviousPhase extends RunTrackingEvent {
  const PreviousPhase();
}

class UpdateLocation extends RunTrackingEvent {
  final double latitude;
  final double longitude;
  final double speed;
  final double elevation;
  final double accuracy;

  const UpdateLocation({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.elevation,
    required this.accuracy,
  });

  @override
  List<Object?> get props => [latitude, longitude, speed, elevation, accuracy];
}

class UpdateTimer extends RunTrackingEvent {
  const UpdateTimer();
}

class SaveRunProgress extends RunTrackingEvent {
  const SaveRunProgress();
}

class LoadSavedRun extends RunTrackingEvent {
  const LoadSavedRun();
}
