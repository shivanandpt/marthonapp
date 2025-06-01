import 'package:flutter/material.dart';
import 'package:marunthon_app/features/user_profile/setup/controllers/user_profile_setup_controller.dart';

class HealthInfoStep extends StatefulWidget {
  final UserProfileSetupController controller;

  const HealthInfoStep({Key? key, required this.controller}) : super(key: key);

  @override
  State<HealthInfoStep> createState() => _HealthInfoStepState();
}

class _HealthInfoStepState extends State<HealthInfoStep> {
  // Create a persistent TextEditingController for injury notes
  late TextEditingController _injuryNotesController;

  @override
  void initState() {
    super.initState();
    // Initialize with current value
    _injuryNotesController = TextEditingController(
      text: widget.controller.injuryNotes ?? '',
    );

    // Add listener to update controller when text changes
    _injuryNotesController.addListener(() {
      widget.controller.updateInjuryNotes(_injuryNotesController.text);
    });
  }

  @override
  void dispose() {
    _injuryNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This information helps us create a safer training plan for you (Optional)',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          SizedBox(height: 32),

          // Injury Notes Section
          Text(
            'Injury History & Medical Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tell us about any injuries, medical conditions, or physical limitations we should consider',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          SizedBox(height: 16),

          // Injury Notes Text Field - FIXED
          TextField(
            controller: _injuryNotesController, // Use persistent controller
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText:
                  'e.g., Previous knee injury, asthma, heart condition, etc.',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              fillColor: Colors.grey[800],
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 16,
              ),
            ),
            // Remove the onChanged callback since we're using addListener
            // onChanged: (value) {
            //   widget.controller.updateInjuryNotes(value);
            // },
          ),
          SizedBox(height: 24),

          // Additional Health Information Card
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
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Why we ask for this information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• We use this information to modify your training plan\n'
                    '• Helps prevent aggravating existing conditions\n'
                    '• Ensures your safety during training\n'
                    '• This information is kept private and secure',
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // Skip option
          Center(
            child: TextButton(
              onPressed: () {
                // Clear injury notes and continue
                _injuryNotesController.clear();
                widget.controller.updateInjuryNotes('');
              },
              child: Text(
                'Skip this step',
                style: TextStyle(
                  color: Colors.grey[400],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
