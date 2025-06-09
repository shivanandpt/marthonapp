import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class LanguageSelector extends StatelessWidget {
  final UserProfileSetupController controller;

  const LanguageSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Language',
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
              value: controller.personalInfoController.language,
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              style: TextStyle(color: AppColors.textPrimary),
              icon: Icon(
                LucideIcons.chevronDown,
                color: AppColors.textSecondary,
              ),
              items:
                  ['English', 'Spanish'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.personalInfoController.updateLanguage(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
