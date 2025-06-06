import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/run_tracking/screen/run_tracking_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StartRunFAB extends StatelessWidget {
  const StartRunFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ElevatedButton.icon(
        onPressed: () => _startFreeRun(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 8,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(LucideIcons.play, size: 24),
        label: const Text(
          'Start Free Run',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _startFreeRun(BuildContext context) {
    // Always start a free run - no need to check for training plan
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RunTrackingScreen()));
  }
}
