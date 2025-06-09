import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'training_day_option.dart';
import '../../controllers/user_profile_setup_controller.dart';

class TrainingDaysSelector extends StatelessWidget {
  final UserProfileSetupController controller;

  const TrainingDaysSelector({super.key, required this.controller});

  static const List<Map<String, dynamic>> trainingDays = [
    {
      'value': 1,
      'title': '1 Day',
      'description': 'Light training - Perfect for beginners',
      'icon': Icons.looks_one,
      'detail': 'One focused session per week',
    },
    {
      'value': 2,
      'title': '2 Days',
      'description': 'Moderate training - Build consistency',
      'icon': Icons.looks_two,
      'detail': 'Two balanced sessions per week',
    },
    {
      'value': 3,
      'title': '3 Days',
      'description': 'Regular training - Optimal progress',
      'icon': Icons.looks_3,
      'detail': 'Three structured sessions per week',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          trainingDays.map((day) {
            final isSelected =
                controller.physicalAttributesController.runDaysPerWeek ==
                day['value'];
            return TrainingDayOption(
              day: day,
              isSelected: isSelected,
              controller: controller,
            );
          }).toList(),
    );
  }
}
