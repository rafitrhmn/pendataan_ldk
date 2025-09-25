import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_event.dart';
import 'package:app/bloc/kelompok/kelompok_state.dart';
import 'package:app/bloc/mentor/mentor_bloc.dart';
import 'package:app/bloc/mentor/mentor_event.dart';
import 'package:app/bloc/mentor/mentor_state.dart';
import 'package:app/models/kelompok_model.dart';
import 'package:app/models/mentor_model.dart';
import 'package:app/utils/style_decorations.dart';
import 'package:app/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EditKelompokDialog extends StatefulWidget {
  final Kelompok kelompokToEdit;
  const EditKelompokDialog({super.key, required this.kelompokToEdit});

  @override
  State<EditKelompokDialog> createState() => _EditKelompokDialogState();
}

class _EditKelompokDialogState extends State<EditKelompokDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaController;
  String? _selectedJadwal;
  String? _selectedMentorId;

  @override
  void initState() {
    super.initState();
    context.read<MentorBloc>().add(FetchMentors());

    final kelompok = widget.kelompokToEdit;
    _namaController = TextEditingController(text: kelompok.namaKelompok);
    _selectedJadwal = kelompok.jadwalPertemuan;
    _selectedMentorId = kelompok.mentorId;
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<KelompokBloc>().add(
        UpdateKelompok(
          id: widget.kelompokToEdit.id,
          namaKelompok: _namaController.text,
          jadwalPertemuan: _selectedJadwal!,
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
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Edit Kelompok',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _namaController,
                  style: GoogleFonts.openSans(),
                  decoration: buildInputDecoration(
                    'Nama Kelompok',
                    suffixIcon: Icon(
                      Icons.hub_outlined,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedJadwal,
                  style: GoogleFonts.openSans(),
                  hint: Text(
                    'Pilih Hari Pertemuan',
                    style: GoogleFonts.openSans(fontSize: 14),
                  ),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  items: AppConstants.hariPertemuan.map((String hari) {
                    return DropdownMenuItem<String>(
                      value: hari,
                      child: Text(hari),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedJadwal = value),
                  validator: (v) => v == null ? 'Wajib memilih jadwal' : null,
                  decoration: buildInputDecoration(
                    'Jadwal Pertemuan',
                    suffixIcon: Icon(
                      Icons.calendar_month_outlined,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<MentorBloc, MentorState>(
                  builder: (context, state) {
                    if (state is MentorLoaded) {
                      return DropdownButtonFormField<String>(
                        value: _selectedMentorId,
                        style: GoogleFonts.openSans(),
                        hint: Text(
                          'Pilih Mentor',
                          style: GoogleFonts.openSans(fontSize: 14),
                        ),
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        decoration: buildInputDecoration(
                          'Mentor',
                          suffixIcon: Icon(
                            Icons.school_outlined,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
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
                    if (state is MentorError)
                      return Text('Gagal memuat mentor: ${state.message}');
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.openSans(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BlocBuilder<KelompokBloc, KelompokState>(
                        builder: (context, state) {
                          if (state is KelompokSubmitting) {
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
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              ),
                            );
                          }
                          return ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Simpan Perubahan',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.openSans(fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
