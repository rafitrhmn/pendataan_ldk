import 'package:app/supabase_config.dart';
import 'package:flutter/material.dart';
import 'app_router.dart'; // Import konfigurasi router kita

Future<void> main() async {
  // Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Panggil fungsi inisialisasi Supabase
  await initializeSupabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan MaterialApp.router untuk mengaktifkan go_router
    return MaterialApp.router(
      title: 'Aplikasi Flutter Saya',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Gunakan routerConfig untuk menghubungkan konfigurasi router
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
