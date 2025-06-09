import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../../controllers/user_profile_setup_controller.dart';

class InjuryNotesSection extends StatefulWidget {
  final UserProfileSetupController controller;
  final Function(VoidCallback)? onClearCallback;

  const InjuryNotesSection({
    super.key,
    required this.controller,
    this.onClearCallback,
  });

  @override
  State<InjuryNotesSection> createState() => _InjuryNotesSectionState();
}

class _InjuryNotesSectionState extends State<InjuryNotesSection> {
  late TextEditingController _injuryNotesController;

  @override
  void initState() {
    super.initState();
    // Initialize with current value
    _injuryNotesController = TextEditingController(
      text: widget.controller.healthInfoController.injuryNotes ?? '',
    );

    // Add listener to update controller when text changes
    _injuryNotesController.addListener(() {
      widget.controller.healthInfoController.updateInjuryNotesWithNotify(
        _injuryNotesController.text,
      );
    });

    // Provide clear function to parent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onClearCallback?.call(clearNotes);
    });
  }

  @override
  void dispose() {
    _injuryNotesController.dispose();
    super.dispose();
  }

  void clearNotes() {
    _injuryNotesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Injury History & Medical Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tell us about any injuries, medical conditions, or physical limitations we should consider',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        SizedBox(height: 16),

        // Injury Notes Text Field
        TextField(
          controller: _injuryNotesController,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText:
                'e.g., Previous knee injury, asthma, heart condition, etc.',
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
