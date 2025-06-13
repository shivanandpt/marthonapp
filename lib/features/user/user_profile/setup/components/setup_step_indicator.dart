import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class SetupStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const SetupStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.disabled.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Progress indicator with custom design
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.disabled.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (currentStep + 1) / totalSteps,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8,
              ),
            ),
          ),
          SizedBox(height: 16),

          // Step counter and progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${((currentStep + 1) / totalSteps * 100).round()}% Complete',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Circular step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isCompleted = index < currentStep;
              final isCurrent = index == currentStep;
              final isUpcoming = index > currentStep;

              return Expanded(
                child: Column(
                  children: [
                    // Step circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isCompleted || isCurrent
                                ? AppColors.primary
                                : AppColors.disabled.withOpacity(0.2),
                        border: Border.all(
                          color:
                              isCurrent
                                  ? AppColors.primary
                                  : isCompleted
                                  ? AppColors.primary
                                  : AppColors.disabled.withOpacity(0.3),
                          width: isCurrent ? 3 : 1,
                        ),
                        boxShadow:
                            isCurrent
                                ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                                : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color:
                                        isCurrent || isCompleted
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Step title (if provided)
                    if (stepTitles.isNotEmpty && index < stepTitles.length)
                      Text(
                        stepTitles[index],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isCurrent
                                  ? AppColors.primary
                                  : isCompleted
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Connecting line (except for last step)
                    if (index < totalSteps - 1)
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        height: 2,
                        color:
                            isCompleted
                                ? AppColors.primary
                                : AppColors.disabled.withOpacity(0.2),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
