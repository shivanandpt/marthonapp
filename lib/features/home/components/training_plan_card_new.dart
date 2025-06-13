import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_plan_model.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';

class TrainingPlanCard extends StatefulWidget {
  final TrainingPlanModel activePlan;
  final List<TrainingDayModel> allTrainingDays;
  final int daysCompleted;
  final int totalDays;
  final int currentWeek;
  final int totalWeeks;
  final TrainingDayModel? todaysTraining;
  final List<TrainingDayModel> upcomingDays;
  final Function(TrainingDayModel)? onStartWorkout;

  const TrainingPlanCard({
    super.key,
    required this.activePlan,
    required this.allTrainingDays,
    required this.daysCompleted,
    required this.totalDays,
    required this.currentWeek,
    required this.totalWeeks,
    this.todaysTraining,
    this.upcomingDays = const [],
    this.onStartWorkout,
  });

  @override
  State<TrainingPlanCard> createState() => _TrainingPlanCardState();
}

class _TrainingPlanCardState extends State<TrainingPlanCard> {
  late PageController _pageController;
  int _currentDayIndex = 0;
  late List<TrainingDayModel> _allDays;

  @override
  void initState() {
    super.initState();
    _setupDays();
    _pageController = PageController(initialPage: _currentDayIndex);
  }

