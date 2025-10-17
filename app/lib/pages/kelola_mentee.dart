import 'dart:async';
import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentee/mentee_event.dart';
import 'package:app/bloc/mentee/mentee_state.dart';
import 'package:app/models/mentee_model.dart';
import 'package:app/utils/style_decorations.dart';
import 'package:app/widgets/admin_drawer.dart';
import 'package:app/widgets/appbar.dart';
import 'package:app/widgets/mentee/add_mentee_dialog.dart';
import 'package:app/widgets/mentee/delete_mentee_dialog.dart';
import 'package:app/widgets/mentee/edit_mentee_dialog.dart';
import 'package:app/widgets/mentee/view_mentee_dialog.dart';
import 'package:app/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class KelolaMenteePage extends StatelessWidget {
  const KelolaMenteePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenteeBloc()..add(FetchMentees()),
      child: const _KelolaMenteeView(),
    );
  }
}

class _KelolaMenteeView extends StatefulWidget {
  const _KelolaMenteeView({Key? key}) : super(key: key);

  @override
  State<_KelolaMenteeView> createState() => _KelolaMenteeViewState();
}

class _KelolaMenteeViewState extends State<_KelolaMenteeView> {
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
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<MenteeBloc>().add(SearchMentees(query));
    });
  }

  void _showViewMenteeDialog(Mentee mentee) {
    showDialog(
      context: context,
      builder: (_) => ViewMenteeDialog(mentee: mentee),
    );
  }

  void _showAddMenteeDialog() {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<MenteeBloc>(context),
        child: const AddMenteeDialog(),
      ),
    );
  }

  void _showEditMenteeDialog(Mentee mentee) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<MenteeBloc>(context),
        child: EditMenteeDialog(menteeToEdit: mentee),
      ),
    );
  }

  void _showDeleteConfirmationDialog(Mentee mentee) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<MenteeBloc>(context),
        child: DeleteMenteeDialog(mentee: mentee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // GAYA BARU: Latar belakang abu-abu
      appBar: const CustomAppBar(title: 'Kelola Mentee'),
      drawer: const AdminDrawer(),
      body: BlocListener<MenteeBloc, MenteeState>(
        listener: (context, state) {
          if (state is MenteeDeleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mentee berhasil dihapus'),
                backgroundColor: Colors.orange, // Warna oranye untuk delete
              ),
            );
          } else if (state is MenteeError) {
            // Anda bisa juga menangani error umum di sini
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
          child: BlocBuilder<MenteeBloc, MenteeState>(
            builder: (context, state) {
              if (state is MenteeLoading || state is MenteeInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MenteeLoaded) {
                if (state.allMentees.isEmpty) {
                  // ... (tampilan data kosong tidak berubah) ...
                }
                return Column(
                  children: [
                    _buildHeader(state), // GAYA BARU: Header
                    const SizedBox(height: 16),
                    _buildSearchAndFilter(), // GAYA BARU: Search dan Filter
                    const SizedBox(height: 16),
                    _buildMenteeList(state), // GAYA BARU: Tampilan Daftar
                  ],
                );
              }
              if (state is MenteeError) {
                // ... (tampilan error tidak berubah) ...
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      // DIHAPUS: FloatingActionButton tidak lagi digunakan
    );
  }

  // GAYA BARU: Header dengan tombol tambah yang besar
  Widget _buildHeader(MenteeLoaded state) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Mentee',
            value: state.allMentees.length.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(8.0),
            elevation: 2,
            child: InkWell(
              onTap: _showAddMenteeDialog,
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
                        'Tambah Mentee',
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

  // GAYA BARU: Sedikit penyesuaian pada search dan filter
  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: GoogleFonts.openSans(),
            decoration: InputDecoration(
              hintText: 'Cari nama mentee...',
              hintStyle: GoogleFonts.openSans(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200], // Diubah agar lebih kontras
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              _isSortAscending = !_isSortAscending;
            });
            context.read<MenteeBloc>().add(SortMentees(_isSortAscending));
          },
          icon: Icon(
            _isSortAscending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          tooltip: _isSortAscending ? 'Urutkan Z-A' : 'Urutkan A-Z',
        ),
      ],
    );
  }

  Widget _buildMenteeList(MenteeLoaded state) {
    if (state.filteredMentees.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Data mentee tidak ditemukan.')),
      );
    }
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          context.read<MenteeBloc>().add(FetchMentees());
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: state.filteredMentees.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final mentee = state.filteredMentees[index];
            return InkWell(
              onTap: () => _showViewMenteeDialog(mentee),
              borderRadius: BorderRadius.circular(8.0),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris 1: Nama Lengkap
                          Text(
                            mentee.namaLengkap,
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Baris 2: Program Studi
                          Row(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                mentee.prodi,
                                style: GoogleFonts.openSans(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Baris 3: Angkatan
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Angkatan ${mentee.angkatan}',
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
                    // ==========================================================
                    const SizedBox(width: 12),
                    CircularIconButton(
                      icon: Icons.visibility_outlined,
                      onPressed: () => _showViewMenteeDialog(mentee),
                      tooltip: 'Lihat Detail',
                    ),
                    const SizedBox(width: 8),
                    CircularIconButton(
                      icon: Icons.edit_outlined,
                      onPressed: () => _showEditMenteeDialog(mentee),
                      tooltip: 'Edit Mentee',
                    ),
                    const SizedBox(width: 8),
                    CircularIconButton(
                      icon: Icons.delete_outline,
                      onPressed: () => _showDeleteConfirmationDialog(mentee),
                      tooltip: 'Hapus Mentee',
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
