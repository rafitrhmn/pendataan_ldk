// Konfigurasi GoRouter
import 'package:app/pages/dashbod_admin.dart';
import 'package:app/pages/kelola_kader.dart';
import 'package:app/pages/kelompok/kelola_kelompok.dart';
import 'package:app/pages/kelola_mentee.dart';
import 'package:app/pages/kelola_mentor.dart';
import 'package:app/pages/kelompok/kelompok_detail.dart';
// import 'package:app/pages/kelola_kader.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/profile_admin.dart';
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
    GoRoute(
      path: '/dashadmin', // Path URL untuk halaman ini
      builder: (context, state) => const AdminDashboardPage(),
    ),
    GoRoute(
      path: '/profile', // Path URL untuk halaman ini
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/kelola-kader',
      builder: (context, state) => const KelolaKader(),
    ),
    GoRoute(
      path: '/kelola-mentor',
      builder: (context, state) => const KelolaMentor(),
    ),
    GoRoute(
      path: '/kelola-mentee',
      builder: (context, state) => const KelolaMenteePage(),
    ),
    GoRoute(
      path: '/kelola-kelompok',
      builder: (context, state) => const KelolaKelompokPage(),
      // Tambahkan sub-rute untuk halaman detail
      routes: [
        GoRoute(
          path: ':id', // ':' menandakan 'id' adalah parameter dinamis
          builder: (context, state) {
            // Ambil nilai 'id' dari URL yang dikirim
            final kelompokId = state.pathParameters['id']!;
            // Kirim id tersebut ke halaman detail
            return KelompokDetailPage(kelompokId: kelompokId);
          },
        ),
      ],
    ),
  ],
);
