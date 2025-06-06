// lib/features/home/bloc/home_event.dart
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

// Add event for deleting runs
class DeleteRun extends HomeEvent {
  final String runId;

  const DeleteRun(this.runId);

  @override
  List<Object?> get props => [runId];
}

// Add event for refreshing runs after deletion
class RefreshRuns extends HomeEvent {
  const RefreshRuns();
}
