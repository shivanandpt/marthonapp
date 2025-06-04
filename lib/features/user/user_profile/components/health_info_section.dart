import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../setup/models/user_model.dart';
import 'profile_info_section.dart';
import 'profile_info_tile.dart';

class HealthInfoSection extends StatelessWidget {
  final UserModel user;

  const HealthInfoSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> healthTiles = [];

    // Weight
    if (user.weight > 0) {
      healthTiles.add(
        ProfileInfoTile(
          icon: LucideIcons.scale,
          title: 'Weight',
          value:
              '${user.weight} ${user.metricSystem == 'metric' ? 'kg' : 'lbs'}',
        ),
      );
    }

    // Height
    if (user.height > 0) {
      healthTiles.add(
        ProfileInfoTile(
          icon: LucideIcons.ruler,
          title: 'Height',
          value:
              '${user.height} ${user.metricSystem == 'metric' ? 'cm' : 'in'}',
        ),
      );
    }

    // Gender
    if (user.gender.isNotEmpty) {
      healthTiles.add(
        ProfileInfoTile(
          icon: LucideIcons.users,
          title: 'Gender',
          value:
              user.gender.substring(0, 1).toUpperCase() +
              user.gender.substring(1),
        ),
      );
    }

    // Injury notes
    if (user.injuryNotes.isNotEmpty) {
      healthTiles.add(
        ProfileInfoTile(
          icon: LucideIcons.stethoscope,
          title: 'Health Notes',
          value: user.injuryNotes,
        ),
      );
    }

    // Only show section if there are health tiles
    if (healthTiles.isEmpty) {
      return SizedBox.shrink();
    }

    return ProfileInfoSection(
      title: 'Health Information',
      children: healthTiles,
    );
  }
}
