import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_state.dart';
import 'package:app/bloc/laporan/laporan_bloc.dart';
import 'package:app/bloc/laporan/laporan_event.dart';
import 'package:app/bloc/laporan/laporan_state.dart';
import 'package:app/widgets/laporan/penilaian_dhuha_input.dart';
import 'package:app/widgets/laporan/penilaian_sholat_input.dart';
import 'package:app/widgets/laporan/penilaian_tilawah_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

String _getPenilaianSholatWajib(int? jumlahDitinggalkan) {
  final int sholatDilaksanakan = 35 - (jumlahDitinggalkan ?? 35);
  if (sholatDilaksanakan >= 34) return 'Unggul';
  if (sholatDilaksanakan >= 30) return 'Sangat Baik';
  if (sholatDilaksanakan >= 25) return 'Baik';
  if (sholatDilaksanakan >= 20) return 'Cukup';
  if (sholatDilaksanakan >= 15) return 'Kurang';
  return 'Sangat Kurang';
}

// Helper untuk mendapatkan level penilaian Sholat Dhuha
String _getPenilaianDhuha(int? jumlahDilaksanakan) {
  final int dhuha = jumlahDilaksanakan ?? 0;
  if (dhuha >= 13) return 'Unggul';
  if (dhuha >= 11) return 'Sangat Baik';
  if (dhuha >= 9) return 'Baik';
  if (dhuha >= 7) return 'Cukup';
  if (dhuha >= 5) return 'Kurang';
  return 'Sangat Kurang';
}

// Helper untuk mendapatkan level penilaian Tilawah
String _getPenilaianTilawah(int? jumlahLembar) {
  final int tilawah = jumlahLembar ?? 0;
  if (tilawah >= 7) return 'Unggul';
  if (tilawah >= 6) return 'Sangat Baik';
  if (tilawah >= 5) return 'Baik';
  if (tilawah >= 4) return 'Cukup';
  if (tilawah >= 2) return 'Kurang';
  // ... sisa logikanya
  return 'Sangat Kurang';
}

class LaporanDetailPage extends StatefulWidget {
  final String pertemuanId;
  const LaporanDetailPage({super.key, required this.pertemuanId});

  @override
  State<LaporanDetailPage> createState() => _LaporanDetailPageState();
}

