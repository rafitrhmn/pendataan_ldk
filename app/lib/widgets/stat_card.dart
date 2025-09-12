// WIDGET BARU UNTUK KARTU STATISTIK (LEBIH BERSIH & REUSABLE)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bagian Kiri: Judul dan Angka
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.openSans(
                  color: const Color(0xFF565656),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.openSans(
                  color: const Color(0xFF3E3E3E),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
