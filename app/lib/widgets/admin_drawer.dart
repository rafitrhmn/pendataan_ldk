import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 1, // Beri sedikit shadow
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
                Text(
                  'Sistem Pembinaan',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'LDK Al-Faateh',
                  style: GoogleFonts.openSans(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Menggunakan helper untuk membuat ListTile yang konsisten
          _buildDrawerItem(
            context: context,
            icon: Icons.home_outlined,
            title: 'Beranda',
            route: '/dashadmin',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.groups_outlined,
            title: 'Kelola Kader',
            route: '/kelola-kader',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.school_outlined,
            title: 'Kelola Mentor',
            route: '/kelola-mentor',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.face_retouching_natural_outlined,
            title: 'Kelola Mentee',
            route: '/kelola-mentee',
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.hub_outlined,
            title: 'Kelola Kelompok',
            route: '/kelola-kelompok',
          ),
        ],
      ),
    );
  }

  //  BUAT HELPER WIDGET UNTUK LISTTILE
  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
  }) {
    final String currentLocation = GoRouterState.of(context).uri.toString();
    final bool isSelected = currentLocation == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue[600] : Colors.grey[600],
      ),
      title: Text(
        title,
        style: GoogleFonts.openSans(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.blue[600] : Colors.grey[800],
        ),
      ),
      tileColor: isSelected ? Colors.blue[50] : null,
      onTap: () {
        Navigator.pop(context); // Selalu tutup drawer
        context.go(route); // Gunakan context.go() yang ringkas
      },
    );
  }
}
