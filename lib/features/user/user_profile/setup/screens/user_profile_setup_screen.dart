import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/user_profile_setup_controller.dart';
import '../components/basic_info_step.dart';
import '../components/personal_details_step.dart';
import '../components/training_pref_step.dart';
import '../components/health_info_step.dart';

class UserProfileSetupScreen extends StatefulWidget {
  final bool isEditMode;

  const UserProfileSetupScreen({Key? key, this.isEditMode = false})
    : super(key: key);

  @override
  _UserProfileSetupScreenState createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  late UserProfileSetupController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserProfileSetupController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(isEditMode: widget.isEditMode);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditMode ? 'Edit Profile' : 'Setup Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Consumer<UserProfileSetupController>(
              builder: (context, controller, _) {
                // Only show Skip button if NOT on Basic Info page (step 0) and not in edit mode
                if (controller.currentStep > 0 && !widget.isEditMode) {
                  return TextButton(
                    onPressed: () {
                      controller.skipToLastStep();
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
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
        ),
        body: Consumer<UserProfileSetupController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading profile...'),
                  ],
                ),
              );
            }

            return SafeArea(
              child: Column(
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LinearProgressIndicator(
                      value:
                          (controller.currentStep + 1) / controller.totalSteps,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),

                  // Step title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      _getStepTitle(controller.currentStep),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Main content area
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          child: _buildCurrentStep(controller),
                        ),
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button
                        SizedBox(
                          width: 150,
                          child:
                              controller.currentStep > 0
                                  ? ElevatedButton(
                                    onPressed: controller.previousStep,
                                    child: Text('Back'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[300],
                                      foregroundColor: Colors.black87,
                                    ),
                                  )
                                  : SizedBox(),
                        ),

                        // Next/Finish button
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed:
                                controller.validateCurrentStep()
                                    ? () => _handleNextOrFinish(controller)
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child:
                                controller.isLoading
                                    ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      controller.currentStep <
                                              controller.totalSteps - 1
                                          ? 'Next'
                                          : 'Finish',
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStep(UserProfileSetupController controller) {
    switch (controller.currentStep) {
      case 0:
        return BasicInfoStep(controller: controller);
      case 1:
        return PersonalDetailsStep(controller: controller);
      case 2:
        return TrainingPrefStep(controller: controller);
      case 3:
        return HealthInfoStep(controller: controller);
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleNextOrFinish(UserProfileSetupController controller) async {
    if (controller.currentStep < controller.totalSteps - 1) {
      controller.nextStep();
    } else {
      final success = await controller.saveUserProfile();
      if (success) {
        if (controller.isEditMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
          context.pop();
        } else {
          context.go(
            '/setup-complete?name=${Uri.encodeComponent(controller.basicInfoController.name)}',
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile. Please try again.')),
        );
      }
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Personal Details';
      case 2:
        return 'Training Preferences';
      case 3:
        return 'Health Information';
      default:
        return 'Setup Profile';
    }
  }
}
