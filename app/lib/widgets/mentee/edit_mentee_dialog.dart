// lib/widgets/mentee/edit_mentee_dialog.dart

import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentee/mentee_event.dart';
import 'package:app/bloc/mentee/mentee_state.dart';
import 'package:app/models/mentee_model.dart';
import 'package:app/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EditMenteeDialog extends StatefulWidget {
  final Mentee menteeToEdit;
  const EditMenteeDialog({super.key, required this.menteeToEdit});

  @override
  State<EditMenteeDialog> createState() => _EditMenteeDialogState();
}

class _EditMenteeDialogState extends State<EditMenteeDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _angkatanController;
  late final TextEditingController _noHpController;

  // DIUBAH: Menggunakan state untuk dropdown
  String? _selectedProdi;
  String? _selectedGender;
  int? _selectedSemester;

  @override
  void initState() {
    super.initState();
    final mentee = widget.menteeToEdit;
    _namaController = TextEditingController(text: mentee.namaLengkap);
    _angkatanController = TextEditingController(
      text: mentee.angkatan.toString(),
    );
    _noHpController = TextEditingController(text: mentee.noHp);

    // Mengisi state dropdown dengan data awal
    _selectedProdi = mentee.prodi;
    _selectedGender = mentee.gender;
    _selectedSemester = mentee.semester;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _angkatanController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<MenteeBloc>().add(
        UpdateMentee(
          id: widget.menteeToEdit.id,
          namaLengkap: _namaController.text,
          gender: _selectedGender ?? '',
          prodi: _selectedProdi ?? '',
          semester: _selectedSemester ?? 1,
          angkatan: int.tryParse(_angkatanController.text) ?? 0,
          noHp: _noHpController.text,
        ),
      );
    }
  }

  // GAYA BARU: Helper styling yang konsisten
  InputDecoration _buildInputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.openSans(
        color: Colors.black.withOpacity(0.5),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0x33C4C4C4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 24.0,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MenteeBloc, MenteeState>(
      listener: (context, state) {
        // Kondisi saat aksi BERHASIL
        if (state is MenteeUpdateSuccess) {
          // 1. Tutup dialog
          Navigator.of(context).pop();
          // 2. Tampilkan notifikasi sukses
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data mentee berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Kondisi saat aksi GAGAL
        else if (state is MenteeError) {
          // Tampilkan notifikasi error
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
          child: AutofillGroup(
            // GAYA BARU: Mencegah prompt "Simpan Password"
            onDisposeAction: AutofillContextAction.cancel,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GAYA BARU: Header yang konsisten
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit Data Mentee',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                    autofillHints: const [AutofillHints.name],
                    decoration: _buildInputDecoration(
                      'Nama Lengkap',
                      suffixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    decoration: _buildInputDecoration(
                      'Gender',
                      suffixIcon: Icon(
                        Icons.wc_outlined,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    hint: Text(
                      'Pilih Gender',
                      style: GoogleFonts.openSans(fontSize: 14),
                    ),
                    items: AppConstants.gender
                        .map(
                          (String gender) => DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) =>
                        setState(() => _selectedGender = newValue),
                    validator: (value) =>
                        value == null ? 'Wajib memilih gender' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedProdi,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    decoration: _buildInputDecoration(
                      'Program Studi',
                      suffixIcon: Icon(
                        Icons.school_outlined,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    hint: Text(
                      'Pilih Program Studi',
                      style: GoogleFonts.openSans(fontSize: 14),
                    ),
                    items: AppConstants.programStudi
                        .map(
                          (String prodi) => DropdownMenuItem<String>(
                            value: prodi,
                            child: Text(prodi),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) =>
                        setState(() => _selectedProdi = newValue),
                    validator: (value) =>
                        value == null ? 'Wajib memilih prodi' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    value: _selectedSemester,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    decoration: _buildInputDecoration(
                      'Semester',
                      suffixIcon: Icon(
                        Icons.format_list_numbered,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    hint: Text(
                      'Pilih Semester',
                      style: GoogleFonts.openSans(fontSize: 14),
                    ),
                    items: AppConstants.semesterOptions
                        .map(
                          (int semester) => DropdownMenuItem<int>(
                            value: semester,
                            child: Text(semester.toString()),
                          ),
                        )
                        .toList(),
                    onChanged: (int? newValue) =>
                        setState(() => _selectedSemester = newValue),
                    validator: (value) =>
                        value == null ? 'Wajib memilih semester' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _angkatanController,
                    autofillHints: const [
                      AutofillHints.creditCardExpirationYear,
                    ], // Hint yang mendekati
                    decoration: _buildInputDecoration(
                      'Angkatan',
                      suffixIcon: Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _noHpController,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: _buildInputDecoration(
                      'Nomor HP',
                      suffixIcon: Icon(
                        Icons.phone_outlined,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 32),

                  // GAYA BARU: Layout tombol aksi yang konsisten
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
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: BlocBuilder<MenteeBloc, MenteeState>(
                          builder: (context, state) {
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
                              child: const Text(
                                'Simpan Perubahan',
                                textAlign: TextAlign.center,
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
      ),
    );
  }
}
