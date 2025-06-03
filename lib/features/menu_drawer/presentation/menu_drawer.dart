import 'dart:async'; // Add this import for StreamSubscription
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/features/auth/bloc/logout_bloc.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String userName = "Runner";
  late LogoutBloc _logoutBloc;
  StreamSubscription<User?>? _authSubscription;

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
    _logoutBloc = LogoutBloc();
    _setupAuthListener();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _logoutBloc.close();
    super.dispose();
  }

  void _setupAuthListener() {
    // Listen to authentication state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? user,
    ) {
      if (mounted) {
        if (user != null) {
          setState(() {
            userName = user.displayName ?? user.email ?? "Runner";
          });
        } else {
          // User is logged out, navigate to login after current build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/login');
            }
          });
        }
      }
    });
  }

  void _onMenuItemTapped(String item) {
    print("Tapped on $item");

    switch (item) {
      case 'Home':
        if (mounted) {
          Navigator.of(context).pop(); // Close drawer
          AnalyticsService.setCurrentScreen('HomePage');
          context.go('/');
        }
        break;
      case 'Profile':
        if (mounted) {
          Navigator.of(context).pop(); // Close drawer
          context.go('/profile');
        }
        break;
      case 'My Runs':
        if (mounted) {
          Navigator.of(context).pop(); // Close drawer
          context.go('/my-runs');
        }
        break;
      case 'Settings':
        if (mounted) {
          Navigator.of(context).pop(); // Close drawer
          context.go('/settings');
        }
        break;
      case 'About':
        if (mounted) {
          Navigator.of(context).pop(); // Close drawer
          context.go('/about');
        }
        break;
      case 'Logout':
        // Don't close drawer here - handle it in logout process
        _handleLogout();
        break;
      default:
        print("Unknown menu item: $item");
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;

    // Show confirmation dialog (drawer remains open)
    final bool? shouldLogout = await _showLogoutConfirmation();

    if (shouldLogout != true || !mounted) return;

    // Start logout process (drawer will be closed by BlocListener)
    _logoutBloc.add(LogoutRequested());
  }

  Future<bool?> _showLogoutConfirmation() {
    if (!mounted) return Future.value(false);

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutError(String error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout failed: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            if (mounted) {
              _logoutBloc.add(LogoutRequested());
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      bloc: _logoutBloc,
      listener: (context, state) {
        if (state is LogoutLoading) {
          // Close drawer when logout starts
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } else if (state is LogoutSuccess) {
          // Use addPostFrameCallback for navigation after logout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              AnalyticsService.setCurrentScreen('LoginPage');
              context.go('/login');
            }
          });
        } else if (state is LogoutFailure) {
          if (mounted) {
            _showLogoutError(state.error);
          }
        }
      },
      child: BlocBuilder<LogoutBloc, LogoutState>(
        bloc: _logoutBloc,
        builder: (context, state) {
          return Stack(
            children: [
              Drawer(
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
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 40,
                                  backgroundImage: AssetImage(
                                    'lib/assets/images/avatar.png',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Welcome,',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                      final bool isLogout = item['title'] == 'Logout';
                      final bool isLoading = state is LogoutLoading && isLogout;

                      return ListTile(
                        leading:
                            isLoading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(
                                  item['icon'],
                                  color: AppColors.secondary,
                                ),
                        title: Text(
                          item['title'],
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        enabled: !(state is LogoutLoading),
                        onTap:
                            isLoading
                                ? null
                                : () => _onMenuItemTapped(item['title']),
                      );
                    }),
                  ],
                ),
              ),
              // Show loading overlay during logout
              if (state is LogoutLoading)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Logging out...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
