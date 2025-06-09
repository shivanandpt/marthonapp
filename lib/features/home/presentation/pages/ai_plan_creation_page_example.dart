import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_plan_creation_bloc.dart';
import '../components/ai_plan_preview.dart';
import '../../../user/user_profile/setup/models/user_model.dart';

class AIPlanCreationPageExample extends StatelessWidget {
  final UserModel user;

  const AIPlanCreationPageExample({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Training Plan Generation')),
      body: BlocProvider(
        create: (context) => AIPlanCreationBloc(),
        child: BlocBuilder<AIPlanCreationBloc, AIPlanCreationState>(
          builder: (context, state) {
            if (state is AIPlanCreationInitial) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AIPlanCreationBloc>().add(
                      GeneratePlanEvent(user),
                    );
                  },
                  child: const Text('Generate AI Training Plan'),
                ),
              );
            } else if (state is AIPlanCreationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AIPlanCreationGenerated) {
              return AIPlanPreview(
                trainingPlan: state.trainingPlan,
                trainingDays: state.trainingDays,
                user: user,
                onApprove: (plan, days) {
                  context.read<AIPlanCreationBloc>().add(
                    ApprovePlanEvent(plan, days),
                  );
                },
                onRegenerate: () {
                  context.read<AIPlanCreationBloc>().add(
                    GeneratePlanEvent(user),
                  );
                },
                onCancel: () {
                  context.read<AIPlanCreationBloc>().add(
                    const ResetCreationEvent(),
                  );
                },
              );
            } else if (state is AIPlanCreationSuccess) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Training Plan Created Successfully!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AIPlanCreationError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AIPlanCreationBloc>().add(
                          const ResetCreationEvent(),
                        );
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
