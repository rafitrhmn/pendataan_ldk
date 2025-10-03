import 'package:equatable/equatable.dart';

abstract class LaporanEvent extends Equatable {
  const LaporanEvent();
  @override
  List<Object?> get props => [];
}

// Perintah untuk mengambil riwayat pertemuan sebuah kelompok
class FetchRiwayatPertemuan extends LaporanEvent {
  final String kelompokId;
  const FetchRiwayatPertemuan(this.kelompokId);
}

class CreateLaporanPertemuan extends LaporanEvent {
  final String kelompokId;
  final DateTime tanggal;
  final String? tempat;
  final String? catatan;
  final String? fotoUrl; //  TAMBAHKAN KEMBALI
  final List<Map<String, dynamic>> laporanMentees;

  const CreateLaporanPertemuan({
    required this.kelompokId,
    required this.tanggal,
    this.tempat,
    this.catatan,
    this.fotoUrl, //  TAMBAHKAN KEMBALI
    required this.laporanMentees,
  });
}

class FetchLaporanDetail extends LaporanEvent {
  final String pertemuanId;
  const FetchLaporanDetail(this.pertemuanId);
}

// lib/bloc/laporan/laporan_event.dart

class UpdateLaporanPertemuan extends LaporanEvent {
  final String pertemuanId;
  final DateTime tanggal;
  final String? tempat;
  final String? catatan;
  final String? fotoUrl; // URL baru
  final String? oldFotoUrl; //  TAMBAHKAN INI
  final List<Map<String, dynamic>> laporanMentees;

  const UpdateLaporanPertemuan({
    required this.pertemuanId,
    required this.tanggal,
    this.tempat,
    this.catatan,
    this.fotoUrl,
    this.oldFotoUrl, //  TAMBAHKAN INI
    required this.laporanMentees,
  });
}

class DeleteLaporanPertemuan extends LaporanEvent {
  final String pertemuanId;
  const DeleteLaporanPertemuan(this.pertemuanId);
}
