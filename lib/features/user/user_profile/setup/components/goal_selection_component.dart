import 'package:flutter/material.dart';
import 'package:marunthon_app/features/user/user_profile/setup/controllers/user_profile_setup_controller.dart';

class GoalSelectionComponent extends StatelessWidget {
  final UserProfileSetupController controller;
  final bool showTitle;
  final String? customTitle;

  const GoalSelectionComponent({
    Key? key,
    required this.controller,
    this.showTitle = true,
    this.customTitle,
  }) : super(key: key);

  static const List<Map<String, dynamic>> runningGoals = [
    {
      'value': '5K',
      'title': '5K',
      'description': 'Perfect for beginners',
      'icon': Icons.directions_walk,
    },
    {
      'value': '10K',
      'title': '10K',
      'description': 'Build your endurance',
      'icon': Icons.directions_run,
    },
    {
      'value': 'Half Marathon',
      'title': 'Half Marathon',
      'description': 'Challenge yourself',
      'icon': Icons.trending_up,
    },
    {
      'value': 'Full Marathon',
      'title': 'Full Marathon',
      'description': 'Ultimate achievement',
      'icon': Icons.emoji_events,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            customTitle ?? 'Select your running goal:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
        ],

        // Goal selection cards
        ...runningGoals.map((goal) {
          final isSelected =
              controller.basicInfoController.selectedGoal == goal['value'];
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: isSelected ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  controller.basicInfoController.setGoal(goal['value']);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Goal icon
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                  : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          goal['icon'],
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),

                      // Goal info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal['title'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              goal['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selection indicator
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[400]!,
                            width: 2,
                          ),
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                        ),
                        child:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
