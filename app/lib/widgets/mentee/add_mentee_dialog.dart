import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentee/mentee_event.dart';
import 'package:app/bloc/mentee/mentee_state.dart';
import 'package:app/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMenteeDialog extends StatefulWidget {
  const AddMenteeDialog({super.key});

  @override
  State<AddMenteeDialog> createState() => _AddMenteeDialogState();
}

class _AddMenteeDialogState extends State<AddMenteeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _angkatanController = TextEditingController();
  final _noHpController = TextEditingController();
  String? _selectedProdi;
  String? _selectedGender;
  int? _selectedSemester;

  @override
  void dispose() {
    _namaController.dispose();
    _angkatanController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<MenteeBloc>().add(
        CreateMentee(
          namaLengkap: _namaController.text,
          gender: _selectedGender ?? '',
          prodi: _selectedProdi ?? '',
          semester: _selectedSemester ?? 1,
          angkatan: int.tryParse(_angkatanController.text) ?? 0,
          noHp: _noHpController.text.replaceAll(' ', ''),
        ),
      );
    }
  }

  // GAYA BARU: Mengadopsi helper styling dari AddMentorDialog
  InputDecoration _buildInputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.openSans(
        color: Colors.black.withOpacity(0.5),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0x33C4C4C4), // Warna abu-abu transparan
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
        if (state is MenteeCreateSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data mentee berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
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
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // GAYA BARU: Header dengan judul dan tombol close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Tambah Mentee Baru',
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

                  // GAYA BARU: Menggunakan InputDecoration yang sudah disesuaikan
                  TextFormField(
                    controller: _namaController,
                    autofillHints: const [AutofillHints.name],
                    style: GoogleFonts.openSans(),
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
                    style: GoogleFonts.openSans(),
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
                    items: AppConstants.gender.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Wajib memilih Gender' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedProdi,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.openSans(),
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
                    items: AppConstants.programStudi.map((String prodi) {
                      return DropdownMenuItem<String>(
                        value: prodi,
                        child: Text(prodi),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedProdi = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Wajib memilih prodi' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _selectedSemester,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    style: GoogleFonts.openSans(),
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
                    items: AppConstants.semesterOptions.map((int semester) {
                      return DropdownMenuItem<int>(
                        value: semester,
                        child: Text(semester.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedSemester = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Wajib memilih semester' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _angkatanController,
                    style: GoogleFonts.openSans(),
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
                    style: GoogleFonts.openSans(),
                    decoration: _buildInputDecoration(
                      'Nomor HP',
                      suffixIcon: Icon(
                        Icons.phone_outlined,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    // ▼ HAPUS BARIS DI BAWAH INI ▼
                    // inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor handphone tidak boleh kosong';
                      }
                      final sanitizedPhone = value.replaceAll(' ', '');
                      if (sanitizedPhone.length < 10 ||
                          sanitizedPhone.length > 13) {
                        return 'Nomor HP harus antara 10-13 digit';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // GAYA BARU: Tombol dan loading state yang disesuaikan
                  BlocBuilder<MenteeBloc, MenteeState>(
                    builder: (context, state) {
                      if (state is MenteeSubmitting) {
                        return ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
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
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Simpan',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(fontSize: 14),
                        ),
                      );
                    },
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
