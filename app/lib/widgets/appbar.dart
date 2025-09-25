import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// Widget AppBar harus mengimplementasikan PreferredSizeWidget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.openSans(
          // Menggunakan font Open Sans
          color: Colors.black87, // Ganti warna agar kontras dengan latar putih
          fontWeight: FontWeight.w600,
        ),
      ), // Menggunakan title dari parameter
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: InkWell(
            onTap: () {
              // Navigasi ke halaman profil
              GoRouter.of(context).go('/profile');
            },
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              backgroundColor: Colors.blue[50],
              child: Icon(Icons.admin_panel_settings, color: Colors.blue[600]),
            ),
          ),
        ),
      ],
    );
  }

  // Ini wajib ada saat membuat AppBar kustom
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
