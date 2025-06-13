import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marunthon_app/features/runs/models/run_model.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/features/runs/run_detail/screens/run_detail_screen.dart';
import 'run_card_utils.dart';
import 'run_card_stat_item.dart';
import 'delete_confirmation_dialog.dart';

class RunCard extends StatelessWidget {
  final RunModel run;
  final Function(String runId) onDelete;

  const RunCard({super.key, required this.run, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(run.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      confirmDismiss: (direction) => DeleteConfirmationDialog.show(context),
      onDismissed: (direction) {
        onDelete(run.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Run deleted'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () => _navigateToRunDetail(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [_buildHeader(), SizedBox(height: 16), _buildStats()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 24),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.trash2, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.footprints,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(run.timestamp),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                DateFormat('h:mm a').format(run.timestamp),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Icon(
          LucideIcons.chevronRight,
          color: AppColors.textSecondary,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: RunCardStatItem(
            icon: LucideIcons.map,
            label: "Distance",
            value: "${run.distance.toStringAsFixed(2)} km",
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: RunCardStatItem(
            icon: LucideIcons.clock,
            label: "Duration",
            value: RunCardUtils.formatDuration(run.duration),
            color: AppColors.secondary,
          ),
        ),
        Expanded(
          child: RunCardStatItem(
            icon: LucideIcons.zap,
            label: "Pace",
            value: "${RunCardUtils.formatPace(run.distance, run.duration)}/km",
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  void _navigateToRunDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RunDetailScreen(run: run)),
    );
  }
}