class _LaporanDetailPageState extends State<LaporanDetailPage> {
  // Helper untuk dialog konfirmasi hapus
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text(
          'Apakah Anda yakin? Laporan yang dihapus tidak dapat dipulihkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<LaporanBloc>().add(
                DeleteLaporanPertemuan(widget.pertemuanId),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    context.read<LaporanBloc>().add(FetchLaporanDetail(widget.pertemuanId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LaporanBloc, LaporanState>(
      listener: (context, state) {
        if (state is LaporanUpdateSuccess || state is LaporanDeleteSuccess) {
          // Kirim sinyal 'true' untuk refresh halaman daftar sebelumnya
          context.pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state is LaporanUpdateSuccess
                    ? 'Laporan berhasil diperbarui!'
                    : 'Laporan berhasil dihapus!',
              ),
              backgroundColor: state is LaporanUpdateSuccess
                  ? Colors.green
                  : Colors.orange,
            ),
          );
        } else if (state is LaporanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          // Menempatkan judul di tengah
          centerTitle: true,
          title: Text(
            'Detail Laporan Pertemuan',
            // Menerapkan font Open Sans
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),

          // Mengatur warna latar dan teks
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: BlocBuilder<LaporanBloc, LaporanState>(
          buildWhen: (previous, current) {
            // Abaikan semua state aksi: submitting, update success, dan delete success
            return current is! LaporanSubmitting &&
                current is! LaporanUpdateSuccess &&
                current is! LaporanDeleteSuccess;
          },
          builder: (context, state) {
            if (state is LaporanDetailLoading || state is LaporanInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is LaporanDetailLoaded) {
              final pertemuan = state.pertemuan;
              final laporanMentees = state.laporanMentees;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Umum Pertemuan
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul Utama
                        Text(
                          'Pertemuan ${DateFormat('d MMMM yyyy', 'id_ID').format(pertemuan.tanggal)}',
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24, thickness: 1),

                        // Detail Tempat
                        _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Tempat',
                          value: pertemuan.tempat ?? 'Tidak disebutkan',
                        ),
                        const SizedBox(height: 12),

                        // Detail Catatan
                        _buildDetailRow(
                          icon: Icons.notes_outlined,
                          label: 'Catatan',
                          value:
                              pertemuan.catatan != null &&
                                  pertemuan.catatan!.isNotEmpty
                              ? pertemuan.catatan!
                              : 'Tidak ada catatan.',
                        ),

                        if (pertemuan.fotoUrl != null) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              12.0,
                            ), // Samakan radiusnya
                            child: Image.network(
                              pertemuan.fotoUrl!,
                              fit: BoxFit.cover, // Pastikan gambar mengisi area
                              // ================== TAMBAHKAN LOGIKA INI ==================
                              loadingBuilder:
                                  (
                                    BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress,
                                  ) {
                                    if (loadingProgress == null) {
                                      // Jika gambar sudah selesai dimuat, tampilkan gambarnya
                                      return child;
                                    }
                                    // Selama gambar masih dimuat, tampilkan loading spinner
                                    return Container(
                                      height:
                                          200, // Beri tinggi agar spinner terlihat
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          // Hitung persen loading jika datanya tersedia
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                              // ==========================================================
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Laporan Keaktifan Anggota',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (laporanMentees.isEmpty)
                    const Center(
                      child: Text(
                        'Tidak ada laporan anggota untuk pertemuan ini.',
                      ),
                    )
                  else
                    Column(
                      children: laporanMentees.map((laporan) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Baris 1: Nama Mentee
                              Text(
                                laporan.mentee?.namaLengkap ??
                                    'Nama tidak ditemukan',
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Divider(height: 20),

                              // Baris 2: Sholat Wajib
                              _buildReportRow(
                                'Sholat Wajib',
                                //  context, // <--- Berikan context di sini
                                '${35 - (laporan.sholatWajib ?? 35)} rakaat', // Menampilkan jumlah yang dikerjakan
                                _getPenilaianSholatWajib(laporan.sholatWajib),
                              ),
                              SizedBox(height: 3),

                              // Baris 3: Sholat Dhuha
                              _buildReportRow(
                                'Sholat Dhuha',
                                '${laporan.sholatDhuha ?? 0} kali',
                                _getPenilaianDhuha(laporan.sholatDhuha),
                              ),
                              SizedBox(height: 3),
                              // Baris 4: Tilawah
                              _buildReportRow(
                                'Tilawah',
                                '${laporan.tilawahQuran ?? 0} lembar',
                                _getPenilaianTilawah(laporan.tilawahQuran),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              );
            }

            if (state is LaporanError) {
              return Center(child: Text('Gagal memuat: ${state.message}'));
            }

            return const Center(child: Text('Terjadi kesalahan'));
          },
        ),
        bottomNavigationBar: BlocBuilder<LaporanBloc, LaporanState>(
          builder: (context, state) {
            // Hanya tampilkan tombol jika data sudah dimuat
            if (state is LaporanDetailLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                        onPressed: () async {
                          final kelompokState = context
                              .read<KelompokBloc>()
                              .state;
                          if (kelompokState is KelompokDetailLoaded) {
                            // 2. Tunggu hasil dari halaman edit
                            final result = await context.push<bool>(
                              '/laporan/edit/${state.pertemuan.id}',
                              extra: {
                                'pertemuan': state.pertemuan,
                                'laporanMentees': state.laporanMentees,
                                'allMenteesInKelompok': kelompokState.mentees,
                              },
                            );

                            // 3. Jika hasilnya true, tampilkan SnackBar & refresh
                            if (result == true && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Laporan berhasil diperbarui!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              // Refresh data di halaman ini
                              context.read<LaporanBloc>().add(
                                FetchLaporanDetail(widget.pertemuanId),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus'),
                        onPressed: _showDeleteConfirmation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            // Sembunyikan tombol jika state bukan ...Loaded
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, String penilaian) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom Label (lebar tetap)
          SizedBox(
            width: 110, // Atur lebar ini agar semua titik dua (:) sejajar
            child: Text(
              '$label :',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
          // Kolom Nilai dan Penilaian
          Expanded(
            child: Text.rich(
              TextSpan(
                style: GoogleFonts.openSans(fontSize: 14),
                children: [
                  TextSpan(text: '$value, '),
                  TextSpan(
                    text: 'Penilaian $penilaian',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    // style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8), // Beri sedikit jarak
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.grey[500], size: 20),
            onPressed: () {
              // Logika untuk menampilkan dialog yang sesuai
              if (label.contains('Wajib')) {
                showDialog(
                  context: context,
                  builder: (context) => const InfoPenilaianDialog(),
                );
              } else if (label.contains('Dhuha')) {
                showDialog(
                  context: context,
                  builder: (context) => const InfoPenilaianDhuhaDialog(),
                );
              } else if (label.contains('Tilawah')) {
                showDialog(
                  context: context,
                  builder: (context) => const InfoPenilaianTilawahDialog(),
                );
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

Widget _buildDetailRow({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.grey[600], size: 20),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.openSans(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.openSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
