// lib/widgets/mentee/view_mentee_dialog.dart

import 'package:app/models/mentee_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewMenteeDialog extends StatelessWidget {
  final Mentee mentee;

  const ViewMenteeDialog({super.key, required this.mentee});

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
                  'Detail Data Mentee',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Konten Detail
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Nama Lengkap',
              value: mentee.namaLengkap,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.wc_outlined,
              label: 'Gender',
              value: mentee.gender,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.school_outlined,
              label: 'Program Studi',
              value: mentee.prodi,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.format_list_numbered,
              label: 'Semester',
              value: mentee.semester.toString(),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Angkatan',
              value: mentee.angkatan.toString(),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              icon: Icons.phone_outlined,
              label: 'Nomor HP',
              value: mentee.noHp,
            ),
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
                style: GoogleFonts.openSans(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.openSans(
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
