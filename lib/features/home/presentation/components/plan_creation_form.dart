import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../user/user_profile/setup/models/user_model.dart';
import '../../../user/user_profile/setup/components/goal_selection_component.dart';
import '../../../user/user_profile/setup/components/training_pref/training_day_option.dart';
import '../../../user/user_profile/setup/components/health_info/experience_level_selector.dart';
import '../../../user/user_profile/setup/controllers/user_profile_setup_controller.dart';

class PlanCreationForm extends StatefulWidget {
  final UserModel user;
  final Function(UserModel) onCreatePlan;

  const PlanCreationForm({
    super.key,
    required this.user,
    required this.onCreatePlan,
  });

  @override
  State<PlanCreationForm> createState() => _PlanCreationFormState();
}

class _PlanCreationFormState extends State<PlanCreationForm> {
  late UserModel _currentUser;
  final _formKey = GlobalKey<FormState>();
  late UserProfileSetupController _controller;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _controller = UserProfileSetupController();
    _initializeController();
  }

  void _initializeController() {
    // Initialize the controller with current user data
    _controller.basicInfoController.setGoal(
      _currentUser.trainingPreferences.goal,
    );
    _controller.physicalAttributesController.updateRunDaysPerWeek(
      _currentUser.trainingPreferences.runDaysPerWeek,
    );
    _controller.healthInfoController.updateExperience(
      _currentUser.trainingPreferences.experience,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCurrentPreferences(),
            const SizedBox(height: 24),
            _buildGoalSection(),
            const SizedBox(height: 24),
            _buildTrainingFrequency(),
            const SizedBox(height: 24),
            _buildExperienceLevel(),
            const SizedBox(height: 24),
            _buildGoalDate(),
            const SizedBox(height: 24),
            _buildInjuryNotes(),
            const SizedBox(height: 32),
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI Training Plan Generator',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a personalized training plan based on your profile.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPreferences() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Profile Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Age', '${_currentUser.age} years old'),
            _buildInfoRow(
              'Experience',
              _currentUser.trainingPreferences.experience,
            ),
            _buildInfoRow(
              'Current Goal',
              _currentUser.trainingPreferences.goal,
            ),
            _buildInfoRow(
              'Training Days',
              '${_currentUser.trainingPreferences.runDaysPerWeek} days/week',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          Text(value, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildGoalSection() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedBuilder(
          animation: _controller.basicInfoController,
          builder: (context, child) {
            return GoalSelectionComponent(
              controller: _controller,
              customTitle: 'Training Goal',
              showTitle: true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildTrainingFrequency() {
    const List<Map<String, dynamic>> trainingDays = [
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

    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Training Frequency',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller.physicalAttributesController,
              builder: (context, child) {
                return Column(
                  children:
                      trainingDays.map((day) {
                        final isSelected =
                            _controller
                                .physicalAttributesController
                                .runDaysPerWeek ==
                            day['value'];
                        return TrainingDayOption(
                          day: day,
                          isSelected: isSelected,
                          controller: _controller,
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceLevel() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ExperienceLevelSelector(controller: _controller),
      ),
    );
  }

  Widget _buildGoalDate() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goal Event Date (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      _currentUser.trainingPreferences.goalEventDate ??
                      DateTime.now().add(const Duration(days: 84)),
                  firstDate: DateTime.now().add(const Duration(days: 56)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _currentUser = _currentUser.copyWith(
                      trainingPreferences: _currentUser.trainingPreferences
                          .copyWith(goalEventDate: date),
                    );
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.disabled.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.cardBg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentUser.trainingPreferences.goalEventDate != null
                          ? '${_currentUser.trainingPreferences.goalEventDate!.day}/${_currentUser.trainingPreferences.goalEventDate!.month}/${_currentUser.trainingPreferences.goalEventDate!.year}'
                          : 'Select goal event date',
                      style: TextStyle(
                        color:
                            _currentUser.trainingPreferences.goalEventDate !=
                                    null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInjuryNotes() {
    return Card(
      color: AppColors.cardBg,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Injury Notes (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _currentUser.trainingPreferences.injuryNotes,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g., Previous knee injury, ankle weakness...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.disabled.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.disabled.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.cardBg,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 3,
              onChanged: (value) {
                _currentUser = _currentUser.copyWith(
                  trainingPreferences: _currentUser.trainingPreferences
                      .copyWith(injuryNotes: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Update the current user with values from the controller
            final updatedUser = _currentUser.copyWith(
              trainingPreferences: _currentUser.trainingPreferences.copyWith(
                goal: _controller.basicInfoController.selectedGoal,
                runDaysPerWeek:
                    _controller.physicalAttributesController.runDaysPerWeek,
                experience:
                    _controller.healthInfoController.experience ?? 'beginner',
              ),
            );
            widget.onCreatePlan(updatedUser);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome),
            SizedBox(width: 8),
            Text(
              'Generate AI Training Plan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
