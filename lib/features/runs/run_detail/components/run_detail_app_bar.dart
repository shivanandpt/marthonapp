import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class RunDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const RunDetailAppBar({Key? key, this.title = "Run Details"})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.background,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Implement share functionality
          },
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
          onPressed: () {
            // TODO: Implement more options
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
