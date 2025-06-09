import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class StepHeader extends StatelessWidget {
  final UserProfileSetupController controller;

  const StepHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step title
        Text(
          _getStepTitle(controller.currentStep),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),

        // Step description
        Text(
          _getStepDescription(controller.currentStep),
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Personal Details';
      case 2:
        return 'Training Preferences';
      case 3:
        return 'Health Information';
      default:
        return 'Setup Profile';
    }
  }

  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return 'Let\'s start with your basic information and running goals';
      case 1:
        return 'Tell us more about yourself for a personalized experience';
      case 2:
        return 'How often would you like to train?';
      case 3:
        return 'Help us create a safer training plan for you';
      default:
        return 'Complete your profile setup';
    }
  }
}
