import 'package:flutter/material.dart';

class SetupStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SetupStepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (currentStep + 1) / totalSteps,
          backgroundColor: Colors.grey[300],
          color: Theme.of(context).colorScheme.primary,
          minHeight: 6,
        ),

        // Step counter
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
