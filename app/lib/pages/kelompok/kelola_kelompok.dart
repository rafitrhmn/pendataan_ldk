// lib/pages/kelola_kelompok_page.dart

import 'dart:async';
import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_event.dart';
import 'package:app/bloc/kelompok/kelompok_state.dart';
import 'package:app/models/kelompok_model.dart';
import 'package:app/widgets/admin_drawer.dart';
import 'package:app/widgets/appbar.dart';
import 'package:app/widgets/kelompok/add_kelompok_dialog.dart';
import 'package:app/widgets/kelompok/delete_kelompok_dialog.dart';
import 'package:app/widgets/kelompok/edit_kelompok_dialog.dart';
import 'package:app/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class KelolaKelompokPage extends StatelessWidget {
  const KelolaKelompokPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => KelompokBloc()..add(FetchKelompok()),
      child: const _KelolaKelompokView(),
    );
  }
}

class _KelolaKelompokView extends StatefulWidget {
  const _KelolaKelompokView({Key? key}) : super(key: key);

  @override
  State<_KelolaKelompokView> createState() => _KelolaKelompokViewState();
}

class _KelolaKelompokViewState extends State<_KelolaKelompokView> {
  // State lokal untuk fungsionalitas search & sort
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      //  AKTIFKAN FUNGSI INI
      context.read<KelompokBloc>().add(SearchKelompok(query));
    });
  }

  void _showAddKelompokDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<KelompokBloc>(context),
        child: const AddKelompokDialog(),
      ),
    );
  }

  // Buat helper untuk memanggil dialog edit
  void _showEditKelompokDialog(Kelompok kelompok) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<KelompokBloc>(context),
        child: EditKelompokDialog(kelompokToEdit: kelompok),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Kelompok kelompok) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<KelompokBloc>(context),
        child: DeleteKelompokDialog(kelompok: kelompok),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(title: 'Kelola Kelompok'),
      drawer: const AdminDrawer(),
      body: BlocListener<KelompokBloc, KelompokState>(
        listener: (context, state) {
          if (state is KelompokError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<KelompokBloc, KelompokState>(
            builder: (context, state) {
              if (state is KelompokLoading || state is KelompokInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is KelompokLoaded) {
                return Column(
                  children: [
                    _buildHeader(state),
                    const SizedBox(height: 16),
                    _buildSearchAndFilter(),
                    const SizedBox(height: 16),
                    _buildKelompokList(state),
                  ],
                );
              }
              if (state is KelompokError) {
                return Center(
                  child: Text('Gagal memuat data: ${state.message}'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(KelompokLoaded state) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Kelompok',
            value: state.allKelompok.length.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(8.0),
            elevation: 2,
            child: InkWell(
              onTap: _showAddKelompokDialog,
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
                        'Tambah Kelompok',
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
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama kelompok...',
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
            setState(() {
              _isSortAscending = !_isSortAscending;
            });
            context.read<KelompokBloc>().add(SortKelompok(_isSortAscending));
          },
          icon: Icon(
            _isSortAscending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          tooltip: _isSortAscending ? 'Urutkan Z-A' : 'Urutkan A-Z',
        ),
      ],
    );
  }

  Widget _buildKelompokList(KelompokLoaded state) {
    if (state.filteredKelompok.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Belum ada data kelompok.')),
      );
    }
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear(); // Hapus teks pencarian saat refresh
          context.read<KelompokBloc>().add(FetchKelompok());
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: state.filteredKelompok.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final kelompok = state.filteredKelompok[index];
            return InkWell(
              onTap: () async {
                //  UBAH AKSI DI SINI: Navigasi ke halaman detail
                final result = await GoRouter.of(
                  context,
                ).push<bool>('/kelola-kelompok/${kelompok.id}');
                // Jika hasilnya adalah 'true', panggil event FetchKelompok
                if (result == true && mounted) {
                  context.read<KelompokBloc>().add(FetchKelompok());
                }
              },
              // borderRadius: BorderRadius.circular(8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                  children: [
                    CircleAvatar(radius: 24, child: Icon(Icons.hub_outlined)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kelompok.namaKelompok,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            // Menampilkan nama mentor dari data join
                            'Mentor: ${kelompok.mentor?.username ?? 'Belum diatur'}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${kelompok.jumlahMentee} Anggota', // Tampilkan jumlah mentee
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          //  PANGGIL METHOD DI SINI
                          _showEditKelompokDialog(kelompok);
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(kelompok);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Hapus'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
