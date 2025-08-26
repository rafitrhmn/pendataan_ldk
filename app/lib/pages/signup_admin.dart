import 'package:app/setttings/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- BAGIAN KONFIGURASI & INISIALISASI ---

Future<void> main() async {
  // Pastikan Flutter siap sebelum menjalankan kode async
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  // Panggil fungsi inisialisasi Supabase
  await initializeSupabase();

  runApp(const MyApp());
}

// Definisikan instance Supabase client agar bisa diakses di seluruh aplikasi
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create User App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // Halaman pertama yang akan ditampilkan adalah CreateUserScreen
      home: const CreateUserScreen(),
    );
  }
}

// --- LOGIKA & FUNGSI BERSAMA ---

// Enum untuk peran pengguna tetap kita gunakan, ini praktik yang bagus
enum UserRole { admin, mentor, kaderisasi }

/// Fungsi untuk mendaftarkan pengguna baru dengan peran tertentu.
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
  final roleString = role.toString().split('.').last;
  await supabase.from('profiles').insert({
    'id': authResponse.user!.id,
    'username': username,
    'role': roleString,
  });

  return authResponse.user!;
}

// --- WIDGET HALAMAN UTAMA ---

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  UserRole _selectedRole = UserRole.kaderisasi; // Nilai default

  Future<void> _createUserAccount() async {
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
      await signUpWithRole(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Akun ${_selectedRole.name} berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
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
      appBar: AppBar(title: const Text('Buat Akun Pengguna Baru')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            decoration: const InputDecoration(labelText: 'Pilih Peran'),
            items: UserRole.values.map((UserRole role) {
              return DropdownMenuItem<UserRole>(
                value: role,
                child: Text(
                  role.name[0].toUpperCase() + role.name.substring(1),
                ),
              );
            }).toList(),
            onChanged: (UserRole? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRole = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _createUserAccount,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Buat Akun'),
                ),
        ],
      ),
    );
  }
}
