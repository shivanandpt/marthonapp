import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'sort_option_enum.dart';

class SortUtils {
  static String getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return 'Date (Newest)';
      case SortOption.dateOldest:
        return 'Date (Oldest)';
      case SortOption.distanceLongest:
        return 'Distance (Longest)';
      case SortOption.distanceShortest:
        return 'Distance (Shortest)';
    }
  }

  static IconData getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return LucideIcons.calendar;
      case SortOption.dateOldest:
        return LucideIcons.calendar;
      case SortOption.distanceLongest:
        return LucideIcons.ruler;
      case SortOption.distanceShortest:
        return LucideIcons.ruler;
    }
  }

  static List<RunModel> getSortedRuns(
    List<RunModel> runs,
    SortOption sortOption,
  ) {
    List<RunModel> sortedRuns = List.from(runs);

    switch (sortOption) {
      case SortOption.dateNewest:
        sortedRuns.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case SortOption.dateOldest:
        sortedRuns.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case SortOption.distanceLongest:
        sortedRuns.sort((a, b) => b.distance.compareTo(a.distance));
        break;
      case SortOption.distanceShortest:
        sortedRuns.sort((a, b) => a.distance.compareTo(b.distance));
        break;
    }

    return sortedRuns;
  }
}
