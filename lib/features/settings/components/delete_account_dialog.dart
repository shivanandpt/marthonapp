import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const DeleteAccountDialog();
      },
    );
  }
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  int _currentStep = 0;
  bool _isConfirmed = false;
  final TextEditingController _confirmationController = TextEditingController();

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(LucideIcons.alertTriangle, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Text(
            'Delete Account',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: _buildStepContent(),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWarningStep();
      case 1:
        return _buildDataLossWarning();
      case 2:
        return _buildConfirmationStep();
      default:
        return _buildWarningStep();
    }
  }

  Widget _buildWarningStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This action cannot be undone!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Deleting your account will permanently remove:',
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        _buildWarningItem('Your profile and personal information'),
        _buildWarningItem('All your run history and statistics'),
        _buildWarningItem('Training plans and progress'),
        _buildWarningItem('Settings and preferences'),
        _buildWarningItem('Any associated data'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.info, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This will also sign you out of all devices',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataLossWarning() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Recovery Warning',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.database, color: AppColors.error, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your data cannot be recovered',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Once deleted, all your running data, achievements, and progress will be permanently lost. There is no way to restore this information.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Consider exporting your data first if you want to keep a record of your running history.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Final Confirmation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Type "DELETE" to confirm account deletion:',
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmationController,
          decoration: InputDecoration(
            hintText: 'Type DELETE here',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            prefixIcon: Icon(LucideIcons.type, color: AppColors.error),
          ),
          onChanged: (value) {
            setState(() {
              _isConfirmed = value.toUpperCase() == 'DELETE';
            });
          },
        ),
        const SizedBox(height: 16),
        if (!_isConfirmed)
          Text(
            'You must type "DELETE" exactly to continue',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.error.withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions() {
    switch (_currentStep) {
      case 0:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ];
      case 1:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentStep = 0;
              });
            },
            child: Text('Back', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 2;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('I Understand'),
          ),
        ];
      case 2:
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentStep = 1;
                _confirmationController.clear();
                _isConfirmed = false;
              });
            },
            child: Text('Back', style: TextStyle(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed:
                _isConfirmed ? () => Navigator.of(context).pop(true) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.disabled,
            ),
            child: const Text('Delete Account'),
          ),
        ];
      default:
        return [];
    }
  }
}
