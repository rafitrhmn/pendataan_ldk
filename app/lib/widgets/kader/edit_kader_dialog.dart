// edit_kader_dialog.dart

import 'package:app/bloc/kader/kader_bloc.dart';
import 'package:app/bloc/kader/kader_event.dart';
import 'package:app/bloc/kader/kader_state.dart';
import 'package:app/models/kader_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EditKaderDialog extends StatefulWidget {
  final Kader kaderToEdit;

  const EditKaderDialog({super.key, required this.kaderToEdit});

  @override
  State<EditKaderDialog> createState() => _EditKaderDialogState();
}

class _EditKaderDialogState extends State<EditKaderDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jabatanController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.kaderToEdit.username,
    );
    _phoneController = TextEditingController(text: widget.kaderToEdit.noHp);
    _jabatanController = TextEditingController(
      text: widget.kaderToEdit.jabatan,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _jabatanController.dispose();
    super.dispose();
  }

  // REKOMENDASI: Tambahkan helper styling dari AddKaderDialog
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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<KaderBloc>().add(
        UpdateKader(
          id: widget.kaderToEdit.id,
          newUsername: _usernameController.text,
          newPhone: _phoneController.text,
          newJabatan: _jabatanController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KaderBloc, KaderState>(
      listener: (context, state) {
        if (state is KaderUpdateSuccess) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is KaderError) {
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
          child: AutofillGroup(
            onDisposeAction: AutofillContextAction
                .cancel, // Batalkan autofill saat dialog ditutup
            child: Form(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // REKOMENDASI: Tambahkan Header yang konsisten
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Data Kader',
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

                    // REKOMENDASI: Gunakan styling yang sama untuk TextFormField
                    TextFormField(
                      controller: _usernameController,
                      autofillHints: const [AutofillHints.name],
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
                      autofillHints: const [AutofillHints.telephoneNumber],
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
                      autofillHints: const [AutofillHints.jobTitle],
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

                    // REKOMENDASI: Gunakan layout tombol yang sama
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
                          child: BlocBuilder<KaderBloc, KaderState>(
                            builder: (context, state) {
                              if (state is KaderUpdating) {
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
                                child: const Text('Simpan Perubahan'),
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
      ),
    );
  }
}
