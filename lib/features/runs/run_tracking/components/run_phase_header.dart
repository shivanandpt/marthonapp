import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/models/run_phase_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RunPhaseHeader extends StatelessWidget {
  final RunPhaseModel currentPhase;
  final int currentPhaseIndex;
  final int totalPhases;
  final Duration phaseElapsedTime;
  final bool hasNextPhase;
  final bool hasPreviousPhase;
  final VoidCallback? onNextPhase;
  final VoidCallback? onPreviousPhase;

  const RunPhaseHeader({
    Key? key,
    required this.currentPhase,
    required this.currentPhaseIndex,
    required this.totalPhases,
    required this.phaseElapsedTime,
    required this.hasNextPhase,
    required this.hasPreviousPhase,
    this.onNextPhase,
    this.onPreviousPhase,
  }) : super(key: key);

  Color _getPhaseColor(RunPhaseType type) {
    switch (type) {
      case RunPhaseType.warmup:
        return AppColors.warning;
      case RunPhaseType.easyRun:
        return AppColors.success;
      case RunPhaseType.intervals:
        return AppColors.error;
      case RunPhaseType.recovery:
        return AppColors.info;
      case RunPhaseType.cooldown:
        return AppColors.secondary;
      case RunPhaseType.freeRun:
        return AppColors.primary;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final phaseColor = _getPhaseColor(currentPhase.type);
    final progress =
        currentPhase.targetDuration.inSeconds > 0
            ? (phaseElapsedTime.inSeconds /
                    currentPhase.targetDuration.inSeconds)
                .clamp(0.0, 1.0)
            : 0.0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phaseColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Phase indicator
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Phase ${currentPhaseIndex + 1} of $totalPhases',
                  style: TextStyle(
                    color: phaseColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Spacer(),
              if (hasPreviousPhase) ...[
                IconButton(
                  onPressed: onPreviousPhase,
                  icon: Icon(
                    LucideIcons.chevronLeft,
                    color: AppColors.textSecondary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    padding: EdgeInsets.all(8),
                  ),
                ),
                SizedBox(width: 8),
              ],
              if (hasNextPhase) ...[
                IconButton(
                  onPressed: onNextPhase,
                  icon: Icon(
                    LucideIcons.chevronRight,
                    color: AppColors.textSecondary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 16),

          // Phase name and target
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPhase.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      currentPhase.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(phaseElapsedTime),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: phaseColor,
                    ),
                  ),
                  Text(
                    'of ${_formatDuration(currentPhase.targetDuration)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: AppColors.background,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
              ),
            ),
          ),

          SizedBox(height: 12),

          // Instructions
          if (currentPhase.instructions.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.info, color: AppColors.info, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentPhase.instructions,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
