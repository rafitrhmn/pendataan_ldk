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
    const duration = Duration(seconds: 10);

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
            Image.asset('assets/images/logo_2.png', height: 241, width: 261),
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
