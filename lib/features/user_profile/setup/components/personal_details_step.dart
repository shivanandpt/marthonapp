import 'package:flutter/material.dart';
import 'package:marunthon_app/features/user_profile/setup/controllers/user_profile_setup_controller.dart';

class PersonalDetailsStep extends StatefulWidget {
  final UserProfileSetupController controller;

  const PersonalDetailsStep({Key? key, required this.controller})
    : super(key: key);

  @override
  State<PersonalDetailsStep> createState() => _PersonalDetailsStepState();
}

class _PersonalDetailsStepState extends State<PersonalDetailsStep> {
  // Create controllers once and reuse them
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current values
    _heightController = TextEditingController(
      text:
          widget.controller.height != null && widget.controller.height! > 0
              ? widget.controller.height.toString()
              : '',
    );
    _weightController = TextEditingController(
      text:
          widget.controller.weight != null && widget.controller.weight! > 0
              ? widget.controller.weight.toString()
              : '',
    );
  }

  @override
  void dispose() {
    // Don't forget to dispose controllers
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date of Birth
          Text(
            'Date of Birth',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: widget.controller.dob ?? DateTime(1990),
                  firstDate: DateTime(1930),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  widget.controller.updateDob(date);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.controller.dob != null
                        ? '${widget.controller.dob!.day}/${widget.controller.dob!.month}/${widget.controller.dob!.year}'
                        : 'Select date of birth',
                    style: TextStyle(
                      color:
                          widget.controller.dob != null
                              ? Colors
                                  .white // Fix: Changed from Colors.white
                              : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  Icon(Icons.calendar_today, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          // Gender Dropdown
          Text(
            'Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    widget.controller.gender?.isEmpty == true
                        ? null
                        : widget.controller.gender, // Fixed null safety
                hint: Text('Select gender'),
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                  DropdownMenuItem(
                    value: 'prefer_not_to_say',
                    child: Text('Prefer not to say'),
                  ),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.controller.updateGender(newValue);
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 24),

          // Metric System Toggle
          Text(
            'Measurement System',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.controller.updateMetricSystem('metric');
                      // Update hint text when metric system changes
                      _updateHintTexts();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            widget.controller.metricSystem == 'metric'
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(7),
                        ),
                      ),
                      child: Text(
                        'Metric (kg/cm)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              widget.controller.metricSystem == 'metric'
                                  ? Colors.white
                                  : Colors.grey[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      widget.controller.updateMetricSystem('imperial');
                      // Update hint text when metric system changes
                      _updateHintTexts();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            widget.controller.metricSystem == 'imperial'
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                      child: Text(
                        'Imperial (lbs/ft)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              widget.controller.metricSystem == 'imperial'
                                  ? Colors.white
                                  : Colors.grey[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Height and Weight Section - FIXED
          Row(
            children: [
              // Height
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Height (${widget.controller.metricSystem == 'metric' ? 'cm' : 'ft'})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller:
                          _heightController, // Use persistent controller
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText:
                            widget.controller.metricSystem == 'metric'
                                ? '170'
                                : '5.8',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final height =
                              widget.controller.metricSystem == 'metric'
                                  ? int.tryParse(value)
                                  : (double.tryParse(
                                    value,
                                  )?.round()); // Handle decimal for imperial
                          widget.controller.updateHeight(height);
                        } else {
                          widget.controller.updateHeight(null);
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Weight
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight (${widget.controller.metricSystem == 'metric' ? 'kg' : 'lbs'})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller:
                          _weightController, // Use persistent controller
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText:
                            widget.controller.metricSystem == 'metric'
                                ? '70'
                                : '150',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final weight = int.tryParse(value);
                          widget.controller.updateWeight(weight);
                        } else {
                          widget.controller.updateWeight(null);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to update hint texts when metric system changes
  void _updateHintTexts() {
    setState(() {
      // The hint text will update because we're calling setState
      // and the decoration is recreated with new hint text
    });
  }
}
