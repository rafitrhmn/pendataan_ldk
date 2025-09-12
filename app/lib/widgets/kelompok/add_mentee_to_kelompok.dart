import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_event.dart';
import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentee/mentee_event.dart';
import 'package:app/bloc/mentee/mentee_state.dart';
import 'package:app/models/mentee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        title: const Text('Tambah Anggota Mentee'),
        content: BlocBuilder<MenteeBloc, MenteeState>(
          builder: (context, state) {
            if (state is UnassignedMenteesLoaded) {
              if (state.mentees.isEmpty) {
                return const Text('Semua mentee sudah memiliki kelompok.');
              }
              return DropdownButton<String>(
                value: _selectedMenteeId,
                isExpanded: true,
                hint: const Text('Pilih Mentee'),
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          BlocBuilder<MenteeBloc, MenteeState>(
            builder: (context, state) {
              if (state is MenteeSubmitting) {
                return const ElevatedButton(
                  onPressed: null,
                  child: Text('Menyimpan...'),
                );
              }
              return ElevatedButton(
                onPressed: _selectedMenteeId == null ? null : _submit,
                child: const Text('Simpan'),
              );
            },
          ),
        ],
      ),
    );
  }
}
