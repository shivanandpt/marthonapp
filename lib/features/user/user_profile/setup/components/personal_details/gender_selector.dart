import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class GenderSelector extends StatelessWidget {
  final UserProfileSetupController controller;

  const GenderSelector({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.disabled.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.cardBg,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
                  controller.personalInfoController.gender?.isEmpty == true
                      ? null
                      : controller.personalInfoController.gender,
              hint: Text(
                'Select gender',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              style: TextStyle(color: AppColors.textPrimary),
              icon: Icon(
                LucideIcons.chevronDown,
                color: AppColors.textSecondary,
              ),
              items: [
                DropdownMenuItem(
                  value: 'male',
                  child: Text(
                    'Male',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text(
                    'Female',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text(
                    'Other',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                DropdownMenuItem(
                  value: 'prefer_not_to_say',
                  child: Text(
                    'Prefer not to say',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.personalInfoController.updateGender(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
