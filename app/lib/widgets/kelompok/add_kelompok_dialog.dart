// lib/widgets/kelompok/add_kelompok_dialog.dart

import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_event.dart';
import 'package:app/bloc/kelompok/kelompok_state.dart';
import 'package:app/bloc/mentor/mentor_bloc.dart';
import 'package:app/bloc/mentor/mentor_event.dart';
import 'package:app/bloc/mentor/mentor_state.dart';
import 'package:app/models/mentor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddKelompokDialog extends StatefulWidget {
  const AddKelompokDialog({super.key});

  @override
  State<AddKelompokDialog> createState() => _AddKelompokDialogState();
}

class _AddKelompokDialogState extends State<AddKelompokDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jadwalController = TextEditingController();
  String? _selectedMentorId;

  @override
  void initState() {
    super.initState();
    // Secara aktif meminta daftar mentor saat dialog dibuka
    context.read<MentorBloc>().add(FetchMentors());
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jadwalController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<KelompokBloc>().add(
        CreateKelompok(
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
              content: Text('Kelompok berhasil dibuat!'),
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
                // ... (Header dialog seperti biasa) ...
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
                // Dropdown untuk memilih mentor
                BlocBuilder<MentorBloc, MentorState>(
                  builder: (context, state) {
                    // Kondisi jika terjadi error saat memuat mentor
                    if (state is MentorError) {
                      return Text('Gagal memuat mentor: ${state.message}');
                    }

                    // Kondisi jika data mentor sudah berhasil dimuat
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

                    // Kondisi default (saat MentorInitial atau MentorLoading)
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
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Simpan'),
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
