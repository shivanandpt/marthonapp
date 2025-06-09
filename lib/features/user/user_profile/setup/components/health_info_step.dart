import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../controllers/user_profile_setup_controller.dart';
import 'health_info/experience_level_selector.dart';
import 'health_info/injury_notes_section.dart';
import 'health_info/health_info_card.dart';
import 'health_info/privacy_notice.dart';
import 'health_info/skip_step_button.dart';

class HealthInfoStep extends StatefulWidget {
  final UserProfileSetupController controller;

  const HealthInfoStep({super.key, required this.controller});

  @override
  State<HealthInfoStep> createState() => _HealthInfoStepState();
}

class _HealthInfoStepState extends State<HealthInfoStep> {
  // Callback function to clear injury notes
  VoidCallback? _clearInjuryNotes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Health Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This information helps us create a safer training plan for you (Optional)',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          SizedBox(height: 32),

          // Experience level section
          ExperienceLevelSelector(controller: widget.controller),
          SizedBox(height: 32),

          // Injury Notes Section
          InjuryNotesSection(
            controller: widget.controller,
            onClearCallback: (clearFunction) {
              _clearInjuryNotes = clearFunction;
            },
          ),
          SizedBox(height: 24),

          // Information cards
          HealthInfoCard(),
          SizedBox(height: 24),

          // Privacy notice
          PrivacyNotice(),
          SizedBox(height: 16),

          // Skip option
          SkipStepButton(
            controller: widget.controller,
            onSkip: () {
              // Clear injury notes using callback
              _clearInjuryNotes?.call();
            },
          ),
        ],
      ),
    );
  }
}
