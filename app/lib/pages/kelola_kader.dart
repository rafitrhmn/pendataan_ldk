import 'package:app/widgets/add_kader_dialog.dart';
import 'package:app/widgets/admin_drawer.dart';
import 'package:app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/kader/kader_bloc.dart';
import 'dart:async';

import '../widgets/stat_card.dart';

class KelolaKaderPage extends StatefulWidget {
  const KelolaKaderPage({super.key});

  @override
  State<KelolaKaderPage> createState() => _KelolaKaderPageState();
}

class _KelolaKaderPageState extends State<KelolaKaderPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Ambil data saat halaman dibuka
    context.read<KaderBloc>().add(FetchKaderList());

    // Listener untuk search "modern" (debounce)
    _searchController.addListener(_onSearchChanged);
  }

  // Fungsi debounce agar BLoC tidak dipanggil setiap ketukan keyboard
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<KaderBloc>().add(SearchKader(_searchController.text));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Membungkus Scaffold dengan BlocListener untuk menangani feedback
    // seperti SnackBar tanpa perlu membangun ulang seluruh UI.
    return BlocListener<KaderBloc, KaderState>(
      listener: (context, state) {
        // Jika akun berhasil dibuat...
        if (state is KaderCreationSuccess) {
          // Cek apakah ada dialog yang terbuka, lalu tutup.
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          // Tampilkan pesan sukses menggunakan SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Akun kader berhasil dibuat!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Jika akun gagal dibuat...
        if (state is KaderCreationFailure) {
          // Tampilkan pesan error.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: const CustomAppBar(title: 'Kelola Kader'),
        drawer: const AdminDrawer(),
        // Stack digunakan untuk menumpuk widget. Di sini kita menumpuk
        // konten utama dengan sebuah overlay loading.
        body: Stack(
          children: [
            // Widget utama yang membangun daftar kader
            BlocBuilder<KaderBloc, KaderState>(
              builder: (context, state) {
                if (state is KaderLoading || state is KaderInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is KaderError) {
                  return Center(child: Text(state.message));
                }
                if (state is KaderLoaded) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildHeader(state),
                        const SizedBox(height: 16),
                        _buildSearchAndFilter(),
                        const SizedBox(height: 16),
                        _buildKaderList(state),
                      ],
                    ),
                  );
                }
                // State default jika tidak ada yang cocok
                return const SizedBox.shrink();
              },
            ),
            // Widget kedua di dalam Stack: Overlay loading
            // Ini hanya akan muncul saat state adalah KaderCreationLoading
            BlocBuilder<KaderBloc, KaderState>(
              builder: (context, state) {
                if (state is KaderCreationLoading) {
                  return Container(
                    // Warna semi-transparan untuk menutupi layar di belakangnya
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  );
                }
                // Jika state bukan loading, tampilkan widget kosong
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BAGIAN-BAGIAN UI ---

  Widget _buildHeader(KaderLoaded state) {
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          children: [
            // Panggil widget StatCard yang baru di sini
            Expanded(
              // Expanded agar kartu mengisi ruang yang tersedia
              child: StatCard(
                title: 'Total Kaderisasi',
                value: state.allCadres.length.toString(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Material(
                // 1. Dekorasi (warna & bentuk) sekarang diatur di widget Material
                color: Colors.blue[600],
                borderRadius: BorderRadius.circular(8.0),
                // Kita juga bisa memindahkan shadow ke sini jika perlu
                elevation: 2, // Memberi sedikit efek terangkat
                shadowColor: Colors.black.withOpacity(0.2),

                // 2. InkWell ditempatkan di dalam Material untuk menangani sentuhan
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddKaderDialog();
                      },
                    );
                  },
                  // 3. Pastikan borderRadius di sini sama agar bentuk riak sesuai
                  borderRadius: BorderRadius.circular(8.0),
                  // 4. (Opsional) Kustomisasi warna riak agar terlihat lebih bagus di atas biru
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),

                  // Container sekarang hanya untuk mengatur layout (padding, tinggi, dll)
                  child: Container(
                    height: 92,
                    padding: const EdgeInsets.all(12.0),
                    // Warna di container dihapus agar tidak menutupi ripple dari InkWell
                    color: Colors.transparent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 28, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            'Tambah Kaderisasi',
                            style: GoogleFonts.openSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama kader...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            // TODO: Tampilkan dialog/menu untuk opsi sorting
            // Contoh: Panggil event untuk sort A-Z
            context.read<KaderBloc>().add(const SortKader(true));
          },
          icon: const Icon(Icons.sort),
          tooltip: 'Urutkan',
        ),
      ],
    );
  }

  Widget _buildKaderList(KaderLoaded state) {
    if (state.filteredCadres.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Data kader tidak ditemukan.')),
      );
    }
    return Expanded(
      child: ListView.separated(
        itemCount: state.filteredCadres.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final kader = state.filteredCadres[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(kader.username[0].toUpperCase()),
              ),
              title: Text(
                kader.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(kader.jabatan ?? 'Jabatan belum diatur'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
