import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // 1. AppBar di bagian atas
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Menambahkan sedikit jarak dari tepi kanan layar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            // Menggunakan InkWell agar CircleAvatar bisa ditekan (tappable)
            child: InkWell(
              onTap: () {
                GoRouter.of(context).go('/profile');
              },
              // Kustomisasi bentuk ripple effect agar sesuai dengan lingkaran
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                backgroundColor: Colors.blue[50], // Warna latar belakang avatar
                // Ikon yang merepresentasikan admin
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.blue[600],
                ),
              ),
            ),
          ),
        ],
      ),
      // 2. Drawer (Menu Samping)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 33, 11, 231),
              ),
              child: Text(
                'Menu Navigasi',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Manajemen Pengguna'),
              onTap: () {
                // TODO: Navigasi ke halaman manajemen pengguna
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Laporan'),
              onTap: () {
                // TODO: Navigasi ke halaman laporan
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                // TODO: Navigasi ke halaman pengaturan
              },
            ),
          ],
        ),
      ),
      // 3. Badan Halaman (Body)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang, Admin!',
              style: GoogleFonts.openSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Bagian Ringkasan Statistik
            Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.people_alt,
                    label: 'Total Pengguna',
                    value: '1,250',
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: StatCard(
                    icon: Icons.shopping_cart,
                    label: 'Pesanan Baru',
                    value: '85',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bagian Menu Aksi Cepat
            Text('Aksi Cepat', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2, // 2 kolom
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true, // Agar GridView tidak error di dalam Column
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ActionCard(
                  icon: Icons.inventory_2,
                  label: 'Manajemen Produk',
                  onTap: () {},
                ),
                ActionCard(
                  icon: Icons.category,
                  label: 'Manajemen Kategori',
                  onTap: () {},
                ),
                ActionCard(
                  icon: Icons.receipt_long,
                  label: 'Lihat Transaksi',
                  onTap: () {},
                ),
                ActionCard(
                  icon: Icons.settings_applications,
                  label: 'Pengaturan App',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET BANTUAN UNTUK KARTU STATISTIK (agar kode tidak berulang)
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// WIDGET BANTUAN UNTUK KARTU AKSI (agar kode tidak berulang)
class ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
