import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/core/widgets/app_button.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class NoUserView extends StatelessWidget {
  const NoUserView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle, size: 80, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text(
            "Profile Setup Required",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Please set up your profile to continue",
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          AppButton(
            onPressed: () {
              context.go('/profile-setup');
            },
            text: "Set Up Profile",
          ),
        ],
      ),
    );
  }
}
