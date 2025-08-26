import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../setttings/supabase_config.dart'; // Pastikan file ini ada dan meng-ekspor 'supabase'

// Definisikan enum untuk peran pengguna agar kode lebih aman dan rapi
enum UserRole { admin, mentor, kaderisasi }

/// Fungsi untuk mendaftarkan pengguna baru dengan peran tertentu.
/// Anda bisa memindahkan ini ke file terpisah (misal: auth_service.dart) agar lebih rapi.
Future<User> signUpWithRole({
  required String username,
  required String password,
  required UserRole role,
}) async {
  final email = '${username.toLowerCase()}@alfaateh.com';
  // 1. Daftarkan pengguna ke sistem Auth
  final authResponse = await supabase.auth.signUp(
    email: email,
    password: password,
  );

  if (authResponse.user == null) {
    throw 'Pendaftaran gagal, pengguna tidak ditemukan.';
  }

  // 2. Simpan profil dan perannya ke tabel 'profiles'
  final roleString = role
      .toString()
      .split('.')
      .last; // Mengubah UserRole.admin -> 'admin'
  await supabase.from('profiles').insert({
    'id': authResponse.user!.id,
    'username': username,
    'role': roleString,
  });

  return authResponse.user!;
}

// --- WIDGET UTAMA ---

class CreateAdminScreen extends StatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  State<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends State<CreateAdminScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  /// Fungsi yang dipanggil saat tombol ditekan.
  /// Logikanya diubah dari sign-in menjadi sign-up.
  Future<void> _createAdminAccount() async {
    // Validasi sederhana agar form tidak kosong
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username dan Password tidak boleh kosong'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil fungsi pendaftaran dengan peran 'admin'
      await signUpWithRole(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        role: UserRole.admin, // Peran 'admin' ditetapkan di sini
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun admin berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        // Kosongkan form setelah berhasil
        _usernameController.clear();
        _passwordController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error Auth: ${error.message}')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi error: $error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Judul diubah
      appBar: AppBar(title: const Text('Buat Akun Admin Baru')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  // Fungsi yang dipanggil diubah
                  onPressed: _createAdminAccount,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  // Teks tombol diubah
                  child: const Text('Buat Akun'),
                ),
        ],
      ),
    );
  }
}
