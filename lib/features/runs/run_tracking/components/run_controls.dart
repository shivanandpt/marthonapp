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
    super.key,
    required this.status,
    required this.hasNextPhase,
    required this.hasPreviousPhase,
    required this.onPlayPause,
    required this.onEnd,
    this.onNextPhase,
    this.onPreviousPhase,
  });

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
              // Play/Pause button with integrated phase navigation
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isPaused ? AppColors.success : AppColors.warning,
                  ),
                  child: Row(
                    children: [
                      // Previous phase button (integrated, left side) - always shown when running
                      if (!isPaused) ...[
                        Expanded(
                          flex: 1,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: hasPreviousPhase ? onPreviousPhase : null,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Icon(
                                  LucideIcons.skipBack,
                                  color:
                                      hasPreviousPhase
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ],

                      // Main play/pause button
                      Expanded(
                        flex: 3,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onPlayPause,
                            borderRadius: BorderRadius.circular(
                              !isPaused ? 0 : 12,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isPaused
                                        ? LucideIcons.play
                                        : LucideIcons.pause,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    isPaused ? 'Resume' : 'Pause',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Next phase button (integrated, right side) - always shown when running
                      if (!isPaused) ...[
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Expanded(
                          flex: 1,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: hasNextPhase ? onNextPhase : null,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Icon(
                                  LucideIcons.skipForward,
                                  color:
                                      hasNextPhase
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
            ],
          ),

          // Phase navigation hint
          if (!isPaused) ...[
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
                    'Use << >> to navigate between phases while running',
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
