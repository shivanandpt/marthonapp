import 'package:flutter/material.dart';
import '../controllers/user_profile_setup_controller.dart';
import 'training_pref/training_frequency_header.dart';
import 'training_pref/training_days_selector.dart';
import 'training_pref/training_tips_card.dart';
import 'training_pref/customization_notice.dart';

class TrainingPrefStep extends StatelessWidget {
  final UserProfileSetupController controller;

  const TrainingPrefStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.physicalAttributesController,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              TrainingFrequencyHeader(),
              SizedBox(height: 24),

              // Training days selection
              TrainingDaysSelector(controller: controller),
              SizedBox(height: 24),

              // Training tips card
              TrainingTipsCard(),
              SizedBox(height: 16),

              // Customization notice
              CustomizationNotice(),
            ],
          ),
        );
      },
    );
  }
}
