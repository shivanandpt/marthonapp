import '../../models/training_day_model.dart';
import 'training_day_core_service.dart';
import 'training_day_query_service.dart';

class TrainingDayStatisticsService {
  final TrainingDayCoreService _coreService;
  final TrainingDayQueryService _queryService;

  TrainingDayStatisticsService(this._coreService, this._queryService);

  // Get training day statistics for a plan
  Future<Map<String, dynamic>> getTrainingDayStats(String planId) async {
    try {
      final allDays = await _queryService.getTrainingDaysForPlan(planId);

      int totalDays = allDays.length;
      int completedDays = allDays.where((d) => d.completed).length;
      int skippedDays = allDays.where((d) => d.skipped).length;
      int lockedDays = allDays.where((d) => d.locked).length;
      int availableDays = allDays.where((d) => d.isAvailable).length;
      int restDays = allDays.where((d) => d.restDay).length;
      int workoutDays = allDays.where((d) => !d.restDay).length;

      // Calculate total planned metrics
      double totalPlannedDistance = 0;
      int totalPlannedDuration = 0;
      int totalPlannedCalories = 0;

      // Calculate actual metrics from completed days
      double totalActualDistance = 0;
      int totalActualDuration = 0;

      for (var day in allDays) {
        totalPlannedDistance += day.targetMetrics.targetDistance;
        totalPlannedDuration += day.totals.totalDuration;
        totalPlannedCalories += day.targetMetrics.targetCalories;

        if (day.completed && day.completionData.hasCompletionData) {
          final actualDistance = day.completionData.actualDistance;
          final actualDuration = day.completionData.actualDuration;
          
          if (actualDistance != null) {
            totalActualDistance += actualDistance;
          }
          if (actualDuration != null) {
            totalActualDuration += actualDuration;
          }
        }
      }

      // Group by session type
      Map<String, int> sessionTypeCount = {};
      for (var day in allDays) {
        sessionTypeCount[day.sessionType] =
            (sessionTypeCount[day.sessionType] ?? 0) + 1;
      }

      return {
        'totalDays': totalDays,
        'completedDays': completedDays,
        'skippedDays': skippedDays,
        'lockedDays': lockedDays,
        'availableDays': availableDays,
        'restDays': restDays,
        'workoutDays': workoutDays,
        'completionRate': totalDays > 0 ? (completedDays / totalDays) * 100 : 0,
        'totalPlannedDistance': totalPlannedDistance,
        'totalPlannedDuration': totalPlannedDuration,
        'totalPlannedCalories': totalPlannedCalories,
        'totalActualDistance': totalActualDistance,
        'totalActualDuration': totalActualDuration,
        'sessionTypeCount': sessionTypeCount,
        'days': allDays,
      };
    } catch (e) {
      print('Error getting training day stats: $e');
      return {};
    }
  }

  // Get weekly statistics
  Future<Map<String, dynamic>> getWeeklyStats(String planId, int week) async {
    try {
      final weekDays = await _queryService.getTrainingDaysForWeek(planId, week);

      int completedThisWeek = weekDays.where((d) => d.completed).length;
      int totalThisWeek = weekDays.length;
      double weeklyCompletionRate =
          totalThisWeek > 0 ? (completedThisWeek / totalThisWeek) * 100 : 0;

      // Calculate weekly metrics
      double weeklyPlannedDistance = 0;
      int weeklyPlannedDuration = 0;
      double weeklyActualDistance = 0;
      int weeklyActualDuration = 0;

      for (var day in weekDays) {
        weeklyPlannedDistance += day.targetMetrics.targetDistance;
        weeklyPlannedDuration += day.totals.totalDuration;

        if (day.completed && day.completionData.hasCompletionData) {
          final actualDistance = day.completionData.actualDistance;
          final actualDuration = day.completionData.actualDuration;
          
          if (actualDistance != null) {
            weeklyActualDistance += actualDistance;
          }
          if (actualDuration != null) {
            weeklyActualDuration += actualDuration;
          }
        }
      }

      return {
        'week': week,
        'totalDays': totalThisWeek,
        'completedDays': completedThisWeek,
        'completionRate': weeklyCompletionRate,
        'plannedDistance': weeklyPlannedDistance,
        'plannedDuration': weeklyPlannedDuration,
        'actualDistance': weeklyActualDistance,
        'actualDuration': weeklyActualDuration,
        'days': weekDays,
      };
    } catch (e) {
      print('Error getting weekly stats: $e');
      return {};
    }
  }

