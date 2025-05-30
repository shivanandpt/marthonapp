class UserModel {
  final String id;
  final String name;
  final String email;
  final String profilePic;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePic,
  });

  // Convert Firestore document to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePic: data['profilePic'] ?? '',
    );
  }

  // Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {'id': id, 'name': name, 'email': email, 'profilePic': profilePic};
  }
}
