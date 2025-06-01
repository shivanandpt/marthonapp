import 'package:flutter/material.dart';
import 'package:marunthon_app/features/user_profile/setup/controllers/user_profile_setup_controller.dart';

class TrainingPrefStep extends StatelessWidget {
  final UserProfileSetupController controller;

  const TrainingPrefStep({Key? key, required this.controller})
    : super(key: key);

  static const List<Map<String, dynamic>> trainingDays = [
    {
      'value': 1,
      'title': '1 Day',
      'description': 'Light training',
      'icon': Icons.looks_one,
    },
    {
      'value': 2,
      'title': '2 Days',
      'description': 'Moderate training',
      'icon': Icons.looks_two,
    },
    {
      'value': 3,
      'title': '3 Days',
      'description': 'Regular training',
      'icon': Icons.looks_3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How many days per week do you want to train?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),

          // Training days selection (similar to goal selection)
          ...trainingDays.map((day) {
            final isSelected = controller.runDaysPerWeek == day['value'];
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
                    controller.updateRunDaysPerWeek(day['value']);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Day icon
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
                            day['icon'],
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),

                        // Day info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day['title'],
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
                                day['description'],
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
      ),
    );
  }
}
