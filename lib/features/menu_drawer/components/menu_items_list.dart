import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/features/auth/bloc/logout_bloc.dart';
import 'menu_item_tile.dart';

class MenuItemsList extends StatelessWidget {
  final LogoutState state;
  final Function(String) onMenuItemTapped;

  const MenuItemsList({
    super.key,
    required this.state,
    required this.onMenuItemTapped,
  });

  static const List<Map<String, dynamic>> menuItems = [
    {'icon': LucideIcons.home, 'title': 'Home', 'action': 'Home'},
    {'icon': LucideIcons.user, 'title': 'Profile', 'action': 'Profile'},
    {'icon': LucideIcons.settings, 'title': 'Settings', 'action': 'Settings'},
    {'icon': LucideIcons.info, 'title': 'About', 'action': 'About'},
    {'icon': LucideIcons.logOut, 'title': 'Logout', 'action': 'Logout'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          menuItems.map((item) {
            final bool isLogout = item['title'] == 'Logout';
            final bool isLoading = state is LogoutLoading && isLogout;

            return MenuItemTile(
              item: item,
              isLoading: isLoading,
              isEnabled: state is! LogoutLoading,
              onTap: () => onMenuItemTapped(item['title']),
            );
          }).toList(),
    );
  }
}