  // Get performance trends
  Future<Map<String, dynamic>> getPerformanceTrends(String planId) async {
    try {
      final allDays = await _queryService.getTrainingDaysForPlan(planId);
      final completedDays = allDays.where((d) => d.completed).toList();

      // Group by week for trend analysis
      Map<int, Map<String, dynamic>> weeklyTrends = {};

      for (var day in completedDays) {
        final week = day.week;
        if (!weeklyTrends.containsKey(week)) {
          weeklyTrends[week] = {
            'week': week,
            'completedDays': 0,
            'totalDistance': 0.0,
            'totalDuration': 0,
            'averagePace': 0.0,
          };
        }

        weeklyTrends[week]!['completedDays'] = 
            (weeklyTrends[week]!['completedDays'] as int) + 1;
            
        final actualDistance = day.completionData.actualDistance;
        final actualDuration = day.completionData.actualDuration;
        
        if (actualDistance != null) {
          weeklyTrends[week]!['totalDistance'] = 
              (weeklyTrends[week]!['totalDistance'] as double) + actualDistance;
        }
        if (actualDuration != null) {
          weeklyTrends[week]!['totalDuration'] = 
              (weeklyTrends[week]!['totalDuration'] as int) + actualDuration;
        }
      }

      // Calculate average pace for each week
      weeklyTrends.forEach((week, data) {
        final distance = data['totalDistance'] as double;
        final duration = data['totalDuration'] as int;
        if (distance > 0 && duration > 0) {
          // Pace in minutes per km
          data['averagePace'] = (duration / 60) / (distance / 1000);
        }
      });

      return {
        'weeklyTrends': weeklyTrends.values.toList(),
        'totalCompletedDays': completedDays.length,
        'overallCompletionRate':
            allDays.isNotEmpty
                ? (completedDays.length / allDays.length) * 100
                : 0,
      };
    } catch (e) {
      print('Error getting performance trends: $e');
      return {};
    }
  }

  // Get session type breakdown
  Future<Map<String, dynamic>> getSessionTypeBreakdown(String planId) async {
    try {
      final allDays = await _queryService.getTrainingDaysForPlan(planId);

      Map<String, Map<String, dynamic>> sessionStats = {};

      for (var day in allDays) {
        final sessionType = day.sessionType;
        if (!sessionStats.containsKey(sessionType)) {
          sessionStats[sessionType] = {
            'total': 0,
            'completed': 0,
            'skipped': 0,
            'planned': 0,
            'totalPlannedDistance': 0.0,
            'totalPlannedDuration': 0,
            'totalActualDistance': 0.0,
            'totalActualDuration': 0,
          };
        }

        final stats = sessionStats[sessionType]!;
        stats['total'] = (stats['total'] as int) + 1;
        
        if (day.completed) {
          stats['completed'] = (stats['completed'] as int) + 1;
        }
        if (day.skipped) {
          stats['skipped'] = (stats['skipped'] as int) + 1;
        }
        if (!day.completed && !day.skipped) {
          stats['planned'] = (stats['planned'] as int) + 1;
        }

        stats['totalPlannedDistance'] = 
            (stats['totalPlannedDistance'] as double) + day.targetMetrics.targetDistance;
        stats['totalPlannedDuration'] = 
            (stats['totalPlannedDuration'] as int) + day.totals.totalDuration;

        if (day.completed && day.completionData.hasCompletionData) {
          final actualDistance = day.completionData.actualDistance;
          final actualDuration = day.completionData.actualDuration;
          
          if (actualDistance != null) {
            stats['totalActualDistance'] = 
                (stats['totalActualDistance'] as double) + actualDistance;
          }
          if (actualDuration != null) {
            stats['totalActualDuration'] = 
                (stats['totalActualDuration'] as int) + actualDuration;
          }
        }
      }

      // Calculate completion rates for each session type
      sessionStats.forEach((type, stats) {
        final total = stats['total'] as int;
        final completed = stats['completed'] as int;
        stats['completionRate'] = total > 0 ? (completed / total) * 100 : 0.0;
      });

      return sessionStats;
    } catch (e) {
      print('Error getting session type breakdown: $e');
      return {};
    }
  }

  // Get upcoming schedule summary
  Future<Map<String, dynamic>> getUpcomingSchedule(
    String planId,
    int days,
  ) async {
    try {
      final now = DateTime.now();
      final upcomingDays = <TrainingDayModel>[];

      final allDays = await _queryService.getTrainingDaysForPlan(planId);

      for (var day in allDays) {
        // Safe access to dateScheduled
        final scheduledDate = day.scheduling.dateScheduled;
        
        if (scheduledDate.isAfter(now) &&
            scheduledDate.isBefore(now.add(Duration(days: days))) &&
            !day.completed &&
            !day.skipped) {
          upcomingDays.add(day);
        }
      }

      // Sort by date
      upcomingDays.sort((a, b) => 
          a.scheduling.dateScheduled.compareTo(b.scheduling.dateScheduled));

      // Group by session type
      Map<String, int> upcomingSessionTypes = {};
      double totalUpcomingDistance = 0;
      int totalUpcomingDuration = 0;

      for (var day in upcomingDays) {
        upcomingSessionTypes[day.sessionType] =
            (upcomingSessionTypes[day.sessionType] ?? 0) + 1;
        totalUpcomingDistance += day.targetMetrics.targetDistance;
        totalUpcomingDuration += day.totals.totalDuration;
      }

      return {
        'upcomingDays': upcomingDays,
        'totalUpcomingWorkouts': upcomingDays.length,
        'sessionTypeBreakdown': upcomingSessionTypes,
        'totalUpcomingDistance': totalUpcomingDistance,
        'totalUpcomingDuration': totalUpcomingDuration,
      };
    } catch (e) {
      print('Error getting upcoming schedule: $e');
      return {};
    }
  }

