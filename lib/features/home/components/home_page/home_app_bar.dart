import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("Dashboard", style: TextStyle(color: AppColors.textPrimary)),
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
