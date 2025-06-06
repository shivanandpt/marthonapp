import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/run_tracking/screen/run_tracking_screen.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QuickStartMenu extends StatelessWidget {
  const QuickStartMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Start',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _QuickStartButton(
                  icon: LucideIcons.play,
                  label: 'Free Run',
                  color: AppColors.primary,
                  onTap: () => _startFreeRun(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickStartButton(
                  icon: LucideIcons.target,
                  label: 'Interval Run',
                  color: AppColors.secondary,
                  onTap: () => _startIntervalRun(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickStartButton(
                  icon: LucideIcons.clock,
                  label: 'Easy Run',
                  color: AppColors.accent,
                  onTap: () => _startEasyRun(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickStartButton(
                  icon: LucideIcons.activity,
                  label: 'Recovery Run',
                  color: Colors.green,
                  onTap: () => _startRecoveryRun(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _startFreeRun(BuildContext context) {
    final phases = [
      RunPhaseModel(
        id: 'freerun',
        type: RunPhaseType.freeRun,
        name: 'Free Run',
        targetDuration: const Duration(minutes: 30),
        description: 'Run at your own pace',
        instructions: 'Maintain a comfortable pace throughout',
      ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RunTrackingScreen(phases: phases),
      ),
    );
  }

  void _startIntervalRun(BuildContext context) {
    final phases = [
      RunPhaseModel(
        id: 'warmup',
        type: RunPhaseType.warmup,
        name: 'Warm Up',
        targetDuration: const Duration(minutes: 10),
        description: 'Easy pace warm up',
        instructions: 'Start with an easy, comfortable pace',
      ),
      RunPhaseModel(
        id: 'interval1',
        type: RunPhaseType.intervals,
        name: 'High Intensity Interval',
        targetDuration: const Duration(minutes: 2),
        description: 'Fast pace interval',
        instructions: 'Run at 85-90% effort',
      ),
      RunPhaseModel(
        id: 'recovery1',
        type: RunPhaseType.recovery,
        name: 'Active Recovery',
        targetDuration: const Duration(minutes: 2),
        description: 'Easy recovery pace',
        instructions: 'Slow down to recover between intervals',
      ),
      RunPhaseModel(
        id: 'interval2',
        type: RunPhaseType.intervals,
        name: 'High Intensity Interval',
        targetDuration: const Duration(minutes: 2),
        description: 'Fast pace interval',
        instructions: 'Run at 85-90% effort',
      ),
      RunPhaseModel(
        id: 'recovery2',
        type: RunPhaseType.recovery,
        name: 'Active Recovery',
        targetDuration: const Duration(minutes: 2),
        description: 'Easy recovery pace',
        instructions: 'Slow down to recover between intervals',
      ),
      RunPhaseModel(
        id: 'interval3',
        type: RunPhaseType.intervals,
        name: 'High Intensity Interval',
        targetDuration: const Duration(minutes: 2),
        description: 'Fast pace interval',
        instructions: 'Run at 85-90% effort',
      ),
      RunPhaseModel(
        id: 'recovery3',
        type: RunPhaseType.recovery,
        name: 'Active Recovery',
        targetDuration: const Duration(minutes: 2),
        description: 'Easy recovery pace',
        instructions: 'Slow down to recover between intervals',
      ),
      RunPhaseModel(
        id: 'cooldown',
        type: RunPhaseType.cooldown,
        name: 'Cool Down',
        targetDuration: const Duration(minutes: 10),
        description: 'Easy cool down',
        instructions: 'Slow, easy pace to finish',
      ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RunTrackingScreen(phases: phases),
      ),
    );
  }

  void _startEasyRun(BuildContext context) {
    final phases = [
      RunPhaseModel(
        id: 'warmup',
        type: RunPhaseType.warmup,
        name: 'Warm Up',
        targetDuration: const Duration(minutes: 5),
        description: 'Gentle warm up',
        instructions: 'Start slowly and gradually increase pace',
      ),
      RunPhaseModel(
        id: 'easyrun',
        type: RunPhaseType.easyRun,
        name: 'Easy Run',
        targetDuration: const Duration(minutes: 25),
        description: 'Comfortable aerobic pace',
        instructions:
            'Maintain conversational pace - you should be able to talk',
      ),
      RunPhaseModel(
        id: 'cooldown',
        type: RunPhaseType.cooldown,
        name: 'Cool Down',
        targetDuration: const Duration(minutes: 5),
        description: 'Easy cool down',
        instructions: 'Slow, easy pace to finish',
      ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RunTrackingScreen(phases: phases),
      ),
    );
  }

  void _startRecoveryRun(BuildContext context) {
    final phases = [
      RunPhaseModel(
        id: 'warmup',
        type: RunPhaseType.warmup,
        name: 'Gentle Warm Up',
        targetDuration: const Duration(minutes: 5),
        description: 'Very easy warm up',
        instructions: 'Start very slowly',
      ),
      RunPhaseModel(
        id: 'recovery',
        type: RunPhaseType.recovery,
        name: 'Recovery Run',
        targetDuration: const Duration(minutes: 20),
        description: 'Very easy recovery pace',
        instructions:
            'Run at a very comfortable, relaxed pace for active recovery',
      ),
      RunPhaseModel(
        id: 'cooldown',
        type: RunPhaseType.cooldown,
        name: 'Cool Down',
        targetDuration: const Duration(minutes: 5),
        description: 'Easy cool down',
        instructions: 'Finish with very easy pace',
      ),
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RunTrackingScreen(phases: phases),
      ),
    );
  }
}

class _QuickStartButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickStartButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
