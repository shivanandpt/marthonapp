// User profile screen for storing and editing user information
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:marunthon_app/core/services/user_service.dart'; // New UserService
import 'package:marunthon_app/core/services/user_profile_service.dart'; // Legacy service
import 'package:marunthon_app/models/user_model.dart'; // New model
import 'package:marunthon_app/models/user_profile.dart'; // Legacy model
import 'package:marunthon_app/core/theme/app_colors.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  UserModel? _userModel;
  bool _loading = true;
  bool _isLegacyUser = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      // Try to load user from new UserService first
      final userModel = await _userService.getUserProfile(user.uid);

      if (userModel != null) {
        setState(() {
          _userModel = userModel;
          _loading = false;
        });
      } else {
        // Fall back to legacy user profile system
        final legacyProfile = await UserProfileService().fetchUserProfile(
          user.uid,
        );
        setState(() {
          _isLegacyUser = true;
          _loading = false;
        });

        // Optionally migrate legacy user to new system
        if (legacyProfile != null) {
          _migrateToNewUserModel(user.uid, legacyProfile, user);
        }
      }
    } catch (e) {
      print("Error loading user profile: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _migrateToNewUserModel(
    String userId,
    UserProfile legacyProfile,
    User firebaseUser,
  ) async {
    try {
      // Create a new user model from legacy data
      final userModel = UserModel(
        id: userId,
        name: legacyProfile.name,
        email: legacyProfile.email,
        profilePic: legacyProfile.profilePicPath ?? firebaseUser.photoURL ?? '',
        metricSystem: legacyProfile.weightUnit == 'kg' ? 'metric' : 'imperial',
        weight: legacyProfile.weight.toInt(),
        height: legacyProfile.height.toInt(),
        dob: legacyProfile.dob,
        gender: legacyProfile.gender.toLowerCase(),
        goal: legacyProfile.trainingGoal,
        runDaysPerWeek: 3, // Default value
        language: 'en', // Default value
        timezone: 'UTC', // Default value
        joinedAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
        appVersion: '',
      );

      // Save the migrated user
      await _userService.createUserProfile(userModel);

      // Reload the profile
      final updatedUserModel = await _userService.getUserProfile(userId);
      if (updatedUserModel != null) {
        setState(() {
          _userModel = updatedUserModel;
          _isLegacyUser = false;
        });
      }
    } catch (e) {
      print("Error migrating user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Smart navigation - go back if possible, otherwise go home
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/profile-edit'),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_userModel == null) {
      return _buildNoProfileView();
    }

    return _buildProfileView();
  }

  Widget _buildNoProfileView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.userX, size: 64, color: AppColors.secondary),
          const SizedBox(height: 16),
          Text(
            'Profile not found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find your profile information',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.push('/profile-setup');
            },
            child: const Text('Create Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with profile pic and name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _userModel!.profilePic.isNotEmpty
                          ? NetworkImage(_userModel!.profilePic)
                          : null,
                  child:
                      _userModel!.profilePic.isEmpty
                          ? Icon(
                            LucideIcons.user,
                            size: 60,
                            color: Colors.white,
                          )
                          : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _userModel!.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  _userModel!.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),

                const SizedBox(height: 32),

                // Edit Profile Button
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/profile-edit');
                  },
                  icon: Icon(LucideIcons.edit),
                  label: Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Profile info sections
          _buildInfoSection('Basic Information', [
            _buildInfoTile(LucideIcons.goal, 'Goal', _userModel!.goal),
            _buildInfoTile(
              LucideIcons.calendar,
              'Date of Birth',
              _userModel!.dob != null
                  ? DateFormat('MMMM d, yyyy').format(_userModel!.dob!)
                  : 'Not set',
            ),
            _buildInfoTile(
              LucideIcons.languages,
              'Language',
              _userModel!.language == 'en' ? 'English' : 'Spanish',
            ),
          ]),

          const SizedBox(height: 24),

          _buildInfoSection('Training Preferences', [
            _buildInfoTile(
              LucideIcons.ruler,
              'Measurement System',
              _userModel!.metricSystem == 'metric'
                  ? 'Metric (km)'
                  : 'Imperial (miles)',
            ),
            _buildInfoTile(
              LucideIcons.calendar,
              'Running Days per Week',
              '${_userModel!.runDaysPerWeek} days',
            ),
          ]),

          const SizedBox(height: 24),

          _buildInfoSection('Health Information', [
            _buildInfoTile(
              LucideIcons.scale,
              'Weight',
              _userModel!.weight > 0
                  ? '${_userModel!.weight} ${_userModel!.metricSystem == 'metric' ? 'kg' : 'lbs'}'
                  : 'Not set',
            ),
            _buildInfoTile(
              LucideIcons.ruler,
              'Height',
              _userModel!.height > 0
                  ? '${_userModel!.height} ${_userModel!.metricSystem == 'metric' ? 'cm' : 'in'}'
                  : 'Not set',
            ),
            if (_userModel!.gender != null && _userModel!.gender!.isNotEmpty)
              _buildInfoTile(LucideIcons.users, 'Gender', _userModel!.gender!),
            if (_userModel!.injuryNotes != null &&
                _userModel!.injuryNotes!.isNotEmpty)
              _buildInfoTile(
                LucideIcons.stethoscope,
                'Health Notes',
                _userModel!.injuryNotes!,
              ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
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

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.secondary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
