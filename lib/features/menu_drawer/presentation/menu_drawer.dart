import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/features/auth/bloc/logout_bloc.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';
import '../components/drawer_content.dart';
import '../components/logout_loading_overlay.dart';
import '../components/logout_confirmation_dialog.dart';
import '../components/menu_navigation_handler.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  String userName = "Runner";
  String? userProfilePic;
  late LogoutBloc _logoutBloc;
  StreamSubscription<User?>? _authSubscription;

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
            userProfilePic = user.photoURL;
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
    if (item == 'Logout') {
      // Don't close drawer here - handle it in logout process
      _handleLogout();
    } else {
      MenuNavigationHandler.handleMenuItemTap(context, item);
    }
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;

    // Show confirmation dialog (drawer remains open)
    final bool? shouldLogout = await LogoutConfirmationDialog.show(context);

    if (shouldLogout != true || !mounted) return;

    // Start logout process (drawer will be closed by BlocListener)
    _logoutBloc.add(LogoutRequested());
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
              DrawerContent(
                userName: userName,
                userProfilePic: userProfilePic,
                state: state,
                onMenuItemTapped: _onMenuItemTapped,
              ),
              // Show loading overlay during logout
              if (state is LogoutLoading) const LogoutLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }
}
