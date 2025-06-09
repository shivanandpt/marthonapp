import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class RestDayContent extends StatelessWidget {
  const RestDayContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.bedDouble, color: AppColors.info),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rest Day",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                Text(
                  "Take time to recover and let your body rest.",
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
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
