// lib/models/kelompok_model.dart

import 'package:app/models/mentor_model.dart';
import 'package:equatable/equatable.dart';

class Kelompok extends Equatable {
  final String id;
  final String namaKelompok;
  final String jadwalPertemuan;
  final String mentorId;
  final DateTime createdAt;
  final MentorModel? mentor;
  final int jumlahMentee;

  const Kelompok({
    required this.id,
    required this.namaKelompok,
    required this.jadwalPertemuan,
    required this.mentorId,
    required this.createdAt,
    this.mentor,
    required this.jumlahMentee,
  });

  // ================== PERBAIKAN UTAMA DI SINI ==================
  factory Kelompok.fromJson(Map<String, dynamic> json) {
    int menteeCount = 0; // 1. Mulai dengan asumsi jumlah mentee adalah 0

    // 2. Lakukan pengecekan keamanan
    if (json['mentee'] != null && json['mentee'] is List) {
      final menteeCountList = json['mentee'] as List;
      if (menteeCountList.isNotEmpty) {
        // 3. Ambil nilai 'count' dari dalam struktur data Supabase
        //    Strukturnya adalah: "mentee": [ { "count": 5 } ]
        menteeCount = menteeCountList.first['count'] ?? 0;
      }
    }

    return Kelompok(
      id: json['id'],
      namaKelompok: json['nama_kelompok'],
      jadwalPertemuan: json['jadwal_pertemuan'],
      mentorId: json['mentor_id'],
      createdAt: DateTime.parse(json['created_at']),
      mentor: json['profiles'] != null
          ? MentorModel.fromJson(json['profiles'])
          : null,
      jumlahMentee:
          menteeCount, // 4. Gunakan nilai yang sudah diproses dengan aman
    );
  }
  // =============================================================

  @override
  List<Object?> get props => [
    id,
    namaKelompok,
    jadwalPertemuan,
    mentorId,
    createdAt,
    mentor,
    jumlahMentee,
  ];
}
