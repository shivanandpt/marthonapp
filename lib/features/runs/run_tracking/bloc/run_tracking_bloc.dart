import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/features/runs/run_tracking/bloc/run_tracking_event.dart';
import 'package:marunthon_app/features/runs/run_tracking/bloc/run_tracking_state.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';
import 'package:marunthon_app/features/runs/services/local_run_storage.dart';
import 'package:marunthon_app/features/runs/services/run_service.dart';
import 'package:marunthon_app/core/services/tts_service.dart';

class RunTrackingBloc extends Bloc<RunTrackingEvent, RunTrackingState> {
  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;
  final RunService _runService = RunService();
  final TTSService _ttsService = TTSService();

  RunTrackingBloc() : super(RunTrackingInitial()) {
    on<StartRun>(_onStartRun);
    on<PauseRun>(_onPauseRun);
    on<ResumeRun>(_onResumeRun);
    on<EndRun>(_onEndRun);
    on<NextPhase>(_onNextPhase);
    on<PreviousPhase>(_onPreviousPhase);
    on<UpdateLocation>(_onUpdateLocation);
    on<UpdateTimer>(_onUpdateTimer);
    on<SaveRunProgress>(_onSaveRunProgress);
    on<LoadSavedRun>(_onLoadSavedRun);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _ttsService.dispose();
    return super.close();
  }

  Future<void> _onStartRun(
    StartRun event,
    Emitter<RunTrackingState> emit,
  ) async {
    try {
      // Request location permission
      final locationPermission = await Permission.location.request();
      if (!locationPermission.isGranted) {
        emit(RunTrackingInitial()); // Could add error state here
        return;
      }

      // Initialize TTS service
      await _ttsService.initialize();

      // Create default phases if none provided
      final phases =
          event.phases ??
          [
            RunPhaseModel(
              id: 'freerun',
              type: RunPhaseType.freeRun,
              name: 'Free Run',
              targetDuration: Duration(minutes: 30),
              description: 'Run at your own pace',
              instructions: 'Maintain a comfortable pace throughout',
            ),
          ];

      final now = DateTime.now();

      emit(
        RunTrackingActive(
          phases: phases,
          currentPhaseIndex: 0,
          status: RunStatus.running,
          elapsedTime: Duration.zero,
          phaseElapsedTime: Duration.zero,
          totalDistance: 0.0,
          currentSpeed: 0.0,
          currentElevation: 0.0,
          routePoints: [],
          startTime: now,
          totalPausedDuration: Duration.zero,
        ),
      );

      // Announce the first phase
      if (phases.isNotEmpty) {
        await _announcePhase(phases[0]);
      }

      // Start location tracking
      _startLocationTracking();

      // Start timer
      _startTimer();
    } catch (e) {
      emit(RunTrackingInitial()); // Could add error state
    }
  }

  Future<void> _onPauseRun(
    PauseRun event,
    Emitter<RunTrackingState> emit,
  ) async {
    if (state is RunTrackingActive) {
      final currentState = state as RunTrackingActive;

      _timer?.cancel();
      _positionSubscription?.cancel();

      emit(
        currentState.copyWith(
          status: RunStatus.paused,
          lastPauseTime: DateTime.now(),
        ),
      );

      // Announce pause
      await _ttsService.speak('Run paused');

      // Save progress locally immediately when paused
      await _saveRunProgress(currentState);
    }
  }

  Future<void> _onResumeRun(
    ResumeRun event,
    Emitter<RunTrackingState> emit,
  ) async {
    if (state is RunTrackingActive) {
      final currentState = state as RunTrackingActive;

      // Calculate paused duration
      Duration additionalPausedDuration = Duration.zero;
      if (currentState.lastPauseTime != null) {
        additionalPausedDuration = DateTime.now().difference(
          currentState.lastPauseTime!,
        );
      }

      emit(
        currentState.copyWith(
          status: RunStatus.running,
          lastPauseTime: null,
          totalPausedDuration:
              currentState.totalPausedDuration + additionalPausedDuration,
        ),
      );

      // Announce resume
      await _ttsService.speak('Run resumed');

      // Restart tracking
      _startLocationTracking();
      _startTimer();
    }
  }

