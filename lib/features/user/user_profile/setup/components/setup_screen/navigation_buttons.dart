import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class NavigationButtons extends StatelessWidget {
  final UserProfileSetupController controller;
  final VoidCallback onNextOrFinish;

  const NavigationButtons({
    Key? key,
    required this.controller,
    required this.onNextOrFinish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        border: Border(
          top: BorderSide(color: AppColors.disabled.withOpacity(0.2), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Back button
              if (controller.currentStep > 0)
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: controller.previousStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.disabled.withOpacity(0.2),
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

              // Next/Finish button
              Expanded(
                flex: controller.currentStep > 0 ? 1 : 2,
                child: Container(
                  margin: EdgeInsets.only(
                    left: controller.currentStep > 0 ? 8 : 0,
                  ),
                  child: ElevatedButton(
                    onPressed:
                        controller.validateCurrentStep()
                            ? onNextOrFinish
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.disabled.withOpacity(
                        0.3,
                      ),
                    ),
                    child:
                        controller.isLoading
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              controller.currentStep < controller.totalSteps - 1
                                  ? 'Next'
                                  : 'Finish',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
