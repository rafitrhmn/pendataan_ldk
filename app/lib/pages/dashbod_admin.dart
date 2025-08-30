import 'package:app/widgets/admin_drawer.dart';
import 'package:app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // DIUBAH: Menggunakan widget AppBar kustom
      appBar: const CustomAppBar(title: 'Admin Dashboard'),

      // DIUBAH: Menggunakan widget Drawer kustom
      drawer: const AdminDrawer(),
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

            // --- TAMBAHKAN TOMBOL INI SEMENTARA UNTUK DEBUGGING ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                print("--- 🔬 Memulai Tes Peran Pengguna ---");
                try {
                  // Memanggil fungsi SQL yang baru saja kita buat
                  final result = await Supabase.instance.client.rpc(
                    'get_my_role_for_testing',
                  );

                  print("✅ [HASIL TES PERAN]: $result");

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hasil tes peran: $result')),
                  );
                } catch (e) {
                  print("🚨 [ERROR TES PERAN]: ${e.toString()}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error tes peran: ${e.toString()}')),
                  );
                }
              },
              child: const Text(
                'Jalankan Tes Peran',
                style: TextStyle(color: Colors.white),
              ),
            ),
            // --- AKHIR DARI TOMBOL DEBUGGING ---

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
