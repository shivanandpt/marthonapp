import 'package:firebase_ai/firebase_ai.dart';
import '../../../features/user/user_profile/setup/models/user_model.dart';
import '../models/training_plan_model.dart';
import '../models/training_day_model.dart';
import '../models/plan/plan_structure_model.dart';
import '../models/plan/plan_progress_model.dart';
import '../models/plan/plan_dates_model.dart';
import '../models/plan/plan_settings_model.dart';
import '../models/plan/plan_statistics_model.dart';
import '../models/days/day_identification_model.dart';
import '../models/days/day_scheduling_model.dart';
import '../models/days/day_configuration_model.dart';
import '../models/days/day_status_model.dart';
import '../models/days/training_phase_model.dart';
import '../models/days/day_totals_model.dart';
import '../models/days/day_target_metrics_model.dart';
import '../models/days/day_completion_data_model.dart';

class AITrainingPlanService {
  static final _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
    generationConfig: GenerationConfig(
      temperature: 0.3, // Lower temperature for more consistent output
      topK: 20,
      topP: 0.8,
      maxOutputTokens: 2048, // Limit output to prevent truncation
    ),
  );

  /// Generates a custom training plan using Firebase AI based on user profile
  /// Returns a map with 'plan' and 'trainingDays' keys
  static Future<Map<String, dynamic>> generateTrainingPlan({
    required UserModel user,
  }) async {
    try {
      // Create the AI prompt based on user data
      final prompt = _buildTrainingPlanPrompt(user);

      // Generate the plan using Firebase AI
      final aiResponse = await _model.generateContent([Content.text(prompt)]);

      // Parse the AI response and create training plan
      final planData = parseAIResponse(
        aiResponse.text ?? '',
        user.trainingPreferences.runDaysPerWeek,
      );

      final result = _createTrainingPlanFromAI(planData: planData, user: user);
      return result;
    } catch (e) {
      throw Exception('Failed to generate training plan: $e');
    }
  }

  /// Builds a detailed prompt for the AI to generate a training plan
  static String _buildTrainingPlanPrompt(UserModel user) {
    final age = user.age;
    final experience = user.trainingPreferences.experience;
    final goal = user.trainingPreferences.goal;
    final runDaysPerWeek = user.trainingPreferences.runDaysPerWeek;
    final injuries = user.trainingPreferences.injuryNotes;
    final goalDate = user.trainingPreferences.goalEventDate;
    final gender = user.gender;
    final weight = user.weight;
    final height = user.height;

    // Calculate BMI and health risk assessment
    double bmi = 0.0;
    String bmiCategory = 'normal';
    String injuryRisk = 'moderate';

    if (weight > 0 && height > 0) {
      if (user.metricSystem == 'metric') {
        bmi = weight / ((height / 100) * (height / 100));
      } else {
        bmi = (weight * 703) / (height * height);
      }

      if (bmi < 18.5) {
        bmiCategory = 'underweight';
        injuryRisk = 'low';
      } else if (bmi < 25) {
        bmiCategory = 'normal';
        injuryRisk = 'low';
      } else if (bmi < 30) {
        bmiCategory = 'overweight';
        injuryRisk = 'moderate';
      } else {
        bmiCategory = 'obese';
        injuryRisk = 'high';
      }
    }

    return '''
Create a training plan for $experience $goal runner (BMI: ${bmi.toStringAsFixed(1)}).

USER PROFILE: Age $age, $gender, BMI $bmiCategory, Risk: $injuryRisk
GUIDANCE: ${getBMIGuidance(bmiCategory)}
${injuries.isNotEmpty ? 'INJURIES: $injuries' : ''}
${goalDate != null ? 'GOAL DATE: ${goalDate.toString().split(' ')[0]}' : ''}

SAFETY CONSTRAINTS:
- BMI $bmiCategory safety: ${getBMISafetyNotes(bmiCategory)}
- Max repetitions: ${_getMaxRepetitions(bmiCategory)} per session
- Expected Distance Per Session: for $bmiCategory person in meters
- Expected Pace Per Session: for $bmiCategory person in meters/second

GENERATE COMPACT DATA FORMAT:

PLAN_INFO|BMI-Optimized $goal Plan|Personalized $bmiCategory BMI training|[WEEKS]|[TOTAL_SESSIONS]

WEEKLY_DATA (Format: Week|Focus|RunPhaseTime|WalkPhaseTime|Repetitions|Instructions|Tempo|ExpectedDistancePerSession|ExpectedPacePerSession):
[Generate appropriate weekly progression considering BMI constraints]

PROGRESSION GUIDELINES:
- Start conservatively based on BMI category
- Progress gradually based on experience level
- Adjust intensity and volume appropriately
- Consider goal date if provided but prioritize safety

RESPOND WITH DATA LINES ONLY (no explanations):''';
  }

  /// Parses the AI response and extracts training plan data from compact string format
  static Map<String, dynamic> parseAIResponse(
    String aiResponse,
    int runDaysPerWeek,
  ) {
    try {
      // Parse the compact string format
      String cleanResponse = aiResponse.trim();
      final lines = cleanResponse.split('\n');

      Map<String, dynamic> planInfo = {};
      List<Map<String, dynamic>> weeks = [];

      for (String line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        if (line.startsWith('PLAN_INFO|')) {
          planInfo = _parsePlanInfo(line);
        } else if (line.startsWith('WEEKLY_DATA|')) {
          // This is weekly data - remove the prefix and parse
          final weeklyDataLine = line.substring('WEEKLY_DATA|'.length);
          final weekData = _parseWeeklyData(weeklyDataLine, runDaysPerWeek);
          if (weekData != null) {
            weeks.add(weekData);
          }
        }
      } // Ensure we have plan info - use AI values first, fallback to calculated values
      if (planInfo.isEmpty && weeks.isNotEmpty) {
        // No plan info found, create default plan info from weeks data
        int actualTotalSessions = 0;
        for (final week in weeks) {
          final sessions = week['sessions'] as List<dynamic>? ?? [];
          actualTotalSessions += sessions.length;
        }

        planInfo = {
          'planName': 'AI Generated Training Plan',
          'description': 'Personalized training plan',
          'totalWeeks': weeks.length,
          'totalSessions': actualTotalSessions,
        };
      }
      // If planInfo exists from AI response, use those values as-is
      // No need to override AI-provided totalWeeks and totalSessions

      // Validate that we have some data
      if (weeks.isEmpty) {
        throw Exception('No weekly data found in AI response');
      }

      return {...planInfo, 'weeks': weeks};
    } catch (e) {
      // If parsing fails, create a minimal fallback plan
      print('AI response parsing failed: $e');
      return createFallbackPlan();
    }
  }

  /// Parse plan info line: PLAN_INFO|name|description|weeks|sessions
  static Map<String, dynamic> _parsePlanInfo(String line) {
    final parts = line.split('|');
    if (parts.length >= 5) {
      return {
        'planName': parts[1],
        'description': parts[2],
        'totalWeeks': int.tryParse(parts[3]) ?? 12,
        'totalSessions': int.tryParse(parts[4]) ?? 36,
      };
    }
    return {};
  }

  /// Parse weekly data line: Week|Focus|RunPhaseTime|WalkPhaseTime|Repetitions|Instructions|Tempo
  static Map<String, dynamic>? _parseWeeklyData(
    String line,
    int runDaysPerWeek,
  ) {
    final parts = line.split('|');
    if (parts.length >= 9) {
      final weekNumber = int.tryParse(parts[0]) ?? 1;
      final focus = parts[1];

      // Parse run phase time (remove safety caps to allow progression)
      int runPhaseTime = int.tryParse(parts[2]) ?? 2;

      // Parse walk phase time (remove safety caps to allow progression)
      int walkPhaseTime = int.tryParse(parts[3]) ?? 2;

      // Parse repetitions with reasonable safety limits
      int repetitions = int.tryParse(parts[4]) ?? 8;
      repetitions = repetitions.clamp(
        1,
        50,
      ); // Allow more repetitions for progression

      final instructions = parts[5];
      final tempo = parts[6];
      double expectedDistance =
          parts.length > 7 ? double.tryParse(parts[7]) ?? 0.0 : 0.0;
      double expectedPace =
          parts.length > 8 ? double.tryParse(parts[8]) ?? 0.0 : 0.0;
      // Create sessions for each training day in the week
      final sessions = <Map<String, dynamic>>[];
      final sessionDays =
          runDaysPerWeek == 3
              ? [1, 3, 5]
              : runDaysPerWeek == 4
              ? [1, 2, 4, 6]
              : [1, 2, 3, 5, 6]; // 5+ days

      for (int i = 0; i < runDaysPerWeek; i++) {
        final dayOfWeek = sessionDays[i];
        final sessionType =
            i == 1
                ? 'recovery_run'
                : 'interval_training'; // Middle session is recovery

        sessions.add({
          'dayOfWeek': dayOfWeek,
          'sessionType': sessionType,
          'title':
              sessionType == 'recovery_run'
                  ? 'Recovery Session'
                  : 'Run/Walk Intervals',
          'totalDuration': _calculateSessionDuration(
            runPhaseTime,
            walkPhaseTime,
            repetitions,
          ),
          'intensity': tempo,
          'phases': _generateSessionPhasesFromWeekData(
            runPhaseTime,
            walkPhaseTime,
            repetitions,
            instructions,
            sessionType == 'recovery_run',
          ),
          'notes': instructions,
          'expectedDistance': expectedDistance,
          'targetPace': expectedPace,
        });
      }

      return {'weekNumber': weekNumber, 'focus': focus, 'sessions': sessions};
    }
    return null;
  }

  /// Create a fallback training plan if AI parsing fails
  static Map<String, dynamic> createFallbackPlan() {
    const totalWeeks = 12;
    const sessionsPerWeek = 3;

    final weeks = <Map<String, dynamic>>[];

    // Generate all 12 weeks
    for (int week = 1; week <= totalWeeks; week++) {
      final sessions = <Map<String, dynamic>>[];

      // Week 1: Day 1, 3, 5
      final sessionDays = [1, 3, 5];
      final sessionTypes = [
        'interval_training',
        'recovery_run',
        'interval_training',
      ];

      for (int i = 0; i < sessionDays.length; i++) {
        final dayOfWeek = sessionDays[i];
        final sessionType = sessionTypes[i];
        final isRecovery = sessionType == 'recovery_run';

        // Progressive difficulty
        final runDuration = (1.5 + (week * 0.3)).clamp(1, 4).round();
        final walkDuration = (2.5 - (week * 0.1)).clamp(1, 3).round();
        final repetitions = (6 + (week * 0.5)).clamp(6, 12).round();
        final totalDurationMinutes = isRecovery ? 20 + week : 25 + (week * 2);
        final totalDuration = totalDurationMinutes * 60; // Convert to seconds

        sessions.add({
          'dayOfWeek': dayOfWeek,
          'sessionType': sessionType,
          'title': isRecovery ? 'Recovery Session' : 'Run/Walk Intervals',
          'totalDuration': totalDuration,
          'intensity': 'easy',
          'phases': [
            {
              'phaseType': 'warmup',
              'duration': 5 * 60, // Convert to seconds
              'instruction': 'Walk and light stretching',
              'allowsRunning': false,
              'repetitions': 1,
            },
            {
              'phaseType': 'run',
              'duration': runDuration * 60, // Convert to seconds
              'instruction':
                  isRecovery ? 'Very easy recovery pace' : 'Easy pace running',
              'allowsRunning': true,
              'repetitions': isRecovery ? (repetitions ~/ 2) : repetitions,
            },
            {
              'phaseType': 'walk',
              'duration': walkDuration * 60, // Convert to seconds
              'instruction': 'Recovery walk',
              'allowsRunning': false,
              'repetitions': isRecovery ? (repetitions ~/ 2) : repetitions,
            },
            {
              'phaseType': 'cooldown',
              'duration': 5 * 60, // Convert to seconds
              'instruction': 'Cool down walk',
              'allowsRunning': false,
              'repetitions': 1,
            },
          ],
          'notes':
              isRecovery
                  ? 'Light recovery session - week $week'
                  : 'Progressive training - week $week',
        });
      }

      weeks.add({
        'weekNumber': week,
        'focus':
            week <= 4
                ? 'Foundation Building'
                : week <= 8
                ? 'Endurance Development'
                : 'Peak Training',
        'sessions': sessions,
      });
    }

    return {
      'planName': 'Basic Training Plan',
      'description': 'Fallback plan generated due to parsing error',
      'totalWeeks': totalWeeks,
      'totalSessions': totalWeeks * sessionsPerWeek,
      'weeks': weeks,
    };
  }

  /// Creates a TrainingPlanModel from parsed AI data
  /// Returns a map with 'plan' and 'trainingDays' keys
  static Map<String, dynamic> _createTrainingPlanFromAI({
    required Map<String, dynamic> planData,
    required UserModel user,
  }) {
    final now = DateTime.now();
    final startDate = now;
    final weeks = planData['totalWeeks'] as int? ?? 12;
    final endDate = startDate.add(Duration(days: weeks * 7));

    // Convert AI weeks data to training days
    final trainingDays = <TrainingDayModel>[];
    final weeksData = planData['weeks'] as List<dynamic>;

    int globalDayCounter = 1;
    for (final weekData in weeksData) {
      final sessions = weekData['sessions'] as List<dynamic>;
      final weekNumber = weekData['weekNumber'] as int;

      // Sort sessions by dayOfWeek to ensure proper ordering
      sessions.sort(
        (a, b) => (a['dayOfWeek'] ?? 1).compareTo(b['dayOfWeek'] ?? 1),
      );

      for (final sessionData in sessions) {
        if (sessionData['sessionType'] != 'rest') {
          final dayOfWeek = sessionData['dayOfWeek'] as int? ?? 1;

          // Calculate scheduled date based on week and day
          final scheduledDate = startDate.add(
            Duration(days: ((weekNumber - 1) * 7) + (dayOfWeek - 1)),
          );

          final trainingDay = _createTrainingDayFromSession(
            sessionData: sessionData,
            dayNumber: globalDayCounter,
            dayOfWeek: dayOfWeek,
            weekNumber: weekNumber,
            scheduledDate: scheduledDate,
            userId: user.id,
          );
          trainingDays.add(trainingDay);
          globalDayCounter++;
        }
      }
    }

    // Calculate totals
    final double totalDistance = _calculateTotalDistance(trainingDays);
    final totalDuration = _calculateTotalTime(trainingDays);
    final averageDuration =
        trainingDays.isEmpty
            ? 0
            : (totalDuration / trainingDays.length).round();

    final plan = TrainingPlanModel(
      userId: user.id,
      goalType: user.trainingPreferences.goal,
      planType: 'ai_generated',
      planName:
          planData['planName'] ??
          'AI Generated ${user.trainingPreferences.goal} Plan',
      description:
          planData['description'] ?? 'Custom training plan generated by AI',
      structure: PlanStructureModel(
        weeks: weeks,
        runDaysPerWeek: user.trainingPreferences.runDaysPerWeek,
        totalSessions: trainingDays.length,
      ),
      progress: PlanProgressModel(
        isActive: true,
        currentWeek: 1,
        currentDay: 1,
        completedWeeks: 0,
        completedSessions: 0,
      ),
      dates: PlanDatesModel(
        startDate: startDate,
        estimatedEndDate: endDate,
        actualEndDate: null,
      ),
      settings: PlanSettingsModel(
        difficulty: user.trainingPreferences.experience,
        restDaysBetweenRuns: 1,
        allowSkipDays: true,
        maxSkippedDays: 2,
      ),
      statistics: PlanStatisticsModel(
        totalPlannedDistance: totalDistance,
        totalPlannedDuration: totalDuration,
        averageSessionDuration: averageDuration,
      ),
      createdAt: now,
      updatedAt: now,
    );

    return {'plan': plan, 'trainingDays': trainingDays};
  }

  /// Creates a TrainingDayModel from AI session data
  static TrainingDayModel _createTrainingDayFromSession({
    required Map<String, dynamic> sessionData,
    required int dayNumber,
    required int dayOfWeek,
    required int weekNumber,
    required DateTime scheduledDate,
    required String userId,
  }) {
    final now = DateTime.now();
    final sessionType = _mapSessionType(
      sessionData['sessionType'] ?? 'easy_run',
    );
    final totalDuration = _parseDuration(sessionData['totalDuration']);

    // Parse phases from AI response with repetition support
    final phases = <TrainingPhaseModel>[];
    final aiPhases = sessionData['phases'] as List<dynamic>? ?? [];

    for (final phaseData in aiPhases) {
      final phaseType = phaseData['phaseType'] ?? 'run';
      final duration = _parseDuration(phaseData['duration']);
      final instruction = phaseData['instruction'] ?? '';
      final allowsRunning = phaseData['allowsRunning'] ?? true;
      final repetitions = _parseRepetitions(phaseData['repetitions']);

      // Map AI phase types to our phase types
      String mappedPhase;
      switch (phaseType.toLowerCase()) {
        case 'warmup':
        case 'warm_up':
          mappedPhase = 'warmup';
          break;
        case 'cooldown':
        case 'cool_down':
          mappedPhase = 'cooldown';
          break;
        case 'walk':
          mappedPhase = 'walk';
          break;
        case 'run':
        default:
          mappedPhase = 'run';
          break;
      }

      // Create multiple phases based on repetition count
      for (int i = 0; i < repetitions; i++) {
        String phaseInstruction = instruction;

        // Add repetition context for run/walk intervals
        if (repetitions > 1 &&
            (mappedPhase == 'run' || mappedPhase == 'walk')) {
          phaseInstruction = '$instruction (${i + 1} of $repetitions)';
        }

        phases.add(
          TrainingPhaseModel(
            phase: mappedPhase,
            duration: duration, // Duration should already be in seconds
            instruction: phaseInstruction,
            targetPace:
                allowsRunning
                    ? _mapIntensity(sessionData['intensity'] ?? 'easy')
                    : 'walk',
            voicePrompt: _generateVoicePrompt(mappedPhase, phaseInstruction),
          ),
        );
      }
    }

    // If no phases provided, create a default single run phase
    if (phases.isEmpty) {
      phases.add(
        TrainingPhaseModel(
          phase: 'run',
          duration: totalDuration, // Duration should already be in seconds
          instruction:
              sessionData['description'] ?? 'Complete your training session',
          targetPace: _mapIntensity(sessionData['intensity'] ?? 'easy'),
          voicePrompt: 'Start your $sessionType session',
        ),
      );
    }

    final totals = DayTotalsModel.fromPhases(phases);

    // Calculate total distance from session data or estimate from running duration
    final estimatedDistance =
        _parseDistance(sessionData['distance']) ??
        _estimateDistanceFromRunningDuration(
          totals.totalRunTime, // Use actual running time from phases
          sessionData['intensity'] ?? 'easy',
        );

    return TrainingDayModel(
      identification: DayIdentificationModel(
        week: weekNumber,
        dayOfWeek: dayOfWeek,
        dayNumber: dayNumber,
        sessionType: sessionType,
      ),
      scheduling: DaySchedulingModel(
        dateScheduled: scheduledDate,
        timeSlot: 'morning',
      ),
      configuration: DayConfigurationModel(
        restDay: false,
        optional: false,
        difficulty: sessionData['intensity'] ?? 'easy',
      ),
      status: DayStatusModel(
        completed: false,
        skipped: false,
        locked: dayNumber > 1,
      ),
      runPhases: phases,
      totals: totals,
      targetMetrics: DayTargetMetricsModel(
        targetDistance: estimatedDistance, // Keep in meters
        targetCalories:
            (totals.totalDuration ~/ 60 * 12)
                .round(), // Calorie estimate: ~12 cal/min
        targetPace: _calculatePaceFromSpeed(
          (sessionData['targetPace'] as num?)?.toDouble() ?? 0.0,
          sessionData['intensity'] ?? 'easy',
        ), // Pace in min/km
        expectedDistance: estimatedDistance, // Keep in meters
      ),
      completionData: DayCompletionDataModel(
        actualDistance: null,
        actualDuration: null,
        completedAt: null,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }

  static String _mapSessionType(String aiType) {
    switch (aiType.toLowerCase()) {
      case 'interval_training':
        return 'intervals';
      case 'tempo_intervals':
        return 'tempo_run';
      case 'endurance_build':
        return 'long_run';
      case 'recovery_run':
        return 'easy_run';
      case 'easy_run':
        return 'easy_run';
      case 'interval':
        return 'intervals';
      case 'tempo':
        return 'tempo_run';
      case 'long_run':
        return 'long_run';
      default:
        return 'easy_run';
    }
  }

  static String _mapIntensity(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'easy':
        return 'slow';
      case 'moderate':
        return 'moderate';
      case 'hard':
        return 'fast';
      default:
        return 'moderate';
    }
  }

  static double? _parseDistance(dynamic distance) {
    if (distance is num) return distance.toDouble();
    if (distance is String) {
      final numStr = distance.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(numStr);
    }
    return null;
  }

  static int _parseDuration(dynamic duration) {
    if (duration is num)
      return duration.toInt(); // Assume already in correct unit (seconds)
    if (duration is String) {
      final numStr = duration.replaceAll(RegExp(r'[^\d]'), '');
      return int.tryParse(numStr) ?? 1800; // Default 30 minutes in seconds
    }
    return 1800; // Default 30 minutes in seconds
  }

  /// Parses repetition count from AI response
  static int _parseRepetitions(dynamic repetitions) {
    if (repetitions is num) return repetitions.toInt().clamp(1, 50);
    if (repetitions is String) {
      final numStr = repetitions.replaceAll(RegExp(r'[^\d]'), '');
      final parsed = int.tryParse(numStr) ?? 1;
      return parsed.clamp(1, 50); // Reasonable limits for safety
    }
    return 1; // Default to 1 repetition if not specified
  }

  /// Get BMI-specific training guidance
  static String getBMIGuidance(String bmiCategory) {
    switch (bmiCategory) {
      case 'underweight':
        return 'Build stamina gradually, avoid overexertion';
      case 'normal':
        return 'Standard progression suitable for experience level';
      case 'overweight':
        return 'Increase walking portions, gentler intensity progression';
      case 'obese':
        return 'Emphasize walking with very short running intervals';
      default:
        return 'Standard progression';
    }
  }

  /// Get BMI-specific safety notes
  static String getBMISafetyNotes(String bmiCategory) {
    switch (bmiCategory) {
      case 'underweight':
        return 'Focus on gradual progression. Stop if feeling dizzy or weak.';
      case 'normal':
        return 'Listen to your body and progress gradually.';
      case 'overweight':
        return 'Prioritize walking recovery. Increase intensity slowly.';
      case 'obese':
        return 'Safety first - start very conservatively. Consider medical clearance.';
      default:
        return 'Listen to your body and progress gradually.';
    }
  }

  /// Get maximum safe repetitions based on BMI category
  static int _getMaxRepetitions(String bmiCategory) {
    switch (bmiCategory) {
      case 'obese':
        return 12; // Maximum 12 repetitions
      case 'overweight':
        return 15; // Maximum 15 repetitions
      case 'underweight':
        return 12; // Conservative limit for underweight
      default:
        return 20; // Maximum 20 repetitions for normal BMI
    }
  }

  /// Generates a voice prompt for a training phase
  static String _generateVoicePrompt(String phaseType, String instruction) {
    switch (phaseType.toLowerCase()) {
      case 'warmup':
        return 'Time to warm up. $instruction';
      case 'run':
        return 'Start running. $instruction';
      case 'walk':
        return 'Walk to recover. $instruction';
      case 'cooldown':
        return 'Cool down time. $instruction';
      default:
        return instruction.isNotEmpty ? instruction : 'Continue your training';
    }
  }

  /// Estimates distance in meters based on running duration and intensity
  static double _estimateDistanceFromRunningDuration(
    int runningDurationSeconds,
    String intensity,
  ) {
    // Rough estimates based on typical running speeds in m/s
    double metersPerSecond;
    switch (intensity.toLowerCase()) {
      case 'easy':
        metersPerSecond = 2.68; // ~6 min/km pace (10 km/h)
        break;
      case 'moderate':
        metersPerSecond = 3.33; // ~5 min/km pace (12 km/h)
        break;
      case 'hard':
        metersPerSecond = 4.17; // ~4 min/km pace (15 km/h)
        break;
      default:
        metersPerSecond = 2.68;
        break;
    }
    return runningDurationSeconds * metersPerSecond;
  }

  static double _calculateTotalDistance(List<TrainingDayModel> days) {
    return days.fold(
      0.0,
      (sum, day) =>
          sum +
          day.targetMetrics.targetDistance, // Both values are now in meters
    );
  }

  static int _calculateTotalTime(List<TrainingDayModel> days) {
    // Calculate from phases total duration in seconds
    return days.fold(0, (sum, day) => sum + day.totals.totalDuration);
  }

  /// Calculate session duration based on run phase, walk phase, and repetitions
  static int _calculateSessionDuration(
    int runPhaseTime,
    int walkPhaseTime,
    int repetitions,
  ) {
    // Warmup (5 min) + (run + walk) * repetitions + cooldown (5 min)
    // Return in seconds for consistency
    final durationMinutes =
        5 +
        ((runPhaseTime * repetitions) + (walkPhaseTime * (repetitions - 1))) +
        5;
    return durationMinutes * 60; // Convert to seconds
  }

  /// Calculate pace in min/km from speed in m/s or intensity
  static double _calculatePaceFromSpeed(double speedMps, String intensity) {
    if (speedMps > 0) {
      // Convert m/s to min/km
      final kmPerSecond = speedMps / 1000;
      final secondsPerKm = 1 / kmPerSecond;
      return secondsPerKm / 60; // Convert to minutes per km
    } else {
      // Estimate pace from intensity if speed not provided (in min/km)
      switch (intensity.toLowerCase()) {
        case 'easy':
          return 6.0; // 6 min/km (moderate easy pace)
        case 'moderate':
          return 5.0; // 5 min/km (moderate pace)
        case 'hard':
          return 4.0; // 4 min/km (fast pace)
        default:
          return 5.5; // Default pace
      }
    }
  }

  /// Generate session phases from week data
  static List<Map<String, dynamic>> _generateSessionPhasesFromWeekData(
    int runPhaseTime,
    int walkPhaseTime,
    int repetitions,
    String instructions,
    bool isRecovery,
  ) {
    List<Map<String, dynamic>> phases = [];

    // Add warmup phase
    phases.add({
      'phaseType': 'warmup',
      'duration': 5 * 60,
      'instruction': 'Walk and light stretching',
      'allowsRunning': false,
      'repetitions': 1,
    });

    // Create alternating run/walk pattern
    // Pattern: run → walk → run → walk → ... → run
    // Total: repetitions run phases, repetitions-1 walk phases
    for (int i = 0; i < repetitions; i++) {
      // Add run phase
      phases.add({
        'phaseType': 'run',
        'duration': runPhaseTime * 60, // Convert minutes to seconds
        'instruction':
            isRecovery
                ? 'Very easy recovery pace'
                : (instructions.isNotEmpty
                    ? instructions
                    : 'Easy pace running'),
        'allowsRunning': true,
      });

      // Add walk phase (except after the last run)
      if (i < repetitions - 1) {
        phases.add({
          'phaseType': 'walk',
          'duration': walkPhaseTime * 60, // Convert minutes to seconds
          'instruction': 'Recovery walk',
          'allowsRunning': false,
        });
      }
    }

    // Add cooldown phase
    phases.add({
      'phaseType': 'cooldown',
      'duration': 5 * 60,
      'instruction': 'Cool down walk',
      'allowsRunning': false,
    });

    return phases;
  }
}
