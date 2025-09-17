// lib/pages/laporan/laporan_detail_page.dart

import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_state.dart';
import 'package:app/bloc/laporan/laporan_bloc.dart';
import 'package:app/bloc/laporan/laporan_event.dart';
import 'package:app/bloc/laporan/laporan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LaporanDetailPage extends StatefulWidget {
  final String pertemuanId;
  const LaporanDetailPage({super.key, required this.pertemuanId});

  @override
  State<LaporanDetailPage> createState() => _LaporanDetailPageState();
}

class _LaporanDetailPageState extends State<LaporanDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<LaporanBloc>().add(FetchLaporanDetail(widget.pertemuanId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: BlocBuilder<LaporanBloc, LaporanState>(
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pertemuan ${DateFormat('d MMMM yyyy').format(pertemuan.tanggal)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 20),
                        if (pertemuan.tempat != null)
                          Text('Tempat: ${pertemuan.tempat}'),
                        if (pertemuan.catatan != null)
                          Text('Catatan: ${pertemuan.catatan}'),
                        if (pertemuan.fotoUrl != null) ...[
                          const SizedBox(height: 10),
                          Image.network(pertemuan.fotoUrl!),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Laporan Keaktifan Anggota',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Daftar Laporan Mentee
                ...laporanMentees.map((laporan) {
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(laporan.mentee?.namaLengkap[0] ?? '?'),
                      ),
                      title: Text(
                        laporan.mentee?.namaLengkap ?? 'Nama tidak ditemukan',
                      ),
                      subtitle: Text(
                        'Sholat: ${laporan.sholatWajib}, Dhuha: ${laporan.sholatDhuha}, Tilawah: ${laporan.tilawahQuran} lbr',
                      ),
                    ),
                  );
                }),
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
                  // Expanded(
                  //   child: ElevatedButton.icon(
                  //     icon: const Icon(Icons.delete_outline),
                  //     label: const Text('Hapus'),
                  //     // onPressed: () => _showDeleteConfirmation(context, state),
                  //     // style: ElevatedButton.styleFrom(
                  //     //   backgroundColor: Colors.red[700],
                  //     // ),
                  //   ),
                  // ),
                ],
              ),
            );
          }
          // Sembunyikan tombol jika state bukan ...Loaded
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
