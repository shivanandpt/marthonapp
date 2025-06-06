import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/runs/run_tracking/bloc/run_tracking_state.dart';
import 'package:lucide_icons/lucide_icons.dart';

class RunControls extends StatelessWidget {
  final RunStatus status;
  final bool hasNextPhase;
  final bool hasPreviousPhase;
  final VoidCallback onPlayPause;
  final VoidCallback onEnd;
  final VoidCallback? onNextPhase;
  final VoidCallback? onPreviousPhase;

  const RunControls({
    Key? key,
    required this.status,
    required this.hasNextPhase,
    required this.hasPreviousPhase,
    required this.onPlayPause,
    required this.onEnd,
    this.onNextPhase,
    this.onPreviousPhase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPaused = status == RunStatus.paused;

    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main controls row
          Row(
            children: [
              // Previous phase button
              if (hasPreviousPhase && isPaused) ...[
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: onPreviousPhase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary.withOpacity(0.2),
                      foregroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Icon(LucideIcons.skipBack, size: 20),
                  ),
                ),
                SizedBox(width: 12),
              ],

              // Play/Pause button
              Expanded(
                flex: isPaused ? 2 : 3,
                child: ElevatedButton(
                  onPressed: onPlayPause,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isPaused ? AppColors.success : AppColors.warning,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPaused ? LucideIcons.play : LucideIcons.pause,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        isPaused ? 'Resume' : 'Pause',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isPaused) ...[
                SizedBox(width: 12),
                // End button (only when paused)
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onEnd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.square, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'End',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Next phase button
              if (hasNextPhase && isPaused) ...[
                SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: onNextPhase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Icon(LucideIcons.skipForward, size: 20),
                  ),
                ),
              ],
            ],
          ),

          // Phase navigation hint
          if (isPaused && (hasNextPhase || hasPreviousPhase)) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.info, color: AppColors.info, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Use << >> to navigate between phases while paused',
                    style: TextStyle(fontSize: 11, color: AppColors.info),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
