// lib/widgets/circular_icon_button.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip; // Tambahan agar ada tooltip seperti IconButton

  const CircularIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    // Logika dari method _buildCircularIconButton dipindahkan ke sini
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(6), // Sedikit penyesuaian padding
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Icon(icon, size: 20, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}

//dekorasi gaya untuk input fields, tombol, dll.
// Fungsi ini sekarang bisa diakses dari mana saja di dalam project Anda
InputDecoration buildInputDecoration(String hintText, {Widget? suffixIcon}) {
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

//  TAMBAHKAN FUNGSI BARU INI (gaya outline)
InputDecoration buildOutlineInputDecoration(
  BuildContext context, {
  required String labelText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText, // Gunakan labelText agar ada efek animasi
    labelStyle: GoogleFonts.openSans(color: Colors.grey[700]),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

    // Border saat normal
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),

    // Border saat di-klik (fokus)
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
    ),

    // Border saat ada error
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 1.5,
      ),
    ),

    // Border saat fokus dan ada error
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 2.0,
      ),
    ),
  );
}
