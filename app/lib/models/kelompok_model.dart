// lib/models/kelompok_model.dart

import 'package:app/models/mentor_model.dart';
import 'package:equatable/equatable.dart';

class Kelompok extends Equatable {
  final String id;
  final String namaKelompok;
  final String jadwalPertemuan;
  final String mentorId;
  final DateTime createdAt;
  final MentorModel? mentor; // Bisa menampung data mentor

  const Kelompok({
    required this.id,
    required this.namaKelompok,
    required this.jadwalPertemuan,
    required this.mentorId,
    required this.createdAt,
    this.mentor,
  });

  factory Kelompok.fromJson(Map<String, dynamic> json) {
    return Kelompok(
      id: json['id'],
      namaKelompok: json['nama_kelompok'],
      jadwalPertemuan: json['jadwal_pertemuan'],
      mentorId: json['mentor_id'],
      createdAt: DateTime.parse(json['created_at']),
      // Jika data 'profiles' ada (hasil join), buat objek MentorModel
      mentor: json['profiles'] != null
          ? MentorModel.fromJson(json['profiles'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    namaKelompok,
    jadwalPertemuan,
    mentorId,
    createdAt,
    mentor,
  ];
}
