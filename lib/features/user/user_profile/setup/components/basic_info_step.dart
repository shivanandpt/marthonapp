import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/user/user_profile/setup/controllers/user_profile_setup_controller.dart';
import 'package:marunthon_app/features/user/user_profile/setup/components/goal_selection_component.dart';

class BasicInfoStep extends StatelessWidget {
  final UserProfileSetupController controller;

  const BasicInfoStep({super.key, required this.controller});

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
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            controller.basicInfoController.profilePic.isNotEmpty
                                ? NetworkImage(
                                  controller.basicInfoController.profilePic,
                                )
                                : null,
                        child:
                            controller.basicInfoController.profilePic.isEmpty
                                ? Icon(
                                  LucideIcons.user,
                                  size: 50,
                                  color: Colors.grey[400],
                                )
                                : null,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      controller.basicInfoController.profilePic.isNotEmpty
                          ? 'Profile picture set'
                          : 'No profile picture',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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

              // Email field (read-only)
              TextFormField(
                controller: TextEditingController(
                  text: controller.basicInfoController.email,
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Your email address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.disabled.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.disabled.withOpacity(0.3),
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.disabled.withOpacity(0.2),
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.disabled,
                  ),
                  filled: true,
                  fillColor: AppColors.disabled.withOpacity(0.1),
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: TextStyle(color: AppColors.textSecondary),
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
                enabled: false,
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
