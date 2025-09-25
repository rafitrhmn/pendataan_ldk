import 'dart:async';
import 'package:app/bloc/kader/kader_bloc.dart';
import 'package:app/bloc/kader/kader_state.dart';
import 'package:app/bloc/mentor/mentor_bloc.dart';
import 'package:app/bloc/mentor/mentor_event.dart';
import 'package:app/bloc/mentor/mentor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMentorDialog extends StatefulWidget {
  const AddMentorDialog({super.key});

  @override
  State<AddMentorDialog> createState() => _AddMentorDialogState();
}

class _AddMentorDialogState extends State<AddMentorDialog> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  bool _isPasswordVisible = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.removeListener(_onUsernameChanged);
    _phoneController.dispose();
    _jabatanController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (_usernameController.text.isNotEmpty) {
        context.read<MentorBloc>().add(
          CheckMentorUsername(_usernameController.text),
        );
      }
    });
  }

  InputDecoration _buildInputDecoration(
    String hintText, {
    Widget? suffixIcon,
    bool isEnabled = true,
  }) {
    // ... (Tidak ada perubahan di fungsi helper ini)
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.openSans(
        color: Colors.black.withOpacity(0.5),
        fontSize: 14,
      ),
      filled: true,
      fillColor: isEnabled ? const Color(0x33C4C4C4) : Colors.grey[200],
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

  //  UBAH METHOD _nextStep
  void _nextStep() {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) return;

    final currentState = context.read<MentorBloc>().state;
    if (currentState is MentorUsernameTaken) {
      // Blokir jika username sudah diambil
    } else {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      // DIUBAH: Menggunakan MentorBloc dan CreateMentorAccount
      context.read<MentorBloc>().add(
        CreateMentorAccount(
          username: _usernameController.text,
          phone: _phoneController.text.replaceAll(' ', '').replaceAll('-', ''),
          jabatan: _jabatanController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // DIUBAH: Menggunakan MentorBloc dan MentorState
    return BlocListener<MentorBloc, MentorState>(
      listener: (context, state) {
        if (state is MentorCreated) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Akun untuk mentor ${state.username} berhasil dibuat!',
              ),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
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
                          'Tambah Data Mentor', // DIUBAH
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
                  if (_currentStep == 0) _buildStep1() else _buildStep2(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        // --- WIDGET UNTUK INPUT USERNAME DENGAN VALIDASI REAL-TIME ---
        BlocBuilder<MentorBloc, MentorState>(
          builder: (context, state) {
            Widget? verificationIcon;
            String? errorText;

            // Tentukan ikon verifikasi berdasarkan state BLoC
            if (state is MentorUsernameChecking) {
              verificationIcon = const Padding(
                padding: EdgeInsets.all(14.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            } else if (state is MentorUsernameTaken) {
              verificationIcon = const Icon(
                Icons.error_outline,
                color: Colors.red,
              );
              errorText = state.message;
            } else if (state is MentorUsernameAvailable) {
              verificationIcon = const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _usernameController,
                  autofillHints: const [AutofillHints.username],
                  style: GoogleFonts.openSans(),
                  decoration: _buildInputDecoration(
                    'Username',
                    suffixIcon: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ================== PERBAIKAN DI SINI ==================
                        // Ikon dasar hanya akan terlihat jika TIDAK ada proses verifikasi
                        if (verificationIcon == null)
                          Icon(
                            Icons.person_outline,
                            color: Colors.black.withOpacity(0.5),
                          ),

                        // Ikon verifikasi akan muncul menggantikan ikon dasar
                        if (verificationIcon != null) verificationIcon,
                        // =======================================================
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                    child: Text(
                      errorText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // --- WIDGET UNTUK INPUT NOMOR HANDPHONE ---
        TextFormField(
          controller: _phoneController,
          style: GoogleFonts.openSans(),
          decoration: _buildInputDecoration(
            'Nomor Handphone',
            suffixIcon: Icon(
              Icons.phone_outlined,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nomor handphone tidak boleh kosong';
            }
            final sanitizedPhone = value
                .replaceAll(' ', '')
                .replaceAll('-', '');
            if (sanitizedPhone.length < 10 || sanitizedPhone.length > 13) {
              return 'Nomor HP harus antara 10-13 digit';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // --- WIDGET UNTUK INPUT JABATAN ---
        TextFormField(
          controller: _jabatanController,
          style: GoogleFonts.openSans(),
          decoration: _buildInputDecoration(
            'Jabatan',
            suffixIcon: Icon(
              Icons.work_outline,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jabatan tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),

        // --- TOMBOL LANJUT YANG DINAMIS ---
        BlocBuilder<MentorBloc, MentorState>(
          builder: (context, state) {
            final bool isButtonDisabled =
                state is MentorUsernameChecking || state is MentorUsernameTaken;

            return ElevatedButton(
              onPressed: isButtonDisabled ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: isButtonDisabled
                    ? Colors.grey
                    : Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Lanjut', style: GoogleFonts.openSans(fontSize: 14)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final email =
        '${_usernameController.text.toLowerCase()}@alfaateh.com'; // Anda mungkin ingin mengubah domain ini
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mentor ${_usernameController.text} telah ditambahkan.', // DIUBAH
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Satu langkah lagi untuk membuat akun mentor $email dengan memasukkan password akun.', // DIUBAH
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _usernameController,
          enabled: false,
          style: GoogleFonts.openSans(),
          decoration: _buildInputDecoration(
            'Username',
            suffixIcon: Icon(
              Icons.person_outline,
              color: Colors.black.withOpacity(0.5),
            ),
            isEnabled: false,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: GoogleFonts.openSans(),
          autofillHints: const [AutofillHints.newPassword],
          decoration: _buildInputDecoration(
            'Password',
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black.withOpacity(0.5),
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Password tidak boleh kosong';
            if (value.length < 6) return 'Password minimal 6 karakter';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isPasswordVisible,
          style: GoogleFonts.openSans(),
          autofillHints: const [AutofillHints.newPassword],
          decoration: _buildInputDecoration(
            'Ulangi Password',
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black.withOpacity(0.5),
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text)
              return 'Password tidak cocok';
            return null;
          },
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: Text(
                  'Kembali',
                  style: GoogleFonts.openSans(fontSize: 14),
                ),
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              // DIUBAH: Menggunakan MentorBloc dan MentorState
              child: BlocBuilder<MentorBloc, MentorState>(
                builder: (context, state) {
                  if (state is MentorCreating) {
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
                    onPressed: _createAccount,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Buat Akun',
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
    );
  }
}
