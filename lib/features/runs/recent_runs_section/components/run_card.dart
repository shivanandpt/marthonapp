import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'run_card_header.dart';
import 'run_stats_section.dart';

class RunCard extends StatelessWidget {
  final RunModel run;
  final VoidCallback onTap;

  const RunCard({Key? key, required this.run, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'run-${run.id}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          color: AppColors.cardBg,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with date and time
                  RunCardHeader(run: run),
                  const SizedBox(height: 12),

                  // Stats section
                  RunStatsSection(run: run),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
