// lib/models/pertemuan_model.dart

import 'package:equatable/equatable.dart';

class Pertemuan extends Equatable {
  final String id;
  final String kelompokId;
  final DateTime tanggal;
  final String? tempat;
  final String? fotoUrl; //  TAMBAHKAN KEMBALI
  final String? catatan;
  final DateTime createdAt;

  const Pertemuan({
    required this.id,
    required this.kelompokId,
    required this.tanggal,
    this.tempat,
    this.fotoUrl, //  TAMBAHKAN KEMBALI
    this.catatan,
    required this.createdAt,
  });

  factory Pertemuan.fromJson(Map<String, dynamic> json) {
    return Pertemuan(
      id: json['id'],
      kelompokId: json['kelompok_id'],
      tanggal: DateTime.parse(json['tanggal']),
      tempat: json['tempat'],
      fotoUrl: json['foto_url'], //  TAMBAHKAN KEMBALI
      catatan: json['catatan'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    kelompokId,
    tanggal,
    tempat,
    fotoUrl,
    catatan,
    createdAt,
  ]; //  TAMBAHKAN KEMBALI
}
