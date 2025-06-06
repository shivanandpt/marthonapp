import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'sort_option_enum.dart';
import 'sort_utils.dart';

class SortBottomSheet extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;

  const SortBottomSheet({
    Key? key,
    required this.currentSort,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.filter, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Sort Runs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...SortOption.values.map(
            (option) => ListTile(
              leading: Icon(
                SortUtils.getSortIcon(option),
                color:
                    currentSort == option
                        ? AppColors.primary
                        : AppColors.textSecondary,
              ),
              title: Text(
                SortUtils.getSortLabel(option),
                style: TextStyle(
                  color:
                      currentSort == option
                          ? AppColors.primary
                          : AppColors.textPrimary,
                  fontWeight:
                      currentSort == option
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
              trailing:
                  currentSort == option
                      ? Icon(LucideIcons.check, color: AppColors.primary)
                      : null,
              onTap: () {
                onSortChanged(option);
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required SortOption currentSort,
    required Function(SortOption) onSortChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SortBottomSheet(
            currentSort: currentSort,
            onSortChanged: onSortChanged,
          ),
    );
  }
}
