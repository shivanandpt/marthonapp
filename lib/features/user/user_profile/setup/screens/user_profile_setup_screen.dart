import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/user_profile_setup_controller.dart';
import '../components/setup_screen/setup_app_bar.dart';
import '../components/setup_screen/loading_indicator.dart';
import '../components/setup_screen/scrollable_content.dart';
import '../components/setup_screen/navigation_buttons.dart';

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
        backgroundColor: AppColors.background,
        appBar: SetupAppBar(isEditMode: widget.isEditMode),
        body: Consumer<UserProfileSetupController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return LoadingIndicator();
            }

            return Column(
              children: [
                // Main scrollable content
                ScrollableContent(controller: controller),

                // Fixed navigation buttons at bottom
                NavigationButtons(
                  controller: controller,
                  onNextOrFinish: () => _handleNextOrFinish(controller),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleNextOrFinish(UserProfileSetupController controller) async {
    if (controller.currentStep < controller.totalSteps - 1) {
      controller.nextStep();
    } else {
      final success = await controller.saveUserProfile();
      if (success) {
        if (widget.isEditMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else {
          context.go(
            '/setup-complete?name=${Uri.encodeComponent(controller.basicInfoController.name)}',
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
