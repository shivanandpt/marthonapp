import 'package:flutter/material.dart';
import '../../controllers/user_profile_setup_controller.dart';
import '../basic_info_step.dart';
import '../personal_details_step.dart';
import '../training_pref_step.dart';
import '../health_info_step.dart';

class StepContent extends StatelessWidget {
  final UserProfileSetupController controller;

  const StepContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 600),
      child: _buildCurrentStep(controller),
    );
  }

  Widget _buildCurrentStep(UserProfileSetupController controller) {
    switch (controller.currentStep) {
      case 0:
        return BasicInfoStep(controller: controller);
      case 1:
        return PersonalDetailsStep(controller: controller);
      case 2:
        return TrainingPrefStep(controller: controller);
      case 3:
        return HealthInfoStep(controller: controller);
      default:
        return const SizedBox.shrink();
    }
  }
}