  void _setupDays() {
    _allDays = [];

    print('TrainingPlanCard _setupDays:');
    print('  Total training days from bloc: ${widget.allTrainingDays.length}');
    print(
      '  Today\'s training: ${widget.todaysTraining != null ? 'Available' : 'Not available'}',
    );
    print('  Upcoming days: ${widget.upcomingDays.length}');

    // Use allTrainingDays for a more comprehensive view
    if (widget.allTrainingDays.isNotEmpty) {
      // Sort all training days by date
      final sortedTrainingDays =
          widget.allTrainingDays.toList()..sort(
            (a, b) => a.scheduling.dateScheduled.compareTo(
              b.scheduling.dateScheduled,
            ),
          );

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Find today's index in the sorted list
      int todayIndex = -1;
      for (int i = 0; i < sortedTrainingDays.length; i++) {
        final dayDate = DateTime(
          sortedTrainingDays[i].scheduling.dateScheduled.year,
          sortedTrainingDays[i].scheduling.dateScheduled.month,
          sortedTrainingDays[i].scheduling.dateScheduled.day,
        );
        if (dayDate.isAtSameMomentAs(todayDate)) {
          todayIndex = i;
          break;
        }
      }

      if (todayIndex != -1) {
        // Show a window around today: 2 days before, today, and 4 days after (7 total)
        final startIndex = (todayIndex - 2).clamp(
          0,
          sortedTrainingDays.length - 1,
        );
        final endIndex = (todayIndex + 5).clamp(0, sortedTrainingDays.length);

        _allDays = sortedTrainingDays.sublist(startIndex, endIndex);
        _currentDayIndex = (todayIndex - startIndex).clamp(
          0,
          _allDays.length - 1,
        );

        print(
          'Using comprehensive view: ${_allDays.length} days starting from index $startIndex',
        );
        print('Today is at display index: $_currentDayIndex');
      } else {
        // If no today's training found, show upcoming days
        final futureDays =
            sortedTrainingDays
                .where((day) {
                  final dayDate = DateTime(
                    day.scheduling.dateScheduled.year,
                    day.scheduling.dateScheduled.month,
                    day.scheduling.dateScheduled.day,
                  );
                  return dayDate.isAfter(todayDate) ||
                      dayDate.isAtSameMomentAs(todayDate);
                })
                .take(7)
                .toList();

        _allDays = futureDays;
        _currentDayIndex = 0;

        print(
          'No today\'s training found, showing ${_allDays.length} upcoming days',
        );
      }
    } else {
      // Fallback to the original approach if allTrainingDays is empty
      print(
        'allTrainingDays is empty, falling back to todaysTraining and upcomingDays',
      );

      if (widget.todaysTraining != null) {
        _allDays.add(widget.todaysTraining!);
        print(
          'Added today\'s training: ${widget.todaysTraining!.identification.sessionType}',
        );
      }

      _allDays.addAll(widget.upcomingDays.take(6));
      print('Added ${widget.upcomingDays.length} upcoming training days');
      _currentDayIndex = 0;
    }

    print('Total training days for display: ${_allDays.length}');
    print('Starting at index: $_currentDayIndex');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 5K Goal type outside the card
        Text(
          widget.activePlan.goalType,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8), // Reduced space after goal
        // Training Card - same structure as welcome card
        Card(
          color: AppColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Column(
            children: [
              // Workout Carousel
              if (_allDays.isNotEmpty) ...[
                SizedBox(
                  height: 500, // Increased height to make card bigger
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentDayIndex = index;
                      });
                    },
                    itemCount: _allDays.length,
                    itemBuilder: (context, index) {
                      final day = _allDays[index];
                      final today = DateTime.now();
                      final todayDate = DateTime(
                        today.year,
                        today.month,
                        today.day,
                      );
                      final dayDate = DateTime(
                        day.scheduling.dateScheduled.year,
                        day.scheduling.dateScheduled.month,
                        day.scheduling.dateScheduled.day,
                      );
                      final isToday = dayDate.isAtSameMomentAs(todayDate);

                      return _buildWorkoutDay(day, isToday);
                    },
                  ),
                ),
              ] else ...[
                // Fallback UI when no training days are available
                Container(
                  height: 500, // Match the expanded workout display height
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Training Sessions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Training days will appear here once your plan is loaded',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Debug: All training days: ${widget.allTrainingDays.length}\n'
                        'Today\'s training: ${widget.todaysTraining != null ? 'Available' : 'Not available'}\n'
                        'Upcoming days: ${widget.upcomingDays.length}\n'
                        'Currently displaying: ${_allDays.length} days',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutDay(TrainingDayModel day, bool isToday) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // Match welcome card padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session type and Today badge on same line (no goal type here)
          Row(
            children: [
              Expanded(
                child: Text(
                  day.identification.sessionType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Week ${day.identification.week}, Day ${day.identification.dayOfWeek}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              if (day.status.completed)
                Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 12),

          // Duration and distance
          Row(
            children: [
              Icon(LucideIcons.clock, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${day.totals.totalDuration ~/ 60} min',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              Icon(
                LucideIcons.mapPin,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${(day.targetMetrics.targetDistance / 1000).toStringAsFixed(1)} km',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Phases preview
          Text(
            'Workout Phases:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Phases list
          ...day.runPhases.take(3).map((phase) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getPhaseColor(phase.phase),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${phase.phase.toUpperCase()}: ${phase.duration ~/ 60}min',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          if (day.runPhases.length > 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '+${day.runPhases.length - 3} more phases',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(
            height: 24,
          ), // Added more space before start workout button
          // Start button (inside the box outline)
          if (isToday && !day.status.completed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onStartWorkout?.call(day),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.play, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Start Workout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (day.status.completed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Day indicators inside the box (bigger for touch) - scrollable to prevent overflow
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_allDays.length, (index) {
                final day = _allDays[index];
                final isSelected = index == _currentDayIndex;
                final today = DateTime.now();
                final todayDate = DateTime(today.year, today.month, today.day);
                final dayDate = DateTime(
                  day.scheduling.dateScheduled.year,
                  day.scheduling.dateScheduled.month,
                  day.scheduling.dateScheduled.day,
                );
                final isToday = dayDate.isAtSameMomentAs(todayDate);

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isSelected ? 48 : 40, // Keep bigger size
                          height: isSelected ? 48 : 40, // Keep bigger size
                          decoration: BoxDecoration(
                            color:
                                isToday
                                    ? AppColors.primary
                                    : isSelected
                                    ? AppColors.primary.withOpacity(0.7)
                                    : Colors.grey[300],
                            shape: BoxShape.circle,
                            border:
                                day.status.completed
                                    ? Border.all(color: Colors.green, width: 2)
                                    : null,
                          ),
                          child: Center(
                            child:
                                day.status.completed
                                    ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    ) // Keep bigger icon
                                    : Text(
                                      (index + 1)
                                          .toString(), // Show consecutive numbers 1, 2, 3...
                                      style: TextStyle(
                                        color:
                                            isToday || isSelected
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16, // Keep bigger text
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isToday ? 'Today' : 'W${day.identification.week}',
                          style: TextStyle(
                            fontSize: 12, // Keep bigger text
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                            fontWeight:
                                isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'warmup':
        return Colors.orange;
      case 'run':
        return AppColors.primary;
      case 'walk':
        return Colors.blue;
      case 'cooldown':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
