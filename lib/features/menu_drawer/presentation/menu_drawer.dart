import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/data/services/firestore_service.dart';
import 'package:marunthon_app/features/home/home_page.dart';
import 'package:marunthon_app/features/settings/settings_page.dart';

import 'package:marunthon_app/features/auth/presentation/login_page.dart';
import 'package:marunthon_app/features/auth/data/user_prefrences.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String userName = "Runner";
  final List<Map<String, dynamic>> menuItems = [
    {'icon': Icons.home, 'title': 'Home', 'action': 'Home'},
    {'icon': Icons.run_circle, 'title': 'My Runs', 'action': 'My Runs'},
    {'icon': Icons.settings, 'title': 'Settings', 'action': 'Settings'},
    {'icon': Icons.info, 'title': 'About', 'action': 'About'},
    {'icon': Icons.logout, 'title': 'Logout', 'action': 'Logout'},
  ];
  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    String? userId = await UserPreferences.getUserId();
    if (userId != null) {
      String? savedName = await UserPreferences.getUserName();
      setState(() {
        userName = savedName ?? "Runner";
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _onMenuItemTapped(String item) {
    // Handle menu item tap
    print("Tapped on $item");
    switch (item) {
      case 'Home':
        // Navigate to Home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 'My Runs':
        // Navigate to My Runs
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => MyRunsPage()),
        // );
        break;
      case 'Settings':
        // Navigate to Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsPage()),
        );
        break;
      case 'About':
        // Navigate to About
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => AboutPage()),
        // );
        break;
      case 'Logout':
        // Handle logout
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        break;
      default:
        print("Unknown menu item: $item");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marathon Trainer',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                        'lib/assets/images/avatar.png',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome,',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          Text(
                            userName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow:
                                TextOverflow
                                    .ellipsis, // Handle long names gracefully
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...menuItems.map((item) {
            return ListTile(
              leading: Icon(item['icon']),
              title: Text(item['title']),
              onTap: () => _onMenuItemTapped(item['title']),
            );
          }),
        ],
      ),
    );
  }
}
