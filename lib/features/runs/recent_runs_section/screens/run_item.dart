import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/run_detail_page.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';

class RunItem extends StatelessWidget {
  final RunModel run;

  const RunItem({super.key, required this.run});

  void _navigateToRunDetail(BuildContext context) {
    // Navigate to run details using the route you have set up
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RunDetailPage(run: run)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM dd').format(run.startTime); // Use startTime
    final time = DateFormat('h:mm a').format(run.startTime);
    final distance = (run.totalDistance / 1000).toStringAsFixed(
      2,
    ); // Convert to km

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            LucideIcons.activity,
            color: AppColors.secondary,
            size: 20,
          ),
        ),
        title: Text(
          '$date • $distance km',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '$time • ${run.steps} steps',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              run.formattedDuration,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            Text(
              '${(run.avgSpeed * 3.6).toStringAsFixed(1)} km/h',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        onTap: () => _navigateToRunDetail(context),
      ),
    );
  }
}
