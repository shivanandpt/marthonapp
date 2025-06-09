import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/ai_plan_creation_bloc.dart';
import '../../../user/user_profile/setup/models/user_model.dart';
import '../../../user/user_profile/setup/services/user_service.dart';
import '../components/plan_creation_form.dart';
import '../components/ai_plan_preview.dart';

class PlanCreationScreen extends StatelessWidget {
  const PlanCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AIPlanCreationBloc(),
      child: const _PlanCreationScreenContent(),
    );
  }
}

class _PlanCreationScreenContent extends StatefulWidget {
  const _PlanCreationScreenContent();

  @override
  State<_PlanCreationScreenContent> createState() =>
      _PlanCreationScreenContentState();
}

class _PlanCreationScreenContentState
    extends State<_PlanCreationScreenContent> {
  UserModel? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userService = UserService();
        final user = await userService.getUserProfile(currentUser.uid);
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Custom Plan'),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      body:
          _isLoadingUser
              ? const Center(child: CircularProgressIndicator())
              : _currentUser == null
              ? const Center(child: Text('Unable to load user profile'))
              : BlocConsumer<AIPlanCreationBloc, AIPlanCreationState>(
                listener: (context, state) {
                  if (state is AIPlanCreationError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is AIPlanCreationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Training plan created successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop(); // Return to home
                  }
                },
                builder: (context, state) {
                  if (state is AIPlanCreationLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Generating your custom training plan...',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This may take a few moments',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AIPlanCreationGenerated) {
                    return AIPlanPreview(
                      trainingPlan: state.trainingPlan,
                      trainingDays: state.trainingDays,
                      user: _currentUser!,
                      onApprove: (plan, days) {
                        context.read<AIPlanCreationBloc>().add(
                          ApprovePlanEvent(plan, days),
                        );
                      },
                      onRegenerate: () {
                        if (_currentUser != null) {
                          context.read<AIPlanCreationBloc>().add(
                            GeneratePlanEvent(_currentUser!),
                          );
                        }
                      },
                      onCancel: () {
                        context.read<AIPlanCreationBloc>().add(
                          const ResetCreationEvent(),
                        );
                      },
                    );
                  }

                  // Default state - show form
                  return PlanCreationForm(
                    user: _currentUser!,
                    onCreatePlan: (user) {
                      context.read<AIPlanCreationBloc>().add(
                        GeneratePlanEvent(user),
                      );
                    },
                  );
                },
              ),
    );
  }
}
