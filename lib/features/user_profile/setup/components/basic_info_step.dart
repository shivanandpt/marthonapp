import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/features/user_profile/setup/controllers/user_profile_setup_controller.dart';
import 'package:marunthon_app/features/user_profile/setup/components/goal_selection_component.dart';

class BasicInfoStep extends StatelessWidget {
  final UserProfileSetupController controller;

  const BasicInfoStep({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      controller.profilePic.isNotEmpty
                          ? NetworkImage(controller.profilePic)
                          : null,
                  child:
                      controller.profilePic.isEmpty
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
          TextField(
            controller: TextEditingController(text: controller.name),
            decoration: InputDecoration(
              labelText: 'Name*',
              hintText: 'Your full name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (value) {
              controller.name = value;
              controller.updateUI();
            },
          ),
          SizedBox(height: 16),

          // Email field (read-only from Firebase)
          TextField(
            controller: TextEditingController(text: controller.email),
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.email),
              filled: true,
            ),
            readOnly: true,
            enabled: false,
          ),
          SizedBox(height: 32),

          // Running goal section
          Text(
            'Running Goal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
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
        ],
      ),
    );
  }
}
