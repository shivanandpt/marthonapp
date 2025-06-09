import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/features/user/user_profile/setup/controllers/user_profile_setup_controller.dart';
import 'package:marunthon_app/features/user/user_profile/setup/components/goal_selection_component.dart';

class BasicInfoStep extends StatelessWidget {
  final UserProfileSetupController controller;

  const BasicInfoStep({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.basicInfoController,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture section
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          controller.basicInfoController.profilePic.isNotEmpty
                              ? NetworkImage(
                                controller.basicInfoController.profilePic,
                              )
                              : null,
                      child:
                          controller.basicInfoController.profilePic.isEmpty
                              ? Icon(LucideIcons.user, size: 50)
                              : null,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Profile from Google',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Basic information section
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 16),

              // Name field
              TextFormField(
                initialValue: controller.basicInfoController.name,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(),
                ),
                onChanged: controller.basicInfoController.updateName,
              ),
              SizedBox(height: 16),

              // Email field
              TextFormField(
                initialValue: controller.basicInfoController.email,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: controller.basicInfoController.updateEmail,
              ),
              SizedBox(height: 16),

              // Running goal section
              Text(
                'Running Goal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose your target distance for training',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),

              // Use the new goal selection component
              GoalSelectionComponent(
                controller: controller,
                showTitle: false, // Don't show title since we have one above
              ),
              SizedBox(height: 16),

              // Goal event date
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Goal Event Date',
                  hintText: 'Select target date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text:
                      controller.basicInfoController.goalEventDate != null
                          ? '${controller.basicInfoController.goalEventDate!.day}/${controller.basicInfoController.goalEventDate!.month}/${controller.basicInfoController.goalEventDate!.year}'
                          : '',
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate:
                        controller.basicInfoController.goalEventDate ??
                        DateTime.now().add(Duration(days: 70)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null) {
                    controller.basicInfoController.updateGoalEventDate(picked);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
