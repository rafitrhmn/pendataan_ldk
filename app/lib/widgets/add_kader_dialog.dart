import 'package:app/bloc/kader/kader_bloc.dart';
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

  // Variabel untuk mengontrol langkah/halaman mana yang aktif
  int _currentStep = 0;

  // 1. Tambahkan state baru untuk mengontrol visibilitas password
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _jabatanController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                    Text(
                      'Tambah data kaderisasi',
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

                // Tampilkan konten sesuai langkah saat ini
                if (_currentStep == 0) _buildStep1() else _buildStep2(),
              ],
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
        TextFormField(
          controller: _usernameController,
          decoration: _buildInputDecoration(
            'Username',
            suffixIcon: Icon(
              Icons.person_outline,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty)
              return 'Username tidak boleh kosong';
            return null;
          },
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
          child: const Text('Lanjut'),
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
                label: const Text('Kembali'),
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
              child: ElevatedButton(
                onPressed: _createAccount,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Buat Akun'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
