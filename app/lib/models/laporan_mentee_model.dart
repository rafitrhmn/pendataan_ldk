// lib/models/laporan_mentee_model.dart

import 'package:app/models/mentee_model.dart'; // Import model Mentee
import 'package:equatable/equatable.dart';

class LaporanMentee extends Equatable {
  final String id;
  final String pertemuanId;
  final String menteeId;
  final bool hadir;
  final int? sholatWajib;
  final int? sholatDhuha;
  final int? tilawahQuran;
  final Mentee? mentee; // Untuk menampung data join dari tabel mentee

  const LaporanMentee({
    required this.id,
    required this.pertemuanId,
    required this.menteeId,
    required this.hadir,
    this.sholatWajib,
    this.sholatDhuha,
    this.tilawahQuran,
    this.mentee,
  });

  factory LaporanMentee.fromJson(Map<String, dynamic> json) {
    return LaporanMentee(
      id: json['id'],
      pertemuanId: json['pertemuan_id'],
      menteeId: json['mentee_id'],
      hadir: json['hadir'],
      sholatWajib: json['sholat_wajib'],
      sholatDhuha: json['sholat_dhuha'],
      tilawahQuran: json['tilawah_quran'],
      mentee: json['mentee'] != null ? Mentee.fromJson(json['mentee']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    pertemuanId,
    menteeId,
    hadir,
    sholatWajib,
    sholatDhuha,
    tilawahQuran,
    mentee,
  ];
}
