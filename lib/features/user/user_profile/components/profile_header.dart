import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../setup/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildProfileAvatar(),
          const SizedBox(height: 16),
          _buildUserName(),
          _buildUserEmail(),
          const SizedBox(height: 32),
          _buildEditButton(context),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 60,
      backgroundImage:
          user.profilePic.isNotEmpty ? NetworkImage(user.profilePic) : null,
      child:
          user.profilePic.isEmpty
              ? Icon(LucideIcons.user, size: 60, color: Colors.white)
              : null,
    );
  }

  Widget _buildUserName() {
    return Text(
      user.name,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildUserEmail() {
    return Text(
      user.email,
      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.push('/profile-edit'),
      icon: Icon(LucideIcons.edit),
      label: Text('Edit Profile'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
