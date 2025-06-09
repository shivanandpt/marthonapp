import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../setup/models/user_model.dart';
import 'profile_info_section.dart';
import 'profile_info_tile.dart';

class SubscriptionInfoSection extends StatelessWidget {
  final UserModel user;

  const SubscriptionInfoSection({Key? key, required this.user})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileInfoSection(
      title: 'Subscription',
      children: [
        ProfileInfoTile(
          icon: LucideIcons.creditCard,
          title: 'Plan Type',
          value: _formatSubscriptionType(user.subscriptionType),
        ),
        if (user.trialEndDate != null)
          ProfileInfoTile(
            icon: LucideIcons.clock,
            title: 'Trial Expires',
            value: DateFormat('MMMM d, yyyy').format(user.trialEndDate!),
          ),
        ProfileInfoTile(
          icon: LucideIcons.checkCircle,
          title: 'Trial Status',
          value: user.isTrialExpired ? 'Expired' : 'Active',
        ),
      ],
    );
  }

  String _formatSubscriptionType(String type) {
    switch (type.toLowerCase()) {
      case 'free':
        return 'Free Plan';
      case 'monthly':
        return 'Monthly Subscription';
      case 'yearly':
        return 'Yearly Subscription';
      default:
        return type.substring(0, 1).toUpperCase() + type.substring(1);
    }
  }
}
