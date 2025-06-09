import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class ProfileInfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileInfoSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Divider(),
        ...children,
      ],
    );
  }
}
