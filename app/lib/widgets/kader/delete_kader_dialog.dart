// lib/widgets/delete_kader_dialog.dart

import 'package:app/models/kader_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/bloc/kader/kader_bloc.dart';
import 'package:app/bloc/kader/kader_event.dart';

class DeleteKaderDialog extends StatelessWidget {
  // Dialog ini memerlukan data 'kader' yang akan dihapus
  final Kader kader;

  const DeleteKaderDialog({super.key, required this.kader});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Agar tinggi dialog menyesuaikan konten
          children: [
            // 1. Icon Peringatan
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Judul Dialog
            Text(
              'Hapus Kader',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 3. Pesan Konfirmasi
            Text(
              'Apakah Anda yakin ingin menghapus kader bernama "${kader.username}"? Aksi ini tidak dapat dibatalkan.',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Tombol Aksi (Batal & Hapus)
            Row(
              children: [
                // Tombol Batal
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey[800]),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Tombol Hapus
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Kirim event hapus ke BLoC
                      context.read<KaderBloc>().add(DeleteKader(id: kader.id));
                      Navigator.of(context).pop(); // Tutup dialog
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0, // Hilangkan shadow agar lebih flat
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