  // Get daily progress summary
  Future<Map<String, dynamic>> getDailyProgressSummary(String planId) async {
    try {
      final allDays = await _queryService.getTrainingDaysForPlan(planId);
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day);

      // Filter days for today
      final todaysDays = allDays.where((day) {
        final scheduledDate = day.scheduling.dateScheduled;
        final startOfScheduled = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
        );
        return startOfScheduled.isAtSameMomentAs(startOfToday);
      }).toList();

      // Calculate today's metrics
      int completedToday = todaysDays.where((d) => d.completed).length;
      int totalToday = todaysDays.length;
      double todayCompletionRate = 
          totalToday > 0 ? (completedToday / totalToday) * 100 : 0;

      return {
        'date': startOfToday,
        'totalWorkouts': totalToday,
        'completedWorkouts': completedToday,
        'completionRate': todayCompletionRate,
        'workouts': todaysDays,
      };
    } catch (e) {
      print('Error getting daily progress summary: $e');
      return {};
    }
  }

  // Get streak information
  Future<Map<String, dynamic>> getStreakInfo(String planId) async {
    try {
      final allDays = await _queryService.getTrainingDaysForPlan(planId);
      
      // Sort by date
      final sortedDays = allDays.toList()
        ..sort((a, b) => a.scheduling.dateScheduled.compareTo(b.scheduling.dateScheduled));

      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak = 0;
      DateTime? lastCompletedDate;

      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));

      for (var day in sortedDays.reversed) {
        final scheduledDate = day.scheduling.dateScheduled;
        final dayDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);

        if (day.completed) {
          tempStreak++;
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          
          // Calculate current streak (must be consecutive up to today or yesterday)
          if (lastCompletedDate == null) {
            final todayDate = DateTime(today.year, today.month, today.day);
            final yesterdayDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
            
            if (dayDate.isAtSameMomentAs(todayDate) || 
                dayDate.isAtSameMomentAs(yesterdayDate)) {
              currentStreak = tempStreak;
              lastCompletedDate = dayDate;
            }
          } else {
            // Check if this day is consecutive with the last completed day
            final expectedDate = lastCompletedDate!.subtract(Duration(days: 1));
            if (dayDate.isAtSameMomentAs(expectedDate)) {
              currentStreak = tempStreak;
              lastCompletedDate = dayDate;
            }
          }
        } else {
          tempStreak = 0;
          // If we haven't started counting current streak and this is a gap, stop
          if (lastCompletedDate == null) {
            break;
          }
        }
      }

      return {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastCompletedDate': lastCompletedDate,
      };
    } catch (e) {
      print('Error getting streak info: $e');
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'lastCompletedDate': null,
      };
    }
  }

  // Get monthly summary
  Future<Map<String, dynamic>> getMonthlySummary(String planId, DateTime month) async {
    try {
      final allDays = await _queryService.getTrainingDaysForPlan(planId);
      
      // Filter days for the specific month
      final monthlyDays = allDays.where((day) {
        final scheduledDate = day.scheduling.dateScheduled;
        return scheduledDate.year == month.year && 
               scheduledDate.month == month.month;
      }).toList();

      int completedThisMonth = monthlyDays.where((d) => d.completed).length;
      int totalThisMonth = monthlyDays.length;
      double monthlyCompletionRate = 
          totalThisMonth > 0 ? (completedThisMonth / totalThisMonth) * 100 : 0;

      // Calculate monthly metrics
      double monthlyPlannedDistance = 0;
      int monthlyPlannedDuration = 0;
      double monthlyActualDistance = 0;
      int monthlyActualDuration = 0;

      for (var day in monthlyDays) {
        monthlyPlannedDistance += day.targetMetrics.targetDistance;
        monthlyPlannedDuration += day.totals.totalDuration;

        if (day.completed && day.completionData.hasCompletionData) {
          final actualDistance = day.completionData.actualDistance;
          final actualDuration = day.completionData.actualDuration;
          
          if (actualDistance != null) {
            monthlyActualDistance += actualDistance;
          }
          if (actualDuration != null) {
            monthlyActualDuration += actualDuration;
          }
        }
      }

      return {
        'month': month,
        'totalDays': totalThisMonth,
        'completedDays': completedThisMonth,
        'completionRate': monthlyCompletionRate,
        'plannedDistance': monthlyPlannedDistance,
        'plannedDuration': monthlyPlannedDuration,
        'actualDistance': monthlyActualDistance,
        'actualDuration': monthlyActualDuration,
        'days': monthlyDays,
      };
    } catch (e) {
      print('Error getting monthly summary: $e');
      return {};
    }
  }
}
