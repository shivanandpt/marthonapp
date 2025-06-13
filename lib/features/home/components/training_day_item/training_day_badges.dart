import 'package:flutter/material.dart';
import 'package:marunthon_app/core/theme/app_colors.dart';
import 'package:marunthon_app/features/home/models/training_day_model.dart';

class TrainingDayBadges extends StatelessWidget {
  final TrainingDayModel day;

  const TrainingDayBadges({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (day.configuration.optional) _buildOptionalBadge(),
        if (day.configuration.restDay) _buildRestDayBadge(),
      ],
    );
  }

  Widget _buildOptionalBadge() {
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "Optional",
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
    );
  }

  Widget _buildRestDayBadge() {
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "Rest Day",
        style: TextStyle(fontSize: 12, color: AppColors.info),
      ),
    );
  }
}
