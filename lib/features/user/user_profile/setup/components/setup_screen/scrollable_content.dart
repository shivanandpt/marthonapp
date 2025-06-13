import 'package:flutter/material.dart';
import '../../controllers/user_profile_setup_controller.dart';
import 'compact_step_indicator.dart';
import 'step_header.dart';
import 'step_content.dart';

class ScrollableContent extends StatelessWidget {
  final UserProfileSetupController controller;

  const ScrollableContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Compact step indicator (scrolls with content)
            CompactStepIndicator(controller: controller),
            SizedBox(height: 24),

            // Step header (title and description)
            StepHeader(controller: controller),
            SizedBox(height: 32),

            // Main content area
            StepContent(controller: controller),

            // Add some bottom padding for better scrolling
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
