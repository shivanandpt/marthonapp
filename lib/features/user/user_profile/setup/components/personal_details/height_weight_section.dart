import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class HeightWeightSection extends StatefulWidget {
  final UserProfileSetupController controller;
  final Function(VoidCallback)? onUpdateHintTextsCallback;

  const HeightWeightSection({
    Key? key,
    required this.controller,
    this.onUpdateHintTextsCallback,
  }) : super(key: key);

  @override
  State<HeightWeightSection> createState() => _HeightWeightSectionState();
}

class _HeightWeightSectionState extends State<HeightWeightSection> {
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    _heightController = TextEditingController(
      text:
          widget.controller.physicalAttributesController.height != null &&
                  widget.controller.physicalAttributesController.height! > 0
              ? widget.controller.physicalAttributesController.height.toString()
              : '',
    );
    _weightController = TextEditingController(
      text:
          widget.controller.physicalAttributesController.weight != null &&
                  widget.controller.physicalAttributesController.weight! > 0
              ? widget.controller.physicalAttributesController.weight.toString()
              : '',
    );

    // Provide update function to parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onUpdateHintTextsCallback?.call(updateHintTexts);
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Method to update hint texts when metric system changes
  void updateHintTexts() {
    setState(() {
      // This will trigger a rebuild with new hint texts
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Height
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Height (${widget.controller.physicalAttributesController.metricSystem == 'metric' ? 'cm' : 'ft'})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText:
                      widget
                                  .controller
                                  .physicalAttributesController
                                  .metricSystem ==
                              'metric'
                          ? '170'
                          : '5.8',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.disabled.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.disabled.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  fillColor: AppColors.cardBg,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final height =
                        widget
                                    .controller
                                    .physicalAttributesController
                                    .metricSystem ==
                                'metric'
                            ? int.tryParse(value)
                            : (double.tryParse(value)?.round());
                    widget.controller.physicalAttributesController.updateHeight(
                      height,
                    );
                  } else {
                    widget.controller.physicalAttributesController.updateHeight(
                      null,
                    );
                  }
                },
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        // Weight
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weight (${widget.controller.physicalAttributesController.metricSystem == 'metric' ? 'kg' : 'lbs'})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText:
                      widget
                                  .controller
                                  .physicalAttributesController
                                  .metricSystem ==
                              'metric'
                          ? '70'
                          : '150',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.disabled.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.disabled.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  fillColor: AppColors.cardBg,
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final weight = int.tryParse(value);
                    widget.controller.physicalAttributesController.updateWeight(
                      weight,
                    );
                  } else {
                    widget.controller.physicalAttributesController.updateWeight(
                      null,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
