import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_event.dart';
import 'package:app/bloc/kelompok/kelompok_state.dart';
import 'package:app/bloc/mentor/mentor_bloc.dart';
import 'package:app/bloc/mentor/mentor_event.dart';
import 'package:app/bloc/mentor/mentor_state.dart';
import 'package:app/models/kelompok_model.dart';
import 'package:app/models/mentor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditKelompokDialog extends StatefulWidget {
  final Kelompok kelompokToEdit;
  const EditKelompokDialog({super.key, required this.kelompokToEdit});

  @override
  State<EditKelompokDialog> createState() => _EditKelompokDialogState();
}

class _EditKelompokDialogState extends State<EditKelompokDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  late final TextEditingController _jadwalController;
  String? _selectedMentorId;

  @override
  void initState() {
    super.initState();
    // Panggil event untuk memastikan daftar mentor terbaru tersedia
    context.read<MentorBloc>().add(FetchMentors());

    // Isi form dengan data yang sudah ada
    final kelompok = widget.kelompokToEdit;
    _namaController = TextEditingController(text: kelompok.namaKelompok);
    _jadwalController = TextEditingController(text: kelompok.jadwalPertemuan);
    _selectedMentorId = kelompok.mentorId;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jadwalController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<KelompokBloc>().add(
        UpdateKelompok(
          id: widget.kelompokToEdit.id,
          namaKelompok: _namaController.text,
          jadwalPertemuan: _jadwalController.text,
          mentorId: _selectedMentorId!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KelompokBloc, KelompokState>(
      listener: (context, state) {
        if (state is KelompokSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kelompok berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is KelompokError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Kelompok',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: 'Nama Kelompok'),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jadwalController,
                  decoration: const InputDecoration(
                    labelText: 'Jadwal Pertemuan',
                  ),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                BlocBuilder<MentorBloc, MentorState>(
                  builder: (context, state) {
                    if (state is MentorLoaded) {
                      return DropdownButtonFormField<String>(
                        value: _selectedMentorId,
                        hint: const Text('Pilih Mentor'),
                        isExpanded: true,
                        items: state.allMentors.map((MentorModel mentor) {
                          return DropdownMenuItem<String>(
                            value: mentor.id,
                            child: Text(mentor.username),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedMentorId = value),
                        validator: (v) =>
                            v == null ? 'Wajib memilih mentor' : null,
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<KelompokBloc, KelompokState>(
                  builder: (context, state) {
                    if (state is KelompokSubmitting) {
                      return const ElevatedButton(
                        onPressed: null,
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Simpan Perubahan'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
