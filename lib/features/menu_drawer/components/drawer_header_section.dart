import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';

class DrawerHeaderSection extends StatelessWidget {
  final String userName;
  final String? userProfilePic;

  const DrawerHeaderSection({
    super.key,
    required this.userName,
    this.userProfilePic,
  });

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
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
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        userProfilePic != null && userProfilePic!.isNotEmpty
                            ? NetworkImage(userProfilePic!)
                            : const AssetImage('lib/assets/images/avatar.png')
                                as ImageProvider,
                    child:
                        userProfilePic == null || userProfilePic!.isEmpty
                            ? Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey[400],
                            )
                            : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome,',
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
    );
  }
}
