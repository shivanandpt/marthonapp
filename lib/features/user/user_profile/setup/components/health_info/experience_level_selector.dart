import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class ExperienceLevelSelector extends StatelessWidget {
  final UserProfileSetupController controller;

  const ExperienceLevelSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Running Experience Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Help us tailor your training plan to your experience level',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        SizedBox(height: 16),

        // Experience level selection
        AnimatedBuilder(
          animation: controller.healthInfoController,
          builder: (context, child) {
            return Column(
              children:
                  ['beginner', 'intermediate', 'advanced'].map((experience) {
                    final isSelected =
                        controller.healthInfoController.experience ==
                        experience;

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? AppColors.primary
                                  : AppColors.disabled.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        color:
                            isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.cardBg,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            controller.healthInfoController.updateExperience(
                              experience,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon based on experience level
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : AppColors.disabled.withOpacity(
                                              0.2,
                                            ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getExperienceIcon(experience),
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 16),

                                // Experience info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        experience
                                                .substring(0, 1)
                                                .toUpperCase() +
                                            experience.substring(1),
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _getExperienceDescription(experience),
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Selection indicator
                                Container(
                                  width: 24,
                                  height: 24,
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
                                        isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                  ),
                                  child:
                                      isSelected
                                          ? Icon(
                                            LucideIcons.check,
                                            size: 12,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  String _getExperienceDescription(String experience) {
    switch (experience) {
      case 'beginner':
        return 'New to running or getting back into it';
      case 'intermediate':
        return 'Run regularly, comfortable with 5K+';
      case 'advanced':
        return 'Experienced runner, completed races';
      default:
        return '';
    }
  }

  IconData _getExperienceIcon(String experience) {
    switch (experience) {
      case 'beginner':
        return LucideIcons.play;
      case 'intermediate':
        return LucideIcons.lineChart;
      case 'advanced':
        return LucideIcons.award;
      default:
        return LucideIcons.circle;
    }
  }
}
