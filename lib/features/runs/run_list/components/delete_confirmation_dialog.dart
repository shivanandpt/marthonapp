import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      title: Text('Delete Run', style: TextStyle(color: AppColors.textPrimary)),
      content: Text(
        'Are you sure you want to delete this run? This action cannot be undone.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const DeleteConfirmationDialog(),
    );
  }
}
