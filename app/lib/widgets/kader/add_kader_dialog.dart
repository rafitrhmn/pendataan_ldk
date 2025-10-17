import 'dart:async';
import 'package:app/bloc/kader/kader_bloc.dart';
import 'package:app/bloc/kader/kader_event.dart';
import 'package:app/bloc/kader/kader_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddKaderDialog extends StatefulWidget {
  const AddKaderDialog({super.key});

  @override
  State<AddKaderDialog> createState() => _AddKaderDialogState();
}

class _AddKaderDialogState extends State<AddKaderDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk SEMUA input dari kedua langkah
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  Timer? _debounce; //  TAMBAHKAN INI untuk debounce

  // Variabel untuk mengontrol langkah/halaman mana yang aktif
  int _currentStep = 0;

  // 1. Tambahkan state baru untuk mengontrol visibilitas password
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk debounce pengecekan username
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    _phoneController.dispose();
    _jabatanController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Fungsi untuk debounce pengecekan username
  void _onUsernameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), () {
      if (_usernameController.text.isNotEmpty) {
        context.read<KaderBloc>().add(
          CheckKaderUsername(_usernameController.text),
        );
      }
    });
  }

  // 2. Ubah helper method agar bisa menerima widget, bukan hanya IconData
  InputDecoration _buildInputDecoration(
    String hintText, {
    Widget? suffixIcon,
    bool isEnabled = true,
  }) {
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
      suffixIcon: suffixIcon, // Gunakan widget yang diberikan
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      // Jika validasi langkah 1 berhasil, pindah ke langkah 2
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
      // 🔽 BARIS INI KITA AKTIFKAN 🔽
      context.read<KaderBloc>().add(
        CreateKaderAccount(
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
    return BlocListener<KaderBloc, KaderState>(
      listener: (context, state) {
        if (state is KaderCreated) {
          // Jika sukses, tutup dialog
          Navigator.of(context).pop();
          // Tampilkan pesan sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Akun untuk ${state.username} berhasil dibuat!'),
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header (Judul & Tombol Close)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Tambah data kaderisasi',
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

                  // Tampilkan konten sesuai langkah saat ini
                  if (_currentStep == 0) _buildStep1() else _buildStep2(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget untuk konten Langkah 1
  Widget _buildStep1() {
    return Column(
      children: [
        BlocBuilder<KaderBloc, KaderState>(
          builder: (context, state) {
            Widget? suffixIcon = Icon(
              Icons.person_outline,
              color: Colors.black.withOpacity(0.5),
            );

            if (state is KaderUsernameChecking) {
              suffixIcon = const Padding(
                padding: EdgeInsets.all(14.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            } else if (state is KaderUsernameTaken) {
              suffixIcon = const Icon(Icons.error_outline, color: Colors.red);
            } else if (state is KaderUsernameAvailable) {
              suffixIcon = const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _usernameController,
                  style: GoogleFonts.openSans(),
                  decoration: _buildInputDecoration(
                    'Username',
                    suffixIcon: suffixIcon,
                  ), // .copyWith(errorText) DIHAPUS dari sini
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                // BARU: Menampilkan pesan error sebagai widget Text terpisah
                if (state is KaderUsernameTaken)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 12.0),
                    child: Text(
                      state.message,
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
            if (value == null || value.isEmpty)
              return 'Nomor handphone tidak boleh kosong';
            final sanitizedPhone = value
                .replaceAll(' ', '')
                .replaceAll('-', '');
            if (sanitizedPhone.length < 11 || sanitizedPhone.length > 13) {
              return 'Nomor HP harus 11, 12, atau 13 digit';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
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
            if (value == null || value.isEmpty)
              return 'Jabatan tidak boleh kosong';
            return null;
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _nextStep,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text('Lanjut', style: GoogleFonts.openSans(fontSize: 14)),
        ),
      ],
    );
  }

  // Widget untuk konten Langkah 2
  Widget _buildStep2() {
    final email = '${_usernameController.text.toLowerCase()}@alfaateh.com';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kaderisasi ${_usernameController.text} telah ditambahkan.',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Satu langkah lagi untuk membuat akun kaderisasi $email dengan memasukkan password akun.',
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[700]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _usernameController,
          enabled: false, // Tidak bisa diubah
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
          obscureText: !_isPasswordVisible, // Gunakan state, bukan 'true'
          // TAMBAHKAN BARIS INI: Beri tahu browser ini adalah password baru
          autofillHints: const [AutofillHints.newPassword],
          style: GoogleFonts.openSans(),
          decoration: _buildInputDecoration(
            'Password',
            suffixIcon: IconButton(
              icon: Icon(
                // Ganti ikon berdasarkan state
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black.withOpacity(0.5),
              ),
              onPressed: () {
                // Ubah state di dalam setState
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
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
          obscureText: !_isPasswordVisible, // Gunakan state yang sama
          // TAMBAHKAN BARIS INI: Beri tahu browser ini adalah password baru
          autofillHints: const [AutofillHints.newPassword],
          style: GoogleFonts.openSans(),
          decoration: _buildInputDecoration(
            'Ulangi Password',
            // Berikan juga IconButton di sini
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black.withOpacity(0.5),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
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
              child: BlocBuilder<KaderBloc, KaderState>(
                // 👈 Bungkus dengan BlocBuilder
                builder: (context, state) {
                  // Jika state adalah KaderCreating, tampilkan loading
                  if (state is KaderCreating) {
                    return ElevatedButton(
                      onPressed: null, // Non-aktifkan tombol saat loading
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        backgroundColor: Colors.grey, // Ubah warna jadi abu-abu
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

                  // Jika tidak loading, tampilkan tombol seperti biasa
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
