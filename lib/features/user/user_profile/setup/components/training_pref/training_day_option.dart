import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class TrainingDayOption extends StatelessWidget {
  final Map<String, dynamic> day;
  final bool isSelected;
  final UserProfileSetupController controller;

  const TrainingDayOption({
    super.key,
    required this.day,
    required this.isSelected,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: isSelected ? 6 : 2,
        borderRadius: BorderRadius.circular(16),
        shadowColor:
            isSelected
                ? AppColors.primary.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.disabled.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            gradient:
                isSelected
                    ? LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        AppColors.primary.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                    : null,
          ),
          child: InkWell(
            onTap: () {
              controller.physicalAttributesController.updateRunDaysPerWeek(
                day['value'],
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Day icon
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.disabled.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(
                      day['icon'],
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),

                  // Day info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day['title'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          day['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          day['detail'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection indicator
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                        width: 2,
                      ),
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                    ),
                    child:
                        isSelected
                            ? Icon(
                              LucideIcons.check,
                              size: 16,
                              color: Colors.white,
                            )
                            : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
