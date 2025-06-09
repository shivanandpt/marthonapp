import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class MetricSystemToggle extends StatelessWidget {
  final UserProfileSetupController controller;
  final VoidCallback? onMetricSystemChanged;

  const MetricSystemToggle({
    super.key,
    required this.controller,
    this.onMetricSystemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Measurement System',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.disabled.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.physicalAttributesController.updateMetricSystem(
                      'metric',
                    );
                    onMetricSystemChanged?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          controller
                                      .physicalAttributesController
                                      .metricSystem ==
                                  'metric'
                              ? AppColors.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11),
                        bottomLeft: Radius.circular(11),
                      ),
                    ),
                    child: Text(
                      'Metric (kg/cm)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            controller
                                        .physicalAttributesController
                                        .metricSystem ==
                                    'metric'
                                ? Colors.white
                                : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    controller.physicalAttributesController.updateMetricSystem(
                      'imperial',
                    );
                    onMetricSystemChanged?.call();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          controller
                                      .physicalAttributesController
                                      .metricSystem ==
                                  'imperial'
                              ? AppColors.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(11),
                        bottomRight: Radius.circular(11),
                      ),
                    ),
                    child: Text(
                      'Imperial (lbs/ft)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            controller
                                        .physicalAttributesController
                                        .metricSystem ==
                                    'imperial'
                                ? Colors.white
                                : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
