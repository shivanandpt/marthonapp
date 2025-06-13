import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../controllers/user_profile_setup_controller.dart';

class SetupAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditMode;

  const SetupAppBar({super.key, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        isEditMode ? 'Edit Profile' : 'Setup Profile',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      actions: [
        Consumer<UserProfileSetupController>(
          builder: (context, controller, _) {
            // Only show Skip button if NOT on Basic Info page (step 0) and not in edit mode
            if (controller.currentStep > 0 && !isEditMode) {
              return TextButton(
                onPressed: () {
                  controller.skipToLastStep();
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
