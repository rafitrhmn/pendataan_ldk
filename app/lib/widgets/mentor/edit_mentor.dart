import 'package:app/bloc/mentor/mentor_bloc.dart';
import 'package:app/bloc/mentor/mentor_event.dart';
import 'package:app/bloc/mentor/mentor_state.dart';
import 'package:app/models/mentor_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// DIUBAH: Nama class
class EditMentorDialog extends StatefulWidget {
  // DIUBAH: Tipe data menjadi MentorModel
  final MentorModel mentorToEdit;

  const EditMentorDialog({super.key, required this.mentorToEdit});

  @override
  State<EditMentorDialog> createState() => _EditMentorDialogState();
}

class _EditMentorDialogState extends State<EditMentorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jabatanController;

  @override
  void initState() {
    super.initState();
    // Mengisi controller dengan data mentor yang akan diedit
    _usernameController = TextEditingController(
      text: widget.mentorToEdit.username,
    );
    _phoneController = TextEditingController(text: widget.mentorToEdit.noHp);
    _jabatanController = TextEditingController(
      text: widget.mentorToEdit.jabatan,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hintText, {Widget? suffixIcon}) {
    // Tidak ada perubahan di fungsi helper ini
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // DIUBAH: Mengirim event UpdateMentor ke MentorBloc
      context.read<MentorBloc>().add(
        UpdateMentor(
          id: widget.mentorToEdit.id,
          newUsername: _usernameController.text,
          newPhone: _phoneController.text,
          newJabatan: _jabatanController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // DIUBAH: Mendengar MentorBloc dan MentorState
    return BlocListener<MentorBloc, MentorState>(
      listener: (context, state) {
        if (state is MentorUpdateSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is MentorError) {
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
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Data Mentor', // DIUBAH
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
                  controller: _usernameController,
                  decoration: _buildInputDecoration(
                    'Username',
                    suffixIcon: Icon(
                      Icons.person_outline,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Username tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: _buildInputDecoration(
                    'Nomor Handphone',
                    suffixIcon: Icon(
                      Icons.phone_outlined,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Nomor handphone tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jabatanController,
                  decoration: _buildInputDecoration(
                    'Jabatan',
                    suffixIcon: Icon(
                      Icons.work_outline,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Jabatan tidak boleh kosong'
                      : null,
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
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      // DIUBAH: Menggunakan MentorBloc dan state MentorUpdating
                      child: BlocBuilder<MentorBloc, MentorState>(
                        builder: (context, state) {
                          if (state is MentorUpdating) {
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
    );
  }
}