  Future<void> _onEndRun(EndRun event, Emitter<RunTrackingState> emit) async {
    if (state is RunTrackingActive) {
      final currentState = state as RunTrackingActive;

      _timer?.cancel();
      _positionSubscription?.cancel();

      // Announce completion with summary
      final minutes = currentState.elapsedTime.inMinutes;
      final distanceKm = (currentState.totalDistance / 1000).toStringAsFixed(1);
      await _ttsService.speak(
        'Run completed! Total time: $minutes minutes. Distance: $distanceKm kilometers. Great job!',
      );

      // Save completed run
      await _saveCompletedRun(currentState);

      emit(
        RunTrackingCompleted(
          totalTime: currentState.elapsedTime,
          totalDistance: currentState.totalDistance,
          routePoints: currentState.routePoints,
          completedPhases: currentState.phases,
        ),
      );

      // Clear local storage
      await LocalRunStorage.clearActiveRun();
    }
  }

  Future<void> _onNextPhase(
    NextPhase event,
    Emitter<RunTrackingState> emit,
  ) async {
    if (state is RunTrackingActive) {
      final currentState = state as RunTrackingActive;

      if (currentState.hasNextPhase) {
        final nextPhaseIndex = currentState.currentPhaseIndex + 1;

        emit(
          currentState.copyWith(
            currentPhaseIndex: nextPhaseIndex,
            phaseElapsedTime: Duration.zero,
          ),
        );

        // Announce the new phase
        if (nextPhaseIndex < currentState.phases.length) {
          await _announcePhase(currentState.phases[nextPhaseIndex]);
        }
      }
    }
  }

  Future<void> _onPreviousPhase(
    PreviousPhase event,
    Emitter<RunTrackingState> emit,
  ) async {
    if (state is RunTrackingActive) {
      final currentState = state as RunTrackingActive;

      if (currentState.hasPreviousPhase) {
        final previousPhaseIndex = currentState.currentPhaseIndex - 1;

        emit(
          currentState.copyWith(
            currentPhaseIndex: previousPhaseIndex,
            phaseElapsedTime: Duration.zero,
          ),
        );

        // Announce the new phase
        if (previousPhaseIndex >= 0) {
          await _announcePhase(currentState.phases[previousPhaseIndex]);
        }
      }
    }
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<RunTrackingState> emit,
  ) async {
    if (state is RunTrackingActive) {
      final currentState = state as RunTrackingActive;

      // Calculate distance
      double newDistance = currentState.totalDistance;
      if (currentState.routePoints.isNotEmpty) {
        final lastPoint = currentState.routePoints.last;
        newDistance += _calculateDistance(
          lastPoint['latitude'],
          lastPoint['longitude'],
          event.latitude,
          event.longitude,
        );
      }

      // Create new route point
      final routePoint = {
        'latitude': event.latitude,
        'longitude': event.longitude,
        'speed': event.speed,
        'elevation': event.elevation,
        'accuracy': event.accuracy,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final updatedRoutePoints = [...currentState.routePoints, routePoint];

      emit(
        currentState.copyWith(
          totalDistance: newDistance,
          currentSpeed: event.speed,
          currentElevation: event.elevation,
          routePoints: updatedRoutePoints,
        ),
      );
    }
  }

  Future<void> _onUpdateTimer(
    UpdateTimer event,
    Emitter<RunTrackingState> emit,
  ) async {
    if (state is RunTrackingActive) {
      final currentState = state as RunTrackingActive;

      if (currentState.status == RunStatus.running) {
        final newElapsedTime = currentState.elapsedTime + Duration(seconds: 1);
        final newPhaseElapsedTime =
            currentState.phaseElapsedTime + Duration(seconds: 1);

        // Check if current phase is completed and auto-advance
        bool shouldAdvancePhase = false;
        final currentPhase = currentState.currentPhase;

        if (currentPhase.targetDuration.inSeconds > 0 &&
            newPhaseElapsedTime.inSeconds >=
                currentPhase.targetDuration.inSeconds &&
            currentState.hasNextPhase) {
          shouldAdvancePhase = true;
        }

        RunTrackingActive updatedState;

        if (shouldAdvancePhase) {
          // Auto-advance to next phase
          final nextPhaseIndex = currentState.currentPhaseIndex + 1;
          updatedState = currentState.copyWith(
            elapsedTime: newElapsedTime,
            currentPhaseIndex: nextPhaseIndex,
            phaseElapsedTime: Duration.zero, // Reset phase timer
          );

          // Announce the new phase
          if (nextPhaseIndex < currentState.phases.length) {
            await _announcePhase(currentState.phases[nextPhaseIndex]);
          }
        } else {
          // Normal timer update
          updatedState = currentState.copyWith(
            elapsedTime: newElapsedTime,
            phaseElapsedTime: newPhaseElapsedTime,
          );
        }

        emit(updatedState);

        // Auto-save progress every 30 seconds
        if (newElapsedTime.inSeconds % 30 == 0) {
          await _saveRunProgress(updatedState);
        }

        // Provide periodic voice guidance
        if (!shouldAdvancePhase) {
          await _providePeriodicGuidance(updatedState);
        }
      }
    }
  }

  Future<void> _onSaveRunProgress(
    SaveRunProgress event,
    Emitter<RunTrackingState> emit,
  ) async {
    if (state is RunTrackingActive) {
      final currentState = state as RunTrackingActive;
      await _saveRunProgress(currentState);
    }
  }

  Future<void> _onLoadSavedRun(
    LoadSavedRun event,
    Emitter<RunTrackingState> emit,
  ) async {
    try {
      final savedData = await LocalRunStorage.loadActiveRun();
      if (savedData != null) {
        // Restore saved run state
        final phases =
            (savedData['phases'] as List)
                .map((p) => RunPhaseModel.fromMap(p))
                .toList();

        emit(
          RunTrackingActive(
            phases: phases,
            currentPhaseIndex: savedData['currentPhaseIndex'] ?? 0,
            status: RunStatus.values.firstWhere(
              (s) => s.toString() == savedData['status'],
              orElse: () => RunStatus.paused,
            ),
            elapsedTime: Duration(seconds: savedData['elapsedSeconds'] ?? 0),
            phaseElapsedTime: Duration(
              seconds: savedData['phaseElapsedSeconds'] ?? 0,
            ),
            totalDistance: savedData['totalDistance']?.toDouble() ?? 0.0,
            currentSpeed: 0.0,
            currentElevation: 0.0,
            routePoints: List<Map<String, dynamic>>.from(
              savedData['routePoints'] ?? [],
            ),
            startTime:
                savedData['startTime'] != null
                    ? DateTime.parse(savedData['startTime'])
                    : null,
            totalPausedDuration: Duration(
              seconds: savedData['totalPausedSeconds'] ?? 0,
            ),
          ),
        );
      }
    } catch (e) {
      emit(RunTrackingInitial());
    }
  }

  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      add(
        UpdateLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          speed: position.speed,
          elevation: position.altitude,
          accuracy: position.accuracy,
        ),
      );
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      add(UpdateTimer());
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Extract the save progress logic to a private method
  Future<void> _saveRunProgress(RunTrackingActive state) async {
    try {
      await LocalRunStorage.saveActiveRun(
        phases: state.phases,
        currentPhaseIndex: state.currentPhaseIndex,
        status: state.status.toString(),
        elapsedSeconds: state.elapsedTime.inSeconds,
        phaseElapsedSeconds: state.phaseElapsedTime.inSeconds,
        totalDistance: state.totalDistance,
        routePoints: state.routePoints,
        startTime: state.startTime,
        totalPausedSeconds: state.totalPausedDuration.inSeconds,
      );
    } catch (e) {
      print('Error saving run progress: $e');
    }
  }

