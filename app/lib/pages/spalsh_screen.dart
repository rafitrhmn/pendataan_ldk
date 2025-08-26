import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart'; // Import go_router

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  startSplashScreen() {
    const duration = Duration(seconds: 20);

    return Timer(duration, () {
      // Gunakan context.go() untuk berpindah halaman
      // Ini akan menggantikan tumpukan navigasi, mirip seperti pushReplacement
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // Anda bisa sesuaikan ukuran container ini
              // Di sini saya pakai ukuran asli dari gambar Anda
              width: 261,
              height: 241,
              decoration: ShapeDecoration(
                color: Colors.white, // Latar belakang container
                shape: RoundedRectangleBorder(
                  // Mengatur agar sudut container melingkar
                  borderRadius: BorderRadius.circular(30),
                ),
                shadows: const [
                  // Menambahkan efek bayangan (shadow)
                  BoxShadow(
                    color: Color(
                      0x28000000,
                    ), // Warna bayangan dengan transparansi
                    blurRadius: 4, // Tingkat blur bayangan
                    offset: Offset(0, 1), // Posisi bayangan (x, y)
                    spreadRadius: 0,
                  ),
                ],
              ),
              // ClipRRect penting untuk "memotong" gambar agar sesuai dengan sudut container
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: Image.asset(
                  'assets/images/logo_2.png',
                  // fit: BoxFit.cover membuat gambar memenuhi seluruh area container
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              """Sistem Pendataan 
LDK Al - Faateh""",
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                color: const Color(0xFF3C3C3C),
                fontSize: 22.75,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
