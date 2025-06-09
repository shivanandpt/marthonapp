import 'package:cloud_firestore/cloud_firestore.dart';

class BasicInfoModel {
  final String name;
  final String email;
  final DateTime? dob;
  final int age;
  final String gender; // "male", "female", "other"
  final String profilePic;

  const BasicInfoModel({
    required this.name,
    required this.email,
    this.dob,
    this.age = 0,
    this.gender = '',
    this.profilePic = '',
  });

  factory BasicInfoModel.fromMap(Map<String, dynamic> data) {
    return BasicInfoModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      dob: data['dob'] != null ? (data['dob'] as Timestamp).toDate() : null,
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      profilePic: data['profilePic'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'dob': dob,
      'age': age,
      'gender': gender,
      'profilePic': profilePic,
    };
  }

  BasicInfoModel copyWith({
    String? name,
    String? email,
    DateTime? dob,
    int? age,
    String? gender,
    String? profilePic,
  }) {
    return BasicInfoModel(
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}
