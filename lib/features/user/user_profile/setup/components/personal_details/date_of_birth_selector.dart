import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class DateOfBirthSelector extends StatelessWidget {
  final UserProfileSetupController controller;

  const DateOfBirthSelector({Key? key, required this.controller})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.disabled.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            color: AppColors.cardBg,
          ),
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    controller.personalInfoController.dob ??
                    DateTime.now().subtract(Duration(days: 365 * 25)),
                firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
                lastDate: DateTime.now().subtract(Duration(days: 365 * 13)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: AppColors.primary,
                        surface: AppColors.cardBg,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                controller.personalInfoController.updateDob(date);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.personalInfoController.dob != null
                      ? '${controller.personalInfoController.dob!.day}/${controller.personalInfoController.dob!.month}/${controller.personalInfoController.dob!.year}'
                      : 'Select date of birth',
                  style: TextStyle(
                    color:
                        controller.personalInfoController.dob != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                Icon(LucideIcons.calendar, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),

        // Age display (calculated from DOB)
        if (controller.personalInfoController.dob != null) ...[
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.cake, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Age: ${controller.personalInfoController.calculatedAge} years old',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
