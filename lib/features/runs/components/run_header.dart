// lib/features/runs/components/run_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class RunHeader extends StatelessWidget {
  final RunModel run;

  const RunHeader({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.primary.withOpacity(0.1),
      child: Column(
        children: [
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(run.timestamp),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            DateFormat('HH:mm').format(run.timestamp),
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
