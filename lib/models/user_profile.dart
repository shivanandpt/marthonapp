// User profile model for marathon training with Firebase serialization
class UserProfile {
  String name;
  String email;
  double weight;
  String weightUnit; // 'kg' or 'lb'
  double height;
  String heightUnit; // 'cm' or 'in'
  DateTime dob;
  String gender;
  String raceDistance;
  String trainingGoal;
  String experienceLevel;
  String? profilePicPath;

  UserProfile({
    required this.name,
    required this.email,
    this.weight = 0.0,
    this.weightUnit = 'kg',
    this.height = 0.0,
    this.heightUnit = 'cm',
    DateTime? dob,
    this.gender = '',
    this.raceDistance = '',
    this.trainingGoal = '',
    this.experienceLevel = '',
    this.profilePicPath,
  }) : dob = dob ?? DateTime(2000);

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      weight: (map['weight'] ?? 0).toDouble(),
      weightUnit: map['weightUnit'] ?? 'kg',
      height: (map['height'] ?? 0).toDouble(),
      heightUnit: map['heightUnit'] ?? 'cm',
      dob: map['dob'] != null ? DateTime.parse(map['dob']) : DateTime(2000),
      gender: map['gender'] ?? '',
      raceDistance: map['raceDistance'] ?? '',
      trainingGoal: map['trainingGoal'] ?? '',
      experienceLevel: map['experienceLevel'] ?? '',
      profilePicPath: map['profilePicPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'weight': weight,
      'weightUnit': weightUnit,
      'height': height,
      'heightUnit': heightUnit,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'raceDistance': raceDistance,
      'trainingGoal': trainingGoal,
      'experienceLevel': experienceLevel,
      'profilePicPath': profilePicPath,
    };
  }
}
