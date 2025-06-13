import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class SkipStepButton extends StatelessWidget {
  final UserProfileSetupController controller;
  final VoidCallback? onSkip;

  const SkipStepButton({super.key, required this.controller, this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          // Clear injury notes and set default experience
          controller.healthInfoController.updateInjuryNotesWithNotify('');
          controller.healthInfoController.updateExperience('beginner');

          // Call additional skip callback if provided
          onSkip?.call();
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          'Skip this step',
          style: TextStyle(
            color: AppColors.textSecondary,
            decoration: TextDecoration.underline,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
