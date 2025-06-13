import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Make sure this is imported
import '../data/firebase_service.dart';
import 'package:marunthon_app/features/user/user_profile/setup/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/services/analytics_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final UserService _userService = UserService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    AnalyticsService.setCurrentScreen('LoginPage');
    _checkUser(); // Check if user is already logged in
  }

  void _checkUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // If user is logged in, check if profile is complete
      await _checkProfileAndNavigate(user);
    }
  }

  Future<void> _checkProfileAndNavigate(User user) async {
    try {
      // First try to get profile from the new UserService
      var userModel = await _userService.getUserProfile(user.uid);

      if (userModel != null) {
        // Profile exists in the new system, check if it's complete
        if (_isProfileComplete(userModel)) {
          // Profile is complete, navigate to home
          if (!mounted) return;
          // FIXED: Using GoRouter instead of Navigator.pushReplacementNamed
          context.go('/');
          return;
        } else {
          // Profile exists but incomplete, navigate to setup flow
          if (!mounted) return;
          _navigateToProfileSetup();
          return;
        }
      }

      // Check old user profile system as fallback
      var oldUserProfile = await _userService.getUserProfile(user.uid);
      if (oldUserProfile != null) {
        // Old profile exists but not migrated to new system
        // Either migrate first or direct to setup
        if (!mounted) return;
        _navigateToProfileSetup();
        return;
      }

      // No profile exists, navigate to profile setup
      if (!mounted) return;
      _navigateToProfileSetup();
    } catch (e) {
      print("Error checking user profile: $e");
      // On error, best to navigate to profile setup
      if (!mounted) return;
      _navigateToProfileSetup();
    }
  }

  bool _isProfileComplete(dynamic userModel) {
    // Define minimal required fields for a complete profile
    return userModel.name.isNotEmpty &&
        userModel.goal.isNotEmpty &&
        userModel.dob != null;
  }

  void _navigateToProfileSetup() {
    // FIXED: Using GoRouter instead of Navigator.pushReplacement
    context.go('/profile-setup');
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return; // Prevent multiple taps

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      User? user = await _firebaseService.signInWithGoogle();
      if (user != null) {
        // Log analytics event
        AnalyticsService.logEvent('login', {'method': 'google_sign_in'});

        // Check if user already exists in the new system
        var userModel = await _userService.getUserProfile(user.uid);

        if (userModel != null && _isProfileComplete(userModel)) {
          // User exists with complete profile, go to home
          AnalyticsService.setCurrentScreen('HomePage');
          if (mounted) context.go('/');
          return;
        }

        // Regardless of old profile, direct to new profile setup
        if (mounted) _navigateToProfileSetup();
      } else {
        // User cancelled the sign-in
        setState(() {
          _errorMessage = 'Sign-in was cancelled. Please try again.';
        });
      }
    } catch (e) {
      print("Error during sign-in: $e");
      setState(() {
        _errorMessage =
            'Failed to sign in. Please check your internet connection and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo above the button
              SizedBox(
                width: 240,
                height: 240,
                child: Image.asset(
                  'assets/app_icon/run_mate.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 48),

              // App title
              Text(
                'Welcome to RunMate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Track your runs, achieve your goals',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isLoading ? Colors.grey[300] : Colors.white,
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey[300]!),
                    elevation: 2,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleSignIn,
                  child:
                      _isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Signing in...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icons/google_logo.png',
                                height: 24,
                                width: 24,
                                errorBuilder: (context, error, stackTrace) {
                                  // Fallback if Google logo asset doesn't exist
                                  return Icon(
                                    Icons.account_circle,
                                    size: 24,
                                    color: Colors.blue[600],
                                  );
                                },
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 24),

              // Privacy note
              Text(
                'By signing in, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
