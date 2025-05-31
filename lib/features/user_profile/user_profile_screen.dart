// User profile screen for storing and editing user information
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marunthon_app/core/services/user_profile_service.dart';
import 'package:marunthon_app/models/user_profile.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String _weightUnit = 'kg';
  String _heightUnit = 'cm';
  String? _gender;
  String? _raceDistance;
  String? _trainingGoal;
  String? _experienceLevel;
  String? _profilePicPath;
  DateTime? _dob;
  bool _loading = true;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _raceDistances = [
    '5K',
    '10K',
    'Half Marathon',
    'Marathon',
  ];
  final List<String> _trainingGoals = ['Finish', 'Time Goal', 'Personal Best'];
  final List<String> _experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];
  final List<String> _weightUnits = ['kg', 'lb'];
  final List<String> _heightUnits = ['cm', 'in'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    try {
      final profile = await UserProfileService().fetchUserProfile(user.uid);
      print("profile: $profile");
      setState(() {
        if (profile != null) {
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _weightController.text =
              profile.weight > 0 ? profile.weight.toString() : '';
          _heightController.text =
              profile.height > 0 ? profile.height.toString() : '';
          _weightUnit = profile.weightUnit;
          _heightUnit = profile.heightUnit;
          _dob = profile.dob;
          _dobController.text =
              (profile.dob != DateTime(2000))
                  ? DateFormat('yyyy-MM-dd').format(profile.dob)
                  : '';
          _gender = profile.gender;
          _raceDistance = profile.raceDistance;
          _trainingGoal = profile.trainingGoal;
          _experienceLevel = profile.experienceLevel;
          _profilePicPath = user.photoURL;
        } else {
          _nameController.text = user.displayName ?? '';
          _emailController.text = user.email ?? '';
        }
        _loading = false;
      });
    } catch (e) {
      print("Error loading user profile: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickProfilePicture() async {
    // TODO: Implement image picker logic
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_loading) const Center(child: CircularProgressIndicator()),
              if (!_loading) ...[
                Center(
                  child: GestureDetector(
                    onTap: _pickProfilePicture,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage:
                          _profilePicPath != null
                              ? AssetImage(_profilePicPath!)
                              : null,
                      child:
                          _profilePicPath == null
                              ? const Icon(LucideIcons.user, size: 48)
                              : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                ),
                const SizedBox(height: 16),
                // Weight Field with Toggle
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight',
                    suffixText: _weightUnit,
                  ),
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected:
                      _weightUnits.map((u) => u == _weightUnit).toList(),
                  onPressed: (index) {
                    setState(() {
                      _weightUnit = _weightUnits[index];
                    });
                  },
                  children:
                      _weightUnits
                          .map(
                            (u) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(u),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),
                // Height Field with Toggle
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height',
                    suffixText: _heightUnit,
                  ),
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected:
                      _heightUnits.map((u) => u == _heightUnit).toList(),
                  onPressed: (index) {
                    setState(() {
                      _heightUnit = _heightUnits[index];
                    });
                  },
                  children:
                      _heightUnits
                          .map(
                            (u) => Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(u),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Date of Birth'),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value:
                      (_gender != null && _genders.contains(_gender))
                          ? _gender
                          : null,
                  items:
                      _genders
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                  onChanged: (g) => setState(() => _gender = g),
                  decoration: const InputDecoration(labelText: 'Gender'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value:
                      (_raceDistance != null &&
                              _raceDistances.contains(_raceDistance))
                          ? _raceDistance
                          : null,
                  items:
                      _raceDistances
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                  onChanged: (d) => setState(() => _raceDistance = d),
                  decoration: const InputDecoration(
                    labelText: 'Target Race Distance',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value:
                      (_trainingGoal != null &&
                              _trainingGoals.contains(_trainingGoal))
                          ? _trainingGoal
                          : null,
                  items:
                      _trainingGoals
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                  onChanged: (g) => setState(() => _trainingGoal = g),
                  decoration: const InputDecoration(labelText: 'Training Goal'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value:
                      (_experienceLevel != null &&
                              _experienceLevels.contains(_experienceLevel))
                          ? _experienceLevel
                          : null,
                  items:
                      _experienceLevels
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (e) => setState(() => _experienceLevel = e),
                  decoration: const InputDecoration(
                    labelText: 'Experience Level',
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(
                          context,
                        ).colorScheme.primary, // Use primary color
                    foregroundColor:
                        Colors.white, // Optional: ensure text is visible
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) return;
                      final profile = UserProfile(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        weight: double.tryParse(_weightController.text) ?? 0.0,
                        weightUnit: _weightUnit,
                        height: double.tryParse(_heightController.text) ?? 0.0,
                        heightUnit: _heightUnit,
                        dob: _dob,
                        gender: _gender ?? '',
                        raceDistance: _raceDistance ?? '',
                        trainingGoal: _trainingGoal ?? '',
                        experienceLevel: _experienceLevel ?? '',
                        profilePicPath: _profilePicPath,
                      );
                      await UserProfileService().storeUserProfile(
                        user.uid,
                        profile,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile saved!')),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
