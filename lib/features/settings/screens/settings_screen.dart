import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../components/delete_account_dialog.dart';
import '../services/account_deletion_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildUserProfileSection(),

            const SizedBox(height: 24),

            // Settings Sections
            _buildSettingsSection(),

            const SizedBox(height: 24),

            // Danger Zone
            _buildDangerZone(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage:
                  _user?.photoURL != null
                      ? NetworkImage(_user!.photoURL!)
                      : null,
              child:
                  _user?.photoURL == null
                      ? Icon(
                        LucideIcons.user,
                        size: 30,
                        color: AppColors.primary,
                      )
                      : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.cardBg,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: LucideIcons.user,
                title: 'Profile',
                subtitle: 'Edit your profile information',
                onTap: () {
                  // Navigate to profile screen
                  // TODO: Implement profile navigation
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: LucideIcons.bell,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
                onTap: () {
                  // Navigate to notifications screen
                  // TODO: Implement notifications navigation
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: LucideIcons.moon,
                title: 'Theme',
                subtitle: 'Dark/Light mode settings',
                onTap: () {
                  // Navigate to theme screen
                  // TODO: Implement theme navigation
                },
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: LucideIcons.shield,
                title: 'Privacy',
                subtitle: 'Privacy and data settings',
                onTap: () {
                  // Navigate to privacy screen
                  // TODO: Implement privacy navigation
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 16),
        Card(color: AppColors.cardBg, child: _buildDeleteAccountTile()),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        color: AppColors.textSecondary,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDeleteAccountTile() {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(LucideIcons.trash2, color: AppColors.error, size: 20),
      ),
      title: Text(
        'Delete Account',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.error,
        ),
      ),
      subtitle: Text(
        'Permanently delete your account and all data',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      trailing:
          _isLoading
              ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                ),
              )
              : Icon(
                LucideIcons.chevronRight,
                color: AppColors.error,
                size: 20,
              ),
      onTap: _isLoading ? null : _handleDeleteAccount,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.disabled.withOpacity(0.3),
      indent: 16,
      endIndent: 16,
    );
  }

  Future<void> _handleDeleteAccount() async {
    if (_user == null) return;

    final bool? shouldDelete = await DeleteAccountDialog.show(context);

    if (shouldDelete == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final accountDeletionService = AccountDeletionService();
        await accountDeletionService.deleteUserAccountWithReauth(_user.uid);

        // If we reach here, account deletion was successful
        // Show success message before logout
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account successfully deleted',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to login page
          context.go('/login');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          String errorMessage;
          if (e.code == 'requires-recent-login') {
            errorMessage = 'Please sign in again to delete your account';
          } else {
            errorMessage = 'Failed to delete account: ${e.message}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _handleDeleteAccount,
              ),
            ),
          );
        }
      } catch (e) {
        // Handle other errors
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete account: ${e.toString()}',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _handleDeleteAccount,
              ),
            ),
          );
        }
      }
    }
  }
}
