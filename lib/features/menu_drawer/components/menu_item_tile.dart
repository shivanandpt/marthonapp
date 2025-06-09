import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class MenuItemTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onTap;

  const MenuItemTile({
    super.key,
    required this.item,
    this.isLoading = false,
    this.isEnabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : Icon(item['icon'], color: AppColors.secondary),
      title: Text(
        item['title'],
        style: TextStyle(color: AppColors.textPrimary),
      ),
      enabled: isEnabled,
      onTap: isLoading ? null : onTap,
    );
  }
}
