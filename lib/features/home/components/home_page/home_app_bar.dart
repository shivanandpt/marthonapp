import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For system UI customization
import 'package:marunthon_app/core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "Dashboard", 
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0, // Prevents elevation when scrolling
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      // Platform-specific system UI overlay style
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // For dark theme
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      // Ensure proper centering on both platforms
      centerTitle: Theme.of(context).platform == TargetPlatform.iOS,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
