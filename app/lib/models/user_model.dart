// lib/models/user_model.dart

class UserModel {
  final String id;
  final String username;
  final String role;
  final String? jabatan; // Jabatan bisa null

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    this.jabatan,
  });

  // Factory constructor untuk membuat UserModel dari data JSON Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      jabatan: json['jabatan'],
    );
  }
}
