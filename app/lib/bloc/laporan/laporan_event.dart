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

// Perintah untuk membuat laporan pertemuan baru
class CreateLaporanPertemuan extends LaporanEvent {
  final String kelompokId;
  final DateTime tanggal;
  final String? tempat;
  final String? catatan;
  // final String? fotoUrl; // DIHAPUS
  final List<Map<String, dynamic>> laporanMentees;

  const CreateLaporanPertemuan({
    required this.kelompokId,
    required this.tanggal,
    this.tempat,
    this.catatan,
    // this.fotoUrl, // DIHAPUS
    required this.laporanMentees,
  });
}
