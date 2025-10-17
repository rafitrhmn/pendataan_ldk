import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_event.dart';
import 'package:app/bloc/kelompok/kelompok_state.dart';
import 'package:app/bloc/laporan/laporan_bloc.dart';
import 'package:app/bloc/laporan/laporan_event.dart';
import 'package:app/bloc/laporan/laporan_state.dart';
import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentee/mentee_event.dart';
import 'package:app/bloc/mentee/mentee_state.dart';
import 'package:app/models/kelompok_model.dart';
import 'package:app/models/mentee_model.dart';
import 'package:app/widgets/kelompok/add_mentee_to_kelompok.dart';
import 'package:app/widgets/mentee/view_mentee_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Wrapper untuk menyediakan LaporanBloc khusus untuk halaman ini
class KelompokDetailPageWrapper extends StatelessWidget {
  final String kelompokId;
  const KelompokDetailPageWrapper({super.key, required this.kelompokId});

  @override
  Widget build(BuildContext context) {
    // Menyediakan LaporanBloc agar bisa diakses oleh KelompokDetailPage
    return BlocProvider(
      create: (context) => LaporanBloc(),
      child: KelompokDetailPage(kelompokId: kelompokId),
    );
  }
}

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
    context.read<LaporanBloc>().add(FetchRiwayatPertemuan(widget.kelompokId));
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
      builder: (dialogContext) {
        // Menggunakan widget Dialog langsung untuk kustomisasi penuh
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikon untuk visual
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                // Judul
                Text(
                  'Keluarkan Anggota',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Konten/Deskripsi
                Text(
                  'Apakah Anda yakin ingin mengeluarkan "${mentee.namaLengkap}" dari kelompok ini?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.openSans(color: Colors.grey[800]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<MenteeBloc>().add(
                            RemoveMenteeFromKelompok(menteeId: mentee.id),
                          );
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          backgroundColor: Colors
                              .orange, // Warna oranye untuk aksi 'keluarkan'
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text('Keluarkan', style: GoogleFonts.openSans()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Buat helper untuk menampilkan dialog detail mentee
  void _showViewMenteeDialog(Mentee mentee) {
    showDialog(
      context: context,
      builder: (_) => ViewMenteeDialog(mentee: mentee),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghilangkan tombol back default
        elevation: 2,
        backgroundColor: Colors.blue[600],
        foregroundColor:
            Colors.white, // Membuat semua ikon (jika ada) berwarna putih
        title: Row(
          children: [
            // Tombol Kembali yang terlihat seperti teks biasa
            InkWell(
              onTap: () => GoRouter.of(context).pop(true),
              borderRadius: BorderRadius.circular(
                4,
              ), // Memberi efek ripple yang rapi
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 2.0,
                ),
                child: Text(
                  'Kelola Kelompok',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Teks pemisah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Icon(
                Icons.chevron_right,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
            ),
            Text(
              'Detail Kelompok',
              style: GoogleFonts.openSans(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MenteeBloc, MenteeState>(
            listener: (context, state) {
              if (state is MenteeAssignSuccess ||
                  state is MenteeRemoveSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state is MenteeAssignSuccess
                          ? 'Mentee berhasil ditambahkan!'
                          : 'Mentee berhasil dikeluarkan.',
                    ),
                    backgroundColor: const Color.fromARGB(255, 89, 123, 90),
                  ),
                );
                // Refresh data detail kelompok (termasuk daftar anggota)
                context.read<KelompokBloc>().add(
                  FetchKelompokDetail(widget.kelompokId),
                );
              }
            },
          ),
          BlocListener<LaporanBloc, LaporanState>(
            listener: (context, state) {
              if (state is LaporanSubmitSuccess) {
                // Refresh riwayat pertemuan setelah laporan berhasil dibuat
                context.read<LaporanBloc>().add(
                  FetchRiwayatPertemuan(widget.kelompokId),
                );
              }
            },
          ),
        ],
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
                    const SizedBox(height: 10),
                    _buildKelompokDetailCard(kelompok, mentees),
                    const SizedBox(height: 20),

                    // Header Daftar Anggota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Anggota Kelompok',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Tambah'),
                          onPressed: _showAddMenteeToKelompokDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildMenteeList(mentees),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riwayat Pertemuan',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Laporan Baru'),
                          onPressed: () {
                            context.push('/laporan/add', extra: state);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildRiwayatPertemuanList(),
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

  Widget _buildKelompokDetailCard(Kelompok kelompok, List<Mentee> mentees) {
    // DIUBAH: Menggunakan Container untuk styling kustom
    return Container(
      padding: const EdgeInsets.all(20.0), // Padding dipindahkan ke Container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          12.0,
        ), // Radius diubah sedikit agar lebih halus
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Detail Kelompok',
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            children: [
              // Kolom Kiri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow(
                      label: 'Nama Kelompok',
                      value: kelompok.namaKelompok,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Jadwal Kelompok',
                      value: kelompok.jadwalPertemuan,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Kolom Kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow(
                      label: 'Mentor',
                      value: kelompok.mentor?.username ?? 'Belum Diatur',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      label: 'Total Mentee',
                      value: '${mentees.length} Orang',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenteeList(List<Mentee> mentees) {
    if (mentees.isEmpty) {
      // Tampilan jika tidak ada anggota tidak perlu diubah, sudah baik
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(child: Text('Belum ada anggota di kelompok ini.')),
      );
    }

    // Gunakan Column daripada ListView karena parent-nya sudah ListView
    return Column(
      children: mentees.map((mentee) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            onTap: () => _showViewMenteeDialog(mentee),
            borderRadius: BorderRadius.circular(12.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mentee.namaLengkap,
                          //
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              mentee.prodi,
                              style: GoogleFonts.openSans(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              ' | ${mentee.angkatan}',
                              style: GoogleFonts.openSans(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _showRemoveConfirmationDialog(mentee);
                    },
                    tooltip: 'Keluarkan dari kelompok',
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRiwayatPertemuanList() {
    return BlocBuilder<LaporanBloc, LaporanState>(
      builder: (context, state) {
        if (state is RiwayatPertemuanLoaded) {
          if (state.riwayat.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Belum ada laporan pertemuan.')),
            );
          }
          // Gunakan Column agar tidak ada error scrolling di dalam ListView
          return Column(
            children: state.riwayat.map((pertemuan) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () async {
                    final result = await context.push<bool>(
                      '/kelola-kelompok/${widget.kelompokId}/laporan/${pertemuan.id}',
                    );
                    if (result == true && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Aksi pada laporan berhasil!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.read<LaporanBloc>().add(
                        FetchRiwayatPertemuan(widget.kelompokId),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.book_outlined, color: Colors.blue),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Pertemuan ${DateFormat('d MMMM yyyy', 'id_ID').format(pertemuan.tanggal)}',
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// Helper untuk membuat baris detail
Widget _buildDetailRow({required String label, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.openSans(color: Colors.grey[600], fontSize: 14),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: GoogleFonts.openSans(fontSize: 16, fontWeight: FontWeight.bold),
        // style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
