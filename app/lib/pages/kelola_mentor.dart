import 'dart:async';
import 'package:app/bloc/mentor/mentor_bloc.dart'; // DIUBAH
import 'package:app/bloc/mentor/mentor_event.dart'; // DIUBAH
import 'package:app/bloc/mentor/mentor_state.dart'; // DIUBAH
import 'package:app/models/mentor_model.dart'; // DIUBAH
import 'package:app/widgets/admin_drawer.dart';
import 'package:app/widgets/appbar.dart';
import 'package:app/widgets/mentor/add_mentor_dialog.dart';
import 'package:app/widgets/mentor/delete_mentor_dialog.dart';
import 'package:app/widgets/mentor/edit_mentor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/stat_card.dart';

// DIUBAH: Nama class dari KelolaKader -> KelolaMentor
class KelolaMentor extends StatelessWidget {
  const KelolaMentor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // DIUBAH: Menggunakan MentorBloc dan event FetchMentors
      create: (context) => MentorBloc()..add(FetchMentors()),
      child: const _KelolaMentorView(),
    );
  }
}

// DIUBAH: Nama class dari _KelolaKaderView -> _KelolaMentorView
class _KelolaMentorView extends StatefulWidget {
  const _KelolaMentorView({Key? key}) : super(key: key);

  @override
  State<_KelolaMentorView> createState() => __KelolaMentorViewState();
}

// DIUBAH: Nama class dari __KelolaKaderViewState -> __KelolaMentorViewState
class __KelolaMentorViewState extends State<_KelolaMentorView> {
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
      // DIUBAH: Mengirim event SearchMentors
      context.read<MentorBloc>().add(SearchMentors(query));
    });
  }

  // DIUBAH: Semua fungsi dialog disesuaikan untuk Mentor
  void _showAddMentorDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: BlocProvider.of<MentorBloc>(context),
          child: const AddMentorDialog(), // DIUBAH
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(MentorModel mentor) {
    // DIUBAH
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<MentorBloc>(context),
          child: DeleteMentorDialog(mentor: mentor), // DIUBAH
        );
      },
    );
  }

  void _showEditMentorDialog(MentorModel mentor) {
    // DIUBAH
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<MentorBloc>(context),
        child: EditMentorDialog(mentorToEdit: mentor), // DIUBAH
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // DIUBAH: Menggunakan MentorBloc dan MentorState
    return BlocListener<MentorBloc, MentorState>(
      listener: (context, state) {
        // DIUBAH: State menjadi MentorDeleteSuccess
        if (state is MentorDeleteSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              // DIUBAH: Teks notifikasi
              content: Text('Mentor berhasil dihapus'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        // DIUBAH: Judul AppBar
        appBar: const CustomAppBar(title: 'Kelola Mentor'),
        drawer: const AdminDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          // DIUBAH: Menggunakan MentorBloc dan MentorState
          child: BlocBuilder<MentorBloc, MentorState>(
            builder: (context, state) {
              // DIUBAH: State menjadi MentorLoading, MentorInitial
              if (state is MentorLoading || state is MentorInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              // DIUBAH: State menjadi MentorLoaded
              else if (state is MentorLoaded) {
                if (state.allMentors.isEmpty) {
                  // DIUBAH
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum ada data mentor"), // DIUBAH
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Mentor Pertama'), // DIUBAH
                          onPressed: _showAddMentorDialog,
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
                    _buildMentorList(state), // DIUBAH
                  ],
                );
              }
              // DIUBAH: State menjadi MentorError
              else if (state is MentorError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(MentorLoaded state) {
    // DIUBAH
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total Mentor', // DIUBAH
            value: state.allMentors.length.toString(), // DIUBAH
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: Colors.blue[600],
            borderRadius: BorderRadius.circular(8.0),
            elevation: 2,
            child: InkWell(
              onTap: _showAddMentorDialog,
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
                        'Tambah Mentor', // DIUBAH
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
              hintText: 'Cari nama mentor...', // DIUBAH
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
            // DIUBAH: Mengirim event SortMentors
            context.read<MentorBloc>().add(SortMentors(_isSortAscending));
          },
          icon: Icon(
            _isSortAscending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          tooltip: _isSortAscending ? 'Urutkan Z-A' : 'Urutkan A-Z',
        ),
      ],
    );
  }

  Widget _buildCircularIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    // Tidak ada perubahan di sini, ini adalah widget generik
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade700),
      ),
    );
  }

  // DIUBAH: Nama fungsi dari _buildKaderList -> _buildMentorList
  Widget _buildMentorList(MentorLoaded state) {
    // DIUBAH: Menggunakan filteredMentors
    if (state.filteredMentors.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Data mentor tidak ditemukan.')), // DIUBAH
      );
    }
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 6),
        // DIUBAH: Menggunakan filteredMentors
        itemCount: state.filteredMentors.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          // DIUBAH: Tipe data menjadi MentorModel
          final mentor = state.filteredMentors[index];
          return Container(
            padding: EdgeInsets.only(left: 16, right: 16, top: 18, bottom: 18),
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
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      // DIUBAH: Menggunakan data mentor
                      child: Text(mentor.username[0].toUpperCase()),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentor.username, // DIUBAH
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                'Hp: ${mentor.noHp ?? 'No HP belum diatur'}', // DIUBAH
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ' | ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                mentor.jabatan ??
                                    'Jabatan belum diatur', // DIUBAH
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildCircularIconButton(
                      icon: Icons.edit_outlined,
                      onPressed: () {
                        _showEditMentorDialog(mentor); // DIUBAH
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildCircularIconButton(
                      icon: Icons.delete_outline,
                      onPressed: () {
                        _showDeleteConfirmationDialog(mentor); // DIUBAH
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
