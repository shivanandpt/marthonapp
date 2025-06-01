import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/models/run_model.dart';

class RunItem extends StatelessWidget {
  final RunModel run;

  const RunItem({Key? key, required this.run}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMM dd').format(run.timestamp);
    final time = DateFormat('h:mm a').format(run.timestamp);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.footprints, color: AppColors.secondary),
        ),
        title: Text(
          "${(run.distance / 1000).toStringAsFixed(2)} km",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("$date at $time"),
        trailing: Text(
          run.formattedDuration,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        onTap: () {
          // Navigate to run details
          context.push('/run/${run.id}');
        },
      ),
    );
  }
}
