// kelola_kader.dart

import 'dart:async';
import 'package:app/bloc/kader/kader_bloc.dart';
import 'package:app/bloc/kader/kader_event.dart';
import 'package:app/bloc/kader/kader_state.dart';
import 'package:app/models/kader_model.dart';
import 'package:app/widgets/add_kader_dialog.dart';
import 'package:app/widgets/admin_drawer.dart';
import 'package:app/widgets/appbar.dart';
import 'package:app/widgets/edit_kader_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/stat_card.dart';

class KelolaKader extends StatelessWidget {
  const KelolaKader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // REKOMENDASI 1: Gunakan BlocProvider untuk membuat dan menyediakan KaderBloc
    // BLoC akan dibuat saat widget ini dibangun dan ditutup otomatis saat tidak dibutuhkan.
    return BlocProvider(
      create: (context) => KaderBloc()..add(FetchKaderisasi()),
      child: const _KelolaKaderView(), // Pecah UI ke widget terpisah
    );
  }
}

// Widget ini berisi UI utama dan bisa mengakses BLoC dari atas
class _KelolaKaderView extends StatefulWidget {
  const _KelolaKaderView({Key? key}) : super(key: key);

  @override
  State<_KelolaKaderView> createState() => __KelolaKaderViewState();
}

class __KelolaKaderViewState extends State<_KelolaKaderView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi debounce untuk optimasi pencarian
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<KaderBloc>().add(SearchKader(query));
    });
  }

  // Helper untuk menampilkan dialog dengan benar
  void _showAddKaderDialog() {
    showDialog(
      context: context,
      builder: (_) {
        // 'context' utama (dari halaman) sudah memiliki KaderBloc
        // BlocProvider.value akan meneruskannya ke context dialog
        return BlocProvider.value(
          value: BlocProvider.of<KaderBloc>(context),
          child: const AddKaderDialog(),
        );
      },
    );
  }

  // Method baru di dalam __KelolaKaderViewState
  void _showDeleteConfirmationDialog(Kader kader) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Kader'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kader bernama "${kader.username}"? Aksi ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Kirim event hapus ke BLoC
              context.read<KaderBloc>().add(DeleteKader(id: kader.id));
              Navigator.of(dialogContext).pop(); // Tutup dialog
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KaderBloc, KaderState>(
      listener: (context, state) {
        if (state is KaderDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kader berhasil dihapus'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        // Anda juga bisa menambahkan listener untuk create & update di sini jika mau
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: const CustomAppBar(title: 'Kelola Kader'),
        drawer: const AdminDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<KaderBloc, KaderState>(
            builder: (context, state) {
              if (state is KaderLoading || state is KaderInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is KaderLoaded) {
                if (state.allCadres.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum ada kaderisasi"),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Kader Pertama'),
                          onPressed: _showAddKaderDialog,
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(state),
                    const SizedBox(height: 16),
                    _buildSearchAndFilter(),
                    const SizedBox(height: 16),
                    _buildKaderList(state),
                  ],
                );
              } else if (state is KaderError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(KaderLoaded state) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Kaderisasi',
            value: state.allCadres.length.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(8.0),
            elevation: 2,
            child: InkWell(
              onTap: _showAddKaderDialog, // Panggil helper
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                height: 92,
                padding: const EdgeInsets.all(12.0),
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
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged, // Optimasi dengan debounce
            decoration: InputDecoration(
              hintText: 'Cari nama kader...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            // Logika untuk toggle sort
            setState(() {
              _isSortAscending = !_isSortAscending;
            });
            context.read<KaderBloc>().add(SortKader(_isSortAscending));
          },
          icon: Icon(
            _isSortAscending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          tooltip: _isSortAscending ? 'Urutkan Z-A' : 'Urutkan A-Z',
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
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    // Kode ini sudah benar.
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        // 1. Mencari KaderBloc yang ada di halaman utama.
                        value: BlocProvider.of<KaderBloc>(context),
                        // 2. Meneruskannya ke EditKaderDialog dan mengirim data kader.
                        child: EditKaderDialog(kaderToEdit: kader),
                      ),
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(kader);
                  }
                },
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
