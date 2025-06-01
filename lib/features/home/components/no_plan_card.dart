import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class NoPlanCard extends StatelessWidget {
  const NoPlanCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16),
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(LucideIcons.calendar, size: 48, color: AppColors.secondary),
            SizedBox(height: 16),
            Text(
              "No Active Training Plan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Create a personalized training plan to reach your running goals!",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to training plan creation
                context.push('/create-plan');
              },
              child: Text("Create Training Plan"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
