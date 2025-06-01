import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WorkoutPhaseIcons {
  static IconData getPhaseIcon(String? phaseType) {
    switch (phaseType?.toLowerCase()) {
      case 'run':
      case 'running':
        return LucideIcons.footprints;
      case 'walk':
      case 'walking':
        return LucideIcons.footprints;
      case 'warmup':
        return LucideIcons.flame;
      case 'cooldown':
        return LucideIcons.snowflake;
      case 'sprint':
        return LucideIcons.timer;
      default:
        return LucideIcons.activity;
    }
  }
}
