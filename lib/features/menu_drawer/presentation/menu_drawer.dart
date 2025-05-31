import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/features/home/home_page.dart';
import 'package:marunthon_app/features/settings/settings_page.dart';
import 'package:marunthon_app/features/auth/presentation/login_page.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/user_profile/user_profile_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String userName = "Runner";
  final List<Map<String, dynamic>> menuItems = [
    {'icon': LucideIcons.home, 'title': 'Home', 'action': 'Home'},
    {'icon': LucideIcons.user, 'title': 'Profile', 'action': 'Profile'},
    {'icon': LucideIcons.footprints, 'title': 'My Runs', 'action': 'My Runs'},
    {'icon': LucideIcons.settings, 'title': 'Settings', 'action': 'Settings'},
    {'icon': LucideIcons.info, 'title': 'About', 'action': 'About'},
    {'icon': LucideIcons.logOut, 'title': 'Logout', 'action': 'Logout'},
  ];
  @override
  void initState() {
    super.initState();
    _loadUserName();
    //sampleData();
  }

  Future<void> sampleData() async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final random = Random();

    // Generate 14 runs for the last 14 days
    for (int index = 0; index < 14; index++) {
      final daysAgo = 13 - index;
      final runStartTime = now.subtract(Duration(days: daysAgo));
      final userId = "5MsDTcEifVNYvuLp3bVdGYjeake2";

      final totalDistance = double.parse(
        (3.0 + random.nextDouble() * 3.0).toStringAsFixed(2),
      ); // 3–6 km
      final durationInSec = 900 + random.nextInt(900); // 15 to 30 min
      final averageSpeed = double.parse(
        (totalDistance / (durationInSec / 3600)).toStringAsFixed(2),
      );

      final startLat = 18.505845 + index * 0.001;
      final startLon = 73.7715346 + index * 0.001;
      final deltaLat = 0.00001 + random.nextDouble() * 0.00001;
      final deltaLon = 0.00001 + random.nextDouble() * 0.00001;

      final routePoints = List.generate(durationInSec.toInt(), (i) {
        final pointTime = runStartTime.add(Duration(seconds: i));
        return {
          'latitude': double.parse(
            (startLat + i * deltaLat).toStringAsFixed(6),
          ),
          'longitude': double.parse(
            (startLon + i * deltaLon).toStringAsFixed(6),
          ),
          'elevation': 570 + random.nextInt(20), // 570–589
          'speed': double.parse(
            (random.nextDouble() * 6 + 6).toStringAsFixed(2),
          ), // 6–12
          'timestamp': pointTime.millisecondsSinceEpoch, // ✅ epoch ms
        };
      });

      final avgElevation = double.parse(
        (routePoints.map((e) => e['elevation'] as num).reduce((a, b) => a + b) /
                routePoints.length)
            .toStringAsFixed(2),
      );

      final runData = {
        'userId': userId,
        'distance': totalDistance,
        'speed': averageSpeed,
        'elevation': avgElevation,
        'duration': durationInSec,
        'routePoints': routePoints,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await firestore.collection('runs').add(runData);
      print('✅ Uploaded run for day -$daysAgo');
    }

    print('🚀 All 14 sample runs uploaded!');
  }

  void _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? "Runner";
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
        AnalyticsService.setCurrentScreen('HomePage');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        break;
      case 'Profile':
        // Navigate to Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserProfileScreen()),
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
        AnalyticsService.logEvent('logout', {'method': 'menu_drawer'});
        FirebaseAuth.instance.signOut();
        AnalyticsService.setCurrentScreen('LoginPage');
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
      backgroundColor: AppColors.cardBg,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marathon Trainer',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
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
          ),
          ...menuItems.map((item) {
            return ListTile(
              leading: Icon(item['icon'], color: AppColors.secondary),
              title: Text(
                item['title'],
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () => _onMenuItemTapped(item['title']),
            );
          }),
        ],
      ),
    );
  }
}
