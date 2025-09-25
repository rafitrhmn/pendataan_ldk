import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth/auth_bloc.dart'; // Import AuthBloc

class ProfilePage extends StatelessWidget {
  // Bisa diubah menjadi StatelessWidget
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan BlocBuilder untuk mendapatkan state dari AuthBloc
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Tampilkan loading atau pesan jika user belum terautentikasi
        if (state.status != AuthStatus.authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika user sudah terautentikasi, kita punya datanya
        final user = state.user!;

        return Scaffold(
          backgroundColor: Colors.grey[100],

          appBar: AppBar(
            // ... [properti appbar lainnya] ...
            // DITAMBAHKAN: Ikon panah kembali di sebelah kiri
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation:
                0, // Opsional: Anda mungkin ingin menghilangkan bayangan agar terlihat bersih

            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black, // Pastikan warna ikon sesuai dengan judul
              ),
              onPressed: () {
                // Fungsi untuk kembali ke halaman sebelumnya
                GoRouter.of(context).go('/dashadmin');
              },
            ),

            title: Text(
              // UBAH JUDUL SESUAI ROLE
              'Profile ${user.role[0].toUpperCase()}${user.role.substring(1)}',
              // textAlign: TextAlign,
              style: GoogleFonts.openSans(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfilePicture(),
                const SizedBox(height: 30),

                // GUNAKAN DATA DARI BLOC, BUKAN HARDCODED
                _buildInfoField(label: 'Username', value: user.username),
                const SizedBox(height: 20),
                _buildInfoField(label: 'No HandPhone', value: user.noHp ?? ''),
                const SizedBox(height: 20),

                // Tampilkan Jabatan HANYA JIKA ADA (untuk kader)
                if (user.jabatan != null && user.jabatan!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: _buildInfoField(
                      label: 'Jabatan',
                      value: user.jabatan!,
                    ),
                  ),

                _buildInfoField(label: 'Role', value: user.role),

                const SizedBox(height: 40), // Jarak ke tombol
                // DITAMBAHKAN: Baris untuk dua tombol di bawah
                _buildLogoutButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // DIUBAH: Widget ini sekarang hanya membuat satu tombol Logout
  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout, size: 18),
      label: Text('Logout', style: GoogleFonts.openSans(fontSize: 16)),
      onPressed: () {
        // Memicu event logout dari AuthBloc
        context.read<AuthBloc>().add(AuthLogoutRequested());

        // TODO: Navigasi kembali ke halaman login setelah logout
        GoRouter.of(context).go('/login');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        minimumSize: const Size(
          double.infinity,
          50,
        ), // Membuat tombol selebar layar
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  // Widget untuk Foto Profil dengan Ikon Kamera
  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.network(
              'https://picsum.photos/120', // URL baru dari Lorem Picsum
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF5F6FA), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget bantuan untuk membuat setiap field info agar tidak berulang
  Widget _buildInfoField({
    required String label,
    required String value,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.openSans(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              if (suffixIcon != null) Icon(suffixIcon, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  // ... [Taruh helper widget seperti _buildProfilePicture dan _buildInfoField di sini] ...
}
