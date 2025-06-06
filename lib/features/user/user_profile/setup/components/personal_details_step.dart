import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../controllers/user_profile_setup_controller.dart';
import 'personal_details/date_of_birth_selector.dart';
import 'personal_details/gender_selector.dart';
import 'personal_details/language_selector.dart';
import 'personal_details/metric_system_toggle.dart';
import 'personal_details/height_weight_section.dart';

class PersonalDetailsStep extends StatefulWidget {
  final UserProfileSetupController controller;

  const PersonalDetailsStep({Key? key, required this.controller})
    : super(key: key);

  @override
  State<PersonalDetailsStep> createState() => _PersonalDetailsStepState();
}

class _PersonalDetailsStepState extends State<PersonalDetailsStep> {
  // Callback function to update hint texts
  VoidCallback? _updateHintTexts;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.controller.personalInfoController,
        widget.controller.physicalAttributesController,
      ]),
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date of Birth
              DateOfBirthSelector(controller: widget.controller),
              SizedBox(height: 24),

              // Gender Dropdown
              GenderSelector(controller: widget.controller),
              SizedBox(height: 24),

              // Language Selection
              LanguageSelector(controller: widget.controller),
              SizedBox(height: 24),

              // Metric System Toggle
              MetricSystemToggle(
                controller: widget.controller,
                onMetricSystemChanged: () {
                  // Update hint texts when metric system changes
                  _updateHintTexts?.call();
                },
              ),
              SizedBox(height: 24),

              // Height and Weight Section
              HeightWeightSection(
                controller: widget.controller,
                onUpdateHintTextsCallback: (updateFunction) {
                  _updateHintTexts = updateFunction;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
