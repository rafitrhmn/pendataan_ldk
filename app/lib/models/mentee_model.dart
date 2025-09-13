// lib/models/mentee_model.dart

import 'package:equatable/equatable.dart';

class Mentee extends Equatable {
  final String id;
  final String namaLengkap;
  final String gender;
  final String prodi;
  final int semester;
  final int angkatan;
  final String? kelompokId; // Bisa null
  final String noHp;
  final DateTime createdAt;

  const Mentee({
    required this.id,
    required this.namaLengkap,
    required this.gender,
    required this.prodi,
    required this.semester,
    required this.angkatan,
    this.kelompokId,
    required this.noHp,
    required this.createdAt,
  });

  factory Mentee.fromJson(Map<String, dynamic> json) {
    return Mentee(
      id: json['id'],
      namaLengkap: json['nama_lengkap'],
      gender: json['gender'],
      prodi: json['prodi'],
      semester: json['semester'],
      angkatan: json['angkatan'],
      kelompokId: json['kelompok_id'],
      noHp: json['no_hp'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    namaLengkap,
    gender,
    prodi,
    semester,
    angkatan,
    kelompokId,
    noHp,
    createdAt,
  ];
}
