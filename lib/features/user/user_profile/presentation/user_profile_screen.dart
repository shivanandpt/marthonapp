// User profile screen for storing and editing user information
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import '../setup/services/user_service.dart';
import '../setup/models/user_model.dart';
import '../components/profile_header.dart';
import '../components/basic_info_section.dart';
import '../components/training_preferences_section.dart';
import '../components/health_info_section.dart';
import '../components/subscription_info_section.dart';
import '../components/no_profile_view.dart';
import '../components/loading_view.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  UserModel? _userModel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final userModel = await _userService.getUserProfile(user.uid);
      setState(() {
        _userModel = userModel;
        _loading = false;
      });
    } catch (e) {
      print("Error loading user profile: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('Profile', style: TextStyle(color: AppColors.textPrimary)),
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go('/');
          }
        },
      ),
      actions: [
        if (_userModel != null)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/profile-edit'),
            tooltip: 'Edit Profile',
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return LoadingView(message: 'Loading your profile...');
    }

    if (_userModel == null) {
      return NoProfileView();
    }

    return _buildProfileView();
  }

  Widget _buildProfileView() {
    return RefreshIndicator(
      onRefresh: _loadUserProfile,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with avatar, name, email, and edit button
            ProfileHeader(user: _userModel!),

            const SizedBox(height: 40),

            // Basic information section
            BasicInfoSection(user: _userModel!),

            const SizedBox(height: 24),

            // Training preferences section
            TrainingPreferencesSection(user: _userModel!),

            const SizedBox(height: 24),

            // Health information section
            HealthInfoSection(user: _userModel!),

            const SizedBox(height: 24),

            // Subscription information section
            SubscriptionInfoSection(user: _userModel!),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
