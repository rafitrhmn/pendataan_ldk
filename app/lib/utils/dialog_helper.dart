import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

// Fungsi untuk menampilkan dialog status (sukses atau gagal)
void showStatusDialog(
  BuildContext context, {
  required bool isSuccess,
  required String title,
  required String message,
}) {
  // URL Lottie dari LottieFiles.com
  final successAnimation =
      'https://lottie.host/9c3c5598-6a36-4959-a9a3-53ae84158580/p1n4Yd8n9H.json';
  final failureAnimation =
      'https://lottie.host/7033519c-9b8c-40c2-9097-e737155018a3/g5a3mYfYG8.json';

  showDialog(
    context: context,
    builder: (context) {
      // Menutup dialog secara otomatis setelah 3 detik
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pop();
      });

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              isSuccess ? successAnimation : failureAnimation,
              width: 120,
              height: 120,
              repeat: false, // Animasi hanya diputar sekali
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Fungsi terpisah untuk menampilkan dialog loading
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Pengguna tidak bisa menutup dialog ini
    builder: (context) {
      return const Center(child: CircularProgressIndicator());
    },
  );
}
