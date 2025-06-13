import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';

class RunCardHeader extends StatelessWidget {
  final RunModel run;

  const RunCardHeader({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'MMM dd, yyyy',
    ).format(run.startTime);
    final String formattedTime = DateFormat('HH:mm').format(run.startTime);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          formattedDate,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Row(
          children: [
            Icon(LucideIcons.clock, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              formattedTime,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }
}