  Future<void> _saveCompletedRun(RunTrackingActive state) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && state.startTime != null) {
        // Save locally first
        await LocalRunStorage.saveCompletedRunForUpload(
          userId: user.uid,
          distance: state.totalDistance / 1000, // Convert to km
          duration: state.elapsedTime.inSeconds,
          routePoints: state.routePoints,
          phases: state.phases,
          startTime: state.startTime!,
        );

        // Try to upload to Firestore using RunService
        try {
          await _runService.saveRun(
            userId: user.uid,
            distance: state.totalDistance / 1000,
            duration: state.elapsedTime.inSeconds,
            routePoints: state.routePoints,
            startTime: state.startTime!,
          );

          // If successful, remove from local pending
          final pendingRuns = await LocalRunStorage.getPendingRuns();
          if (pendingRuns.isNotEmpty) {
            await LocalRunStorage.removeUploadedRun(pendingRuns.last['id']);
          }
        } catch (e) {
          // Upload failed, but data is saved locally for later retry
          print('Failed to upload run, saved locally: $e');
        }
      }
    } catch (e) {
      print('Error saving completed run: $e');
    }
  }

  // Method to upload pending runs (call this from UI when connectivity is restored)
  Future<void> uploadPendingRuns() async {
    try {
      final pendingRuns = await LocalRunStorage.getPendingRuns();
      if (pendingRuns.isNotEmpty) {
        final uploadedIds = await _runService.uploadPendingRuns(pendingRuns);

        // Remove successfully uploaded runs from local storage
        for (final id in uploadedIds) {
          await LocalRunStorage.removeUploadedRun(id);
        }
      }
    } catch (e) {
      print('Error uploading pending runs: $e');
    }
  }

  /// Announces a training phase using text-to-speech
  Future<void> _announcePhase(RunPhaseModel phase) async {
    try {
      if (!_ttsService.isInitialized) {
        await _ttsService.initialize();
      }

      // Determine the text to announce - prioritize voicePrompt over instructions
      String phaseText = '';
      if (phase.voicePrompt != null && phase.voicePrompt!.isNotEmpty) {
        phaseText = phase.voicePrompt!;
      } else if (phase.instructions.isNotEmpty) {
        phaseText = phase.instructions;
      } else {
        // Fallback to a generic message
        phaseText = 'Continue with your ${phase.name.toLowerCase()}';
      }

      // Create the announcement text based on phase type
      String announcement = '';
      switch (phase.type) {
        case RunPhaseType.warmup:
          announcement = 'Starting warm up phase. $phaseText';
          break;
        case RunPhaseType.easyRun:
          announcement = 'Starting easy run phase. $phaseText';
          break;
        case RunPhaseType.intervals:
          announcement = 'Starting intervals phase. $phaseText';
          break;
        case RunPhaseType.recovery:
          announcement = 'Starting recovery phase. $phaseText';
          break;
        case RunPhaseType.cooldown:
          announcement = 'Starting cool down phase. $phaseText';
          break;
        case RunPhaseType.freeRun:
          announcement = 'Starting free run. $phaseText';
          break;
      }

      // Add duration information if available
      if (phase.targetDuration.inMinutes > 0) {
        final minutes = phase.targetDuration.inMinutes;
        announcement += ' Target duration: $minutes minutes.';
      }

      // Debug logging
      print('TTS Debug - Phase: ${phase.name}');
      print('TTS Debug - VoicePrompt: "${phase.voicePrompt}"');
      print('TTS Debug - Instructions: "${phase.instructions}"');
      print('TTS Debug - Final announcement: "$announcement"');

      // Speak the announcement
      await _ttsService.speak(announcement);
    } catch (e) {
      print('Error announcing phase: $e');
    }
  }

  /// Provides periodic voice guidance during training phases
  Future<void> _providePeriodicGuidance(RunTrackingActive state) async {
    try {
      if (!_ttsService.isInitialized) return;

      final currentPhase = state.currentPhase;
      final phaseElapsed = state.phaseElapsedTime;
      final totalElapsed = state.elapsedTime;

      // Provide guidance at specific intervals
      final elapsedSeconds = phaseElapsed.inSeconds;
      final totalSeconds = totalElapsed.inSeconds;

      // Phase-specific guidance intervals
      if (currentPhase.targetDuration.inSeconds > 0) {
        final targetSeconds = currentPhase.targetDuration.inSeconds;
        final remainingSeconds = targetSeconds - elapsedSeconds;

        // Warn when 30 seconds remaining (for phases longer than 1 minute)
        if (remainingSeconds == 30 && targetSeconds > 60) {
          await _ttsService.speak('30 seconds remaining in this phase');
          return;
        }

        // Warn when 10 seconds remaining (for all phases)
        if (remainingSeconds == 10) {
          await _ttsService.speak('10 seconds left');
          return;
        }

        // Halfway point announcement (for phases longer than 2 minutes)
        if (targetSeconds > 120 && elapsedSeconds == targetSeconds ~/ 2) {
          await _ttsService.speak('Halfway through this phase. Keep going!');
          return;
        }
      }

      // General motivational updates every 5 minutes
      if (totalSeconds > 0 && totalSeconds % 300 == 0) {
        final minutes = totalSeconds ~/ 60;
        final distanceKm = (state.totalDistance / 1000).toStringAsFixed(1);
        await _ttsService.speak(
          '$minutes minutes completed. Distance: $distanceKm kilometers. Great job!',
        );
        return;
      }

      // Speed guidance for intervals (every minute during high-intensity phases)
      if (currentPhase.type == RunPhaseType.intervals &&
          elapsedSeconds % 60 == 0 &&
          elapsedSeconds > 0) {
        final currentSpeedKmh = (state.currentSpeed * 3.6).toStringAsFixed(1);
        if (state.currentSpeed > 0) {
          await _ttsService.speak(
            'Current speed: $currentSpeedKmh kilometers per hour. Keep pushing!',
          );
        } else {
          await _ttsService.speak('Maintain your interval pace!');
        }
        return;
      }

      // Recovery phase guidance (every 30 seconds)
      if (currentPhase.type == RunPhaseType.recovery &&
          elapsedSeconds % 30 == 0 &&
          elapsedSeconds > 0) {
        await _ttsService.speak('Take your time to recover. Easy pace.');
        return;
      }
    } catch (e) {
      print('Error providing periodic guidance: $e');
    }
  }
}
