import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[600]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Image.asset('assets/images/logo_2.png', height: 45),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sistem Pembinaan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'LDK Al-Faateh',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Beranda'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer
              GoRouter.of(context).go('/dashadmin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups_outlined),
            title: const Text('Kelola Kader'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              GoRouter.of(context).go('/kelola-kader');
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Kelola Mentor'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              GoRouter.of(context).go('/kelola-mentor');
            },
          ),
          ListTile(
            leading: const Icon(Icons.face_retouching_natural_outlined),
            title: const Text('Kelola Mantee'),
            onTap: () {
              Navigator.pop(context); // Tutup drawer dulu
              GoRouter.of(context).go('/kelola-mentee');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Kelola PAI'),
            onTap: () {
              // TODO: Navigasi ke halaman Kelola PAI
            },
          ),
        ],
      ),
    );
  }
}
