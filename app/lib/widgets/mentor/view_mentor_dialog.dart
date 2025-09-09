// lib/widgets/mentor/view_mentor_dialog.dart

import 'package:app/models/mentor_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewMentorDialog extends StatelessWidget {
  final MentorModel mentor;

  const ViewMentorDialog({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detail Data Mentor',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                ),
              ],
            ),
            const Divider(height: 24),

            // Konten Detail
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Username',
              value: mentor.username,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: 'Nomor HP',
              value: mentor.noHp ?? '-',
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.work_outline,
              label: 'Jabatan',
              value: mentor.jabatan ?? '-',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat baris detail yang rapi
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
