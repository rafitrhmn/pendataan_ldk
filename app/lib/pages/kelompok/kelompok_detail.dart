// lib/pages/kelompok/kelompok_detail_page.dart

import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_event.dart';
import 'package:app/bloc/kelompok/kelompok_state.dart';
import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentee/mentee_event.dart';
import 'package:app/bloc/mentee/mentee_state.dart';
import 'package:app/models/kelompok_model.dart';
import 'package:app/models/mentee_model.dart';
import 'package:app/widgets/kelompok/add_mentee_to_kelompok.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class KelompokDetailPage extends StatefulWidget {
  final String kelompokId;

  const KelompokDetailPage({super.key, required this.kelompokId});

  @override
  State<KelompokDetailPage> createState() => _KelompokDetailPageState();
}

class _KelompokDetailPageState extends State<KelompokDetailPage> {
  @override
  void initState() {
    super.initState();
    // Memanggil event untuk mengambil data detail saat halaman pertama kali dibuka
    context.read<KelompokBloc>().add(FetchKelompokDetail(widget.kelompokId));
  }

  // Helper untuk menampilkan dialog tambah anggota
  void _showAddMenteeToKelompokDialog() {
    showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: BlocProvider.of<KelompokBloc>(context)),
          BlocProvider.value(value: BlocProvider.of<MenteeBloc>(context)),
        ],
        child: AddMenteeToKelompokDialog(kelompokId: widget.kelompokId),
      ),
    );
  }

  void _showRemoveConfirmationDialog(Mentee mentee) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluarkan Anggota'),
        content: Text(
          'Apakah Anda yakin ingin mengeluarkan "${mentee.namaLengkap}" dari kelompok ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              // Kirim event ke MenteeBloc
              context.read<MenteeBloc>().add(
                RemoveMenteeFromKelompok(menteeId: mentee.id),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Keluarkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('Detail Kelompok'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: BlocListener<MenteeBloc, MenteeState>(
        // Listener untuk Aksi dari MenteeBloc (misal: setelah berhasil assign)
        listener: (context, state) {
          if (state is MenteeAssignSuccess || state is MenteeRemoveSuccess) {
            // Jika berhasil assign ATAU remove, refresh data detail kelompok
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is MenteeAssignSuccess
                      ? 'Mentee berhasil ditambahkan!'
                      : 'Mentee berhasil dikeluarkan.',
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.read<KelompokBloc>().add(
              FetchKelompokDetail(widget.kelompokId),
            );
          }
        },
        child: BlocBuilder<KelompokBloc, KelompokState>(
          builder: (context, state) {
            if (state is KelompokDetailLoading || state is KelompokInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KelompokDetailLoaded) {
              final kelompok = state.kelompok;
              final mentees = state.mentees;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<KelompokBloc>().add(
                    FetchKelompokDetail(widget.kelompokId),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildKelompokDetailCard(kelompok, mentees),
                    const SizedBox(height: 24),

                    // Header Daftar Anggota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Anggota Kelompok',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Tambah'),
                          onPressed: _showAddMenteeToKelompokDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Daftar Anggota Mentee
                    if (mentees.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text('Belum ada anggota di kelompok ini.'),
                        ),
                      )
                    else
                      _buildMenteeList(mentees),
                  ],
                ),
              );
            }

            if (state is KelompokError) {
              return Center(
                child: Text('Gagal memuat detail: ${state.message}'),
              );
            }

            return const Center(child: Text('Terjadi kesalahan.'));
          },
        ),
      ),
    );
  }

  // Widget untuk kartu detail kelompok
  Widget _buildKelompokDetailCard(Kelompok kelompok, List<Mentee> mentees) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              label: 'Nama Kelompok',
              value: kelompok.namaKelompok,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              label: 'Mentor',
              value: kelompok.mentor?.username ?? 'Belum Diatur',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              label: 'Jadwal Pertemuan',
              value: kelompok.jadwalPertemuan,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              label: 'Total Anggota',
              value:
                  '${mentees.length} Mentee', // Ambil jumlah dari list mentees
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk daftar mentee
  Widget _buildMenteeList(List<Mentee> mentees) {
    return ListView.separated(
      physics:
          const NeverScrollableScrollPhysics(), // Agar bisa di-scroll oleh parent ListView
      shrinkWrap: true,
      itemCount: mentees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final mentee = mentees[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(child: Text(mentee.namaLengkap[0])),
            title: Text(mentee.namaLengkap),
            subtitle: Text(mentee.prodi),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                _showRemoveConfirmationDialog(mentee);
              },
              tooltip: 'Keluarkan dari kelompok',
            ),
          ),
        );
      },
    );
  }

  // Helper untuk membuat baris detail
  Widget _buildDetailRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
