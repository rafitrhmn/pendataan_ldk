// lib/widgets/laporan/penilaian_tilawah_input.dart

import 'package:app/utils/style_decorations.dart'; // Sesuaikan path jika perlu
// import 'package:app/widgets/laporan/info_penilaian_tilawah_dialog.dart'; // Akan kita buat nanti
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Helper class untuk menampung hasil penilaian
class Penilaian {
  final String level;
  final Color color;

  Penilaian(this.level, this.color);
}

class PenilaianTilawahInput extends StatefulWidget {
  final TextEditingController controller;

  const PenilaianTilawahInput({super.key, required this.controller});

  @override
  State<PenilaianTilawahInput> createState() => _PenilaianTilawahInputState();
}

class _PenilaianTilawahInputState extends State<PenilaianTilawahInput> {
  Penilaian? _penilaian;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_hitungPenilaian);
    _hitungPenilaian();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_hitungPenilaian);
    super.dispose();
  }

  void _hitungPenilaian() {
    setState(() {
      final jumlahLembar = int.tryParse(widget.controller.text) ?? -1;

      if (widget.controller.text.isEmpty || jumlahLembar < 0) {
        _penilaian = null;
        return;
      }

      // LOGIKA PENILAIAN TILAWAH (TARGET 7 LEMBAR/MINGGU)
      if (jumlahLembar >= 7) {
        _penilaian = Penilaian('Unggul', Colors.green);
      } else if (jumlahLembar >= 6) {
        _penilaian = Penilaian('Sangat Baik', Colors.blue);
      } else if (jumlahLembar >= 5) {
        _penilaian = Penilaian('Baik', Colors.teal);
      } else if (jumlahLembar >= 4) {
        _penilaian = Penilaian('Cukup', Colors.amber.shade800);
      } else if (jumlahLembar >= 2) {
        _penilaian = Penilaian('Kurang', Colors.orange.shade800);
      } else {
        _penilaian = Penilaian('Sangat Kurang', Colors.red);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berapa total lembar tilawah Al-Qur’an yang dilaksanakan dalam satu minggu?',
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[800]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          style: GoogleFonts.openSans(),
          // textAlign: TextAlign.center,
          decoration: buildInputDecoration('Jumlah (0-7)'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
        ),
        if (_penilaian != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.controller.text} lembar tilawah dalam satu minggu, hasil penilaian ${_penilaian!.level}.',
                    style: GoogleFonts.openSans(
                      color: _penilaian!.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const InfoPenilaianTilawahDialog(),
                  ),
                  customBorder: const CircleBorder(),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class InfoPenilaianTilawahDialog extends StatelessWidget {
  const InfoPenilaianTilawahDialog({super.key});

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
            // Header Dialog
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Penilaian Tilawah Al-Qur\'an',
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Penilaian didasarkan pada jumlah tilawah Al-Qur\'an yang dilaksanakan dalam seminggu (targer 7 lembar).',
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const Divider(height: 24, thickness: 1),

            // Konten Penilaian
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildKriteriaRow(
                      'Unggul',
                      '7 lembar',
                      'Membaca Al-Qur\'an setiap hari sesuai target tanpa terlewat. Konsisten dan disiplin.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Sangat Baik',
                      '6 lembar',
                      'Hampir sesuai target, hanya terlewat 1 hari.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Baik',
                      '5 lembar',
                      'Sebagian besar target tercapai, meski ada kekurangan.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Cukup',
                      '4 lembar',
                      'Masih melaksanakan tilawah lebih dari setengah target, tapi tidak konsisten.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Kurang',
                      '2-3 lembar',
                      'Hanya sebagian kecil target yang tercapai.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Sangat Kurang',
                      '0-1 lembar',
                      'Hampir tidak tilawah dalam seminggu.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ok',
                style: GoogleFonts.openSans(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKriteriaRow(String level, String jumlah, String deskripsi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kolom Kiri: Level & Jumlah
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  jumlah,
                  style: GoogleFonts.openSans(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Kolom Kanan: Deskripsi
          Expanded(
            flex: 3,
            child: Text(deskripsi, style: GoogleFonts.openSans(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
