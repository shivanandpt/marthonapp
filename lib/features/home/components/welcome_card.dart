import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/models/user_model.dart';

class WelcomeCard extends StatelessWidget {
  final UserModel userModel;

  const WelcomeCard({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // User profile pic
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  userModel.profilePic.isNotEmpty
                      ? NetworkImage(userModel.profilePic)
                      : null,
              child:
                  userModel.profilePic.isEmpty
                      ? Icon(LucideIcons.user, size: 30)
                      : null,
            ),
            SizedBox(width: 16),
            // Welcome text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    userModel.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Goal: ${userModel.goal}",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Edit profile button
            IconButton(
              icon: Icon(LucideIcons.edit),
              onPressed: () {
                context.push('/profile-edit');
              },
            ),
          ],
        ),
      ),
    );
  }
}
