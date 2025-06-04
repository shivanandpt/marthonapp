import 'package:flutter/material.dart';
import '../controllers/user_profile_setup_controller.dart';

class TrainingPrefStep extends StatelessWidget {
  final UserProfileSetupController controller;

  const TrainingPrefStep({Key? key, required this.controller})
    : super(key: key);

  static const List<Map<String, dynamic>> trainingDays = [
    {
      'value': 1,
      'title': '1 Day',
      'description': 'Light training - Perfect for beginners',
      'icon': Icons.looks_one,
      'detail': 'One focused session per week',
    },
    {
      'value': 2,
      'title': '2 Days',
      'description': 'Moderate training - Build consistency',
      'icon': Icons.looks_two,
      'detail': 'Two balanced sessions per week',
    },
    {
      'value': 3,
      'title': '3 Days',
      'description': 'Regular training - Optimal progress',
      'icon': Icons.looks_3,
      'detail': 'Three structured sessions per week',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.physicalAttributesController,
      builder: (context, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and description
              Text(
                'Training Frequency',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'How many days per week do you want to train?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose a frequency that fits your schedule and fitness level',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              SizedBox(height: 24),

              // Training days selection
              ...trainingDays.map((day) {
                final isSelected =
                    controller.physicalAttributesController.runDaysPerWeek ==
                    day['value'];
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: isSelected ? 8 : 2,
                    color:
                        isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[600]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        controller.physicalAttributesController
                            .updateRunDaysPerWeek(day['value']);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Day icon
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.2)
                                        : Colors.grey[700],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[600]!,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                day['icon'],
                                color:
                                    isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[400],
                                size: 28,
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
                                      color: Colors.grey[300],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    day['detail'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
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
                                          : Colors.grey[500]!,
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

              SizedBox(height: 24),

              // Info card about training frequency
              Card(
                color: Colors.grey[800],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Training Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Start with fewer days and gradually increase\n'
                        '• Rest days are crucial for recovery and progress\n'
                        '• Consistency is more important than frequency\n'
                        '• You can always adjust this later in your profile',
                        style: TextStyle(color: Colors.grey[300], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Note about customization
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Don\'t worry! You can change this anytime in your profile settings.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
