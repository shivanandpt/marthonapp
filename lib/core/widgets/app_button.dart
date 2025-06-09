import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Made nullable to handle disabled state
  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledBackgroundColor;
  final Color? disabledTextColor;
  final double? width;
  final double height;
  final bool isLoading;
  final bool enabled; // Add explicit enabled property

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.disabledBackgroundColor,
    this.disabledTextColor,
    this.width = 200, // Default consistent width
    this.height = 48, // Default consistent height
    this.isLoading = false,
    this.enabled = true, // Default to enabled
  });

  @override
  Widget build(BuildContext context) {
    // Determine if button should be disabled
    final bool isDisabled = !enabled || onPressed == null || isLoading;

    // Determine colors based on state
    final Color effectiveBackgroundColor =
        isDisabled
            ? (disabledBackgroundColor ?? Colors.grey[400]!)
            : (backgroundColor ?? AppColors.primary);

    final Color effectiveTextColor =
        isDisabled
            ? (disabledTextColor ?? Colors.grey[600]!)
            : (textColor ?? Colors.white);

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: disabledBackgroundColor ?? Colors.grey[300],
          disabledForegroundColor: disabledTextColor ?? Colors.grey[600],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isDisabled ? 0 : 2, // No elevation when disabled
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      effectiveTextColor,
                    ),
                  ),
                )
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: effectiveTextColor,
                  ),
                ),
      ),
    );
  }
}
