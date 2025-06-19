import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/auth/bloc/logout_bloc.dart';
import 'drawer_header_section.dart';
import 'menu_items_list.dart';

class DrawerContent extends StatelessWidget {
  final String userName;
  final String? userProfilePic;
  final LogoutState state;
  final Function(String) onMenuItemTapped;

  const DrawerContent({
    super.key,
    required this.userName,
    this.userProfilePic,
    required this.state,
    required this.onMenuItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.cardBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeaderSection(
            userName: userName,
            userProfilePic: userProfilePic,
          ),
          MenuItemsList(state: state, onMenuItemTapped: onMenuItemTapped),
        ],
      ),
    );
  }
}
