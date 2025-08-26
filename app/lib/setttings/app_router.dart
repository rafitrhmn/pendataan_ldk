// Konfigurasi GoRouter
import 'package:app/pages/login.dart';
import 'package:app/pages/spalsh_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  // initialLocation akan menentukan rute awal saat aplikasi dibuka
  initialLocation: '/',
  routes: [
    // Rute untuk Splash Screen
    GoRoute(
      path: '/', // Path URL untuk halaman ini
      builder: (context, state) =>
          const SplashScreen(), // Widget yang akan ditampilkan
    ),
    // Rute untuk Login Screen
    GoRoute(
      path: '/login', // Path URL untuk halaman ini
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
