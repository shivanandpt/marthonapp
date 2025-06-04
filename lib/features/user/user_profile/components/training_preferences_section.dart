import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../setup/models/user_model.dart';
import 'profile_info_section.dart';
import 'profile_info_tile.dart';

class TrainingPreferencesSection extends StatelessWidget {
  final UserModel user;

  const TrainingPreferencesSection({Key? key, required this.user})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileInfoSection(
      title: 'Training Preferences',
      children: [
        ProfileInfoTile(
          icon: LucideIcons.ruler,
          title: 'Measurement System',
          value:
              user.metricSystem == 'metric'
                  ? 'Metric (km, kg, cm)'
                  : 'Imperial (miles, lbs, in)',
        ),
        ProfileInfoTile(
          icon: LucideIcons.calendar,
          title: 'Running Days per Week',
          value: '${user.runDaysPerWeek} days',
        ),
        if (user.experience.isNotEmpty)
          ProfileInfoTile(
            icon: LucideIcons.award,
            title: 'Experience Level',
            value:
                user.experience.substring(0, 1).toUpperCase() +
                user.experience.substring(1),
          ),
      ],
    );
  }
}
