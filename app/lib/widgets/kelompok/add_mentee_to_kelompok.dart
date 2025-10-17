import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_event.dart';
import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentee/mentee_event.dart';
import 'package:app/bloc/mentee/mentee_state.dart';
import 'package:app/models/mentee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMenteeToKelompokDialog extends StatefulWidget {
  final String kelompokId;
  const AddMenteeToKelompokDialog({super.key, required this.kelompokId});

  @override
  State<AddMenteeToKelompokDialog> createState() =>
      _AddMenteeToKelompokDialogState();
}

class _AddMenteeToKelompokDialogState extends State<AddMenteeToKelompokDialog> {
  String? _selectedMenteeId;

  @override
  void initState() {
    super.initState();
    // Ambil daftar mentee yang belum punya kelompok
    context.read<MenteeBloc>().add(FetchUnassignedMentees());
  }

  void _submit() {
    if (_selectedMenteeId != null) {
      context.read<MenteeBloc>().add(
        AssignMenteeToKelompok(
          menteeId: _selectedMenteeId!,
          kelompokId: widget.kelompokId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MenteeBloc, MenteeState>(
      listener: (context, state) {
        if (state is MenteeAssignSuccess) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mentee berhasil ditambahkan ke kelompok!'),
              backgroundColor: Colors.green,
            ),
          );
          // Memicu refresh di halaman detail kelompok
          context.read<KelompokBloc>().add(
            FetchKelompokDetail(widget.kelompokId),
          );
        } else if (state is MenteeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AlertDialog(
        title: Text(
          'Tambah Anggota Mentee',
          style: GoogleFonts.openSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        content: BlocBuilder<MenteeBloc, MenteeState>(
          builder: (context, state) {
            if (state is UnassignedMenteesLoaded) {
              if (state.mentees.isEmpty) {
                return const Text('Semua mentee sudah memiliki kelompok.');
              }
              return DropdownButton<String>(
                value: _selectedMenteeId,
                dropdownColor: Colors.white,
                isExpanded: true,
                style: GoogleFonts.openSans(fontSize: 14),
                hint: Text(
                  'Pilih Mentee',
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
                items: state.mentees.map((Mentee mentee) {
                  return DropdownMenuItem<String>(
                    value: mentee.id,
                    child: Text(mentee.namaLengkap),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedMenteeId = value),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        actions: [
          // Tombol Batal dengan gaya OutlinedButton
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 50), // Menyesuaikan tinggi
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
          const SizedBox(width: 12), // Jarak antar tombol
          // Tombol Simpan/Aksi dengan gaya ElevatedButton
          Expanded(
            child: BlocBuilder<MenteeBloc, MenteeState>(
              builder: (context, state) {
                // Kondisi loading
                if (state is MenteeSubmitting) {
                  return ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                // Kondisi normal/aktif
                return ElevatedButton(
                  onPressed: _selectedMenteeId == null ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Simpan', style: GoogleFonts.openSans()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
