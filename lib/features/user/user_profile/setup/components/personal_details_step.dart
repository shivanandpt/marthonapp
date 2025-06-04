import 'package:flutter/material.dart';
import '../controllers/user_profile_setup_controller.dart';

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
          widget.controller.physicalAttributesController.height != null &&
                  widget.controller.physicalAttributesController.height! > 0
              ? widget.controller.physicalAttributesController.height.toString()
              : '',
    );
    _weightController = TextEditingController(
      text:
          widget.controller.physicalAttributesController.weight != null &&
                  widget.controller.physicalAttributesController.weight! > 0
              ? widget.controller.physicalAttributesController.weight.toString()
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
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.controller.personalInfoController,
        widget.controller.physicalAttributesController,
      ]),
      builder: (context, child) {
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
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          widget.controller.personalInfoController.dob ??
                          DateTime.now().subtract(Duration(days: 365 * 25)),
                      firstDate: DateTime.now().subtract(
                        Duration(days: 365 * 100),
                      ),
                      lastDate: DateTime.now().subtract(
                        Duration(days: 365 * 13),
                      ),
                    );
                    if (date != null) {
                      widget.controller.personalInfoController.updateDob(date);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.controller.personalInfoController.dob != null
                            ? '${widget.controller.personalInfoController.dob!.day}/${widget.controller.personalInfoController.dob!.month}/${widget.controller.personalInfoController.dob!.year}'
                            : 'Select date of birth',
                        style: TextStyle(
                          color:
                              widget.controller.personalInfoController.dob !=
                                      null
                                  ? Colors.white
                                  : Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.calendar_today, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ),

              // Age display (calculated from DOB)
              if (widget.controller.personalInfoController.dob != null) ...[
                SizedBox(height: 12),
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
                        Icons.cake,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Age: ${widget.controller.personalInfoController.calculatedAge} years old',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 24),

              // Gender Dropdown
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value:
                        widget
                                    .controller
                                    .personalInfoController
                                    .gender
                                    ?.isEmpty ==
                                true
                            ? null
                            : widget.controller.personalInfoController.gender,
                    hint: Text(
                      'Select gender',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    isExpanded: true,
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(color: Colors.white),
                    items: [
                      DropdownMenuItem(
                        value: 'male',
                        child: Text(
                          'Male',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text(
                          'Female',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(
                          'Other',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'prefer_not_to_say',
                        child: Text(
                          'Prefer not to say',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        widget.controller.personalInfoController.updateGender(
                          newValue,
                        );
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Language Selection
              Text(
                'Preferred Language',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[800],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: widget.controller.personalInfoController.language,
                    isExpanded: true,
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(color: Colors.white),
                    items:
                        ['English', 'Spanish'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        widget.controller.personalInfoController.updateLanguage(
                          newValue,
                        );
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
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[600]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.controller.physicalAttributesController
                              .updateMetricSystem('metric');
                          // Update hint text when metric system changes
                          _updateHintTexts();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                widget
                                            .controller
                                            .physicalAttributesController
                                            .metricSystem ==
                                        'metric'
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
                                  widget
                                              .controller
                                              .physicalAttributesController
                                              .metricSystem ==
                                          'metric'
                                      ? Colors.white
                                      : Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          widget.controller.physicalAttributesController
                              .updateMetricSystem('imperial');
                          // Update hint text when metric system changes
                          _updateHintTexts();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                widget
                                            .controller
                                            .physicalAttributesController
                                            .metricSystem ==
                                        'imperial'
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
                                  widget
                                              .controller
                                              .physicalAttributesController
                                              .metricSystem ==
                                          'imperial'
                                      ? Colors.white
                                      : Colors.grey[400],
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

              // Height and Weight Section
              Row(
                children: [
                  // Height
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Height (${widget.controller.physicalAttributesController.metricSystem == 'metric' ? 'cm' : 'ft'})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText:
                                widget
                                            .controller
                                            .physicalAttributesController
                                            .metricSystem ==
                                        'metric'
                                    ? '170'
                                    : '5.8',
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
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            fillColor: Colors.grey[800],
                            filled: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final height =
                                  widget
                                              .controller
                                              .physicalAttributesController
                                              .metricSystem ==
                                          'metric'
                                      ? int.tryParse(value)
                                      : (double.tryParse(value)?.round());
                              widget.controller.physicalAttributesController
                                  .updateHeight(height);
                            } else {
                              widget.controller.physicalAttributesController
                                  .updateHeight(null);
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
                          'Weight (${widget.controller.physicalAttributesController.metricSystem == 'metric' ? 'kg' : 'lbs'})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText:
                                widget
                                            .controller
                                            .physicalAttributesController
                                            .metricSystem ==
                                        'metric'
                                    ? '70'
                                    : '150',
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
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            fillColor: Colors.grey[800],
                            filled: true,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              final weight = int.tryParse(value);
                              widget.controller.physicalAttributesController
                                  .updateWeight(weight);
                            } else {
                              widget.controller.physicalAttributesController
                                  .updateWeight(null);
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
      },
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
