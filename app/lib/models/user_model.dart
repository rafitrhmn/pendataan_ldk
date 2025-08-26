// lib/models/user_model.dart

import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String role;
  final String? jabatan;
  final String? noHp; // DITAMBAHKAN: Properti untuk nomor HP

  const UserModel({
    required this.id,
    required this.username,
    required this.role,
    this.jabatan,
    this.noHp, // DITAMBAHKAN: Di dalam constructor
  });

  /// Factory constructor untuk membuat instance UserModel dari data JSON (Map).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      jabatan: json['jabatan'],
      noHp: json['no_hp'], // DITAMBAHKAN: Ambil data 'no_hp' dari Supabase
    );
  }

  /// Properti dari Equatable untuk membandingkan dua objek UserModel.
  @override
  List<Object?> get props => [id, username, role, jabatan, noHp]; // DITAMBAHKAN: 'noHp' ke dalam list
}
