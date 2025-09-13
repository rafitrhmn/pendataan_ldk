import 'dart:async';
import 'package:app/bloc/kader/kader_bloc.dart';
import 'package:app/bloc/kader/kader_event.dart';
import 'package:app/bloc/kader/kader_state.dart';
import 'package:app/models/kader_model.dart';
import 'package:app/utils/icon_style.dart';
import 'package:app/widgets/kader/add_kader_dialog.dart';
import 'package:app/widgets/admin_drawer.dart';
import 'package:app/widgets/appbar.dart';
import 'package:app/widgets/kader/delete_kader_dialog.dart';
import 'package:app/widgets/kader/edit_kader_dialog.dart';
import 'package:app/widgets/kader/view_kader_dialog.dart';
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

  // void _showViewKaderDialog(Kader kader) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => ViewKaderDialog(kader: kader),
  //   );
  // }

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

  void _showDeleteConfirmationDialog(Kader kader) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // BlocProvider.value digunakan untuk 'meneruskan' KaderBloc yang sudah ada
        // ke dalam dialog baru kita, agar dialog tersebut bisa mengirim event.
        return BlocProvider.value(
          value: BlocProvider.of<KaderBloc>(context),
          child: DeleteKaderDialog(kader: kader),
        );
      },
    );
  }

  void _showEditKaderDialog(Kader kader) {
    showDialog(
      context: context,
      // Kita tidak butuh 'dialogContext' di sini, jadi bisa pakai '_'
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<KaderBloc>(context),
        child: EditKaderDialog(kaderToEdit: kader),
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
              fillColor: Colors.grey[200],
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
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: state.filteredCadres.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final kader = state.filteredCadres[index];
          return Container(
            padding: const EdgeInsets.all(
              16,
            ), // Padding diubah sedikit agar simetris
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // 1. Bungkus kolom teks dengan Expanded
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris 1: Username
                      Text(
                        kader.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Baris 2: Nomor HP
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            kader.noHp ?? 'No HP belum diatur',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Baris 3: Jabatan
                      Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            color: Colors.grey[600],
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            kader.jabatan ?? 'Jabatan belum diatur',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                CircularIconButton(
                  icon: Icons.edit_outlined,
                  onPressed: () => _showEditKaderDialog(kader),
                  tooltip: 'Edit Kader',
                ),
                const SizedBox(width: 8),
                CircularIconButton(
                  icon: Icons.delete_outline,
                  onPressed: () => _showDeleteConfirmationDialog(kader),
                  tooltip: 'Hapus Kader',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
