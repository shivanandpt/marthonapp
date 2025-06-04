import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../setup/models/user_model.dart';
import 'profile_info_section.dart';
import 'profile_info_tile.dart';

class BasicInfoSection extends StatelessWidget {
  final UserModel user;

  const BasicInfoSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileInfoSection(
      title: 'Basic Information',
      children: [
        ProfileInfoTile(
          icon: LucideIcons.goal,
          title: 'Goal',
          value: user.goal,
        ),
        ProfileInfoTile(
          icon: LucideIcons.calendar,
          title: 'Age',
          value: '${user.age} years old',
        ),
        ProfileInfoTile(
          icon: LucideIcons.calendar,
          title: 'Date of Birth',
          value:
              user.dob != null
                  ? DateFormat('MMMM d, yyyy').format(user.dob!)
                  : 'Not set',
        ),
        if (user.goalEventDate != null)
          ProfileInfoTile(
            icon: LucideIcons.target,
            title: 'Goal Event Date',
            value: DateFormat('MMMM d, yyyy').format(user.goalEventDate!),
          ),
        ProfileInfoTile(
          icon: LucideIcons.languages,
          title: 'Language',
          value: user.language == 'en' ? 'English' : 'Spanish',
        ),
        if (user.timezone.isNotEmpty)
          ProfileInfoTile(
            icon: LucideIcons.globe,
            title: 'Timezone',
            value: user.timezone,
          ),
      ],
    );
  }
}
