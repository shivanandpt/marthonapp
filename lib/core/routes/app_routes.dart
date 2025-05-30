import 'package:flutter/material.dart';
import 'package:marunthon_app/features/settings/settings_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => MainScreen());
      // case '/trainingPlan':
      //   return MaterialPageRoute(builder: (_) => TrainingPlanPage());
      // case '/logRun':
      //   return MaterialPageRoute(builder: (_) => LogRunPage());
      case '/settings':
        return MaterialPageRoute(builder: (_) => SettingsPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('Page not found')), // 404 page
              ),
        );
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    // HomePage(),
    // TrainingPlanPage(),
    // LogRunPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Log Run',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
