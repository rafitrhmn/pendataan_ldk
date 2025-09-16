import 'package:equatable/equatable.dart';

// lib/models/pertemuan_model.dart

class Pertemuan extends Equatable {
  final String id;
  final String kelompokId;
  final DateTime tanggal;
  final String? tempat;
  // final String? fotoUrl; // DIHAPUS
  final String? catatan;
  final DateTime createdAt;

  const Pertemuan({
    required this.id,
    required this.kelompokId,
    required this.tanggal,
    this.tempat,
    // this.fotoUrl, // DIHAPUS
    this.catatan,
    required this.createdAt,
  });

  factory Pertemuan.fromJson(Map<String, dynamic> json) {
    return Pertemuan(
      id: json['id'],
      kelompokId: json['kelompok_id'],
      tanggal: DateTime.parse(json['tanggal']),
      tempat: json['tempat'],
      // fotoUrl: json['foto_url'], // DIHAPUS
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
    catatan,
    createdAt,
  ]; // DIHAPUS: fotoUrl
}
