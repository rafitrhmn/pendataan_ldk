// lib/widgets/laporan/penilaian_sholat_input.dart

import 'package:app/utils/style_decorations.dart'; // Import helper dekorasi Anda
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Helper class untuk menampung hasil penilaian
class Penilaian {
  final String level;
  final Color color;
  final int jumlahDilaksanakan;

  Penilaian(this.level, this.color, this.jumlahDilaksanakan);
}

// Widget utama yang akan Anda panggil dari halaman form
class PenilaianSholatInput extends StatefulWidget {
  final TextEditingController controller;

  const PenilaianSholatInput({super.key, required this.controller});

  @override
  State<PenilaianSholatInput> createState() => _PenilaianSholatInputState();
}

class _PenilaianSholatInputState extends State<PenilaianSholatInput> {
  Penilaian? _penilaian;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_hitungPenilaian);
    _hitungPenilaian(); // Panggil sekali di awal untuk inisialisasi
  }

  @override
  void dispose() {
    widget.controller.removeListener(_hitungPenilaian);
    super.dispose();
  }

  void _hitungPenilaian() {
    setState(() {
      final jumlahDitinggalkan = int.tryParse(widget.controller.text) ?? -1;

      if (widget.controller.text.isEmpty || jumlahDitinggalkan < 0) {
        _penilaian = null;
        return;
      }

      final int jumlahSholat = 35 - jumlahDitinggalkan;

      if (jumlahSholat >= 34) {
        _penilaian = Penilaian('Unggul', Colors.green, jumlahSholat);
      } else if (jumlahSholat >= 30) {
        _penilaian = Penilaian('Sangat Baik', Colors.blue, jumlahSholat);
      } else if (jumlahSholat >= 25) {
        _penilaian = Penilaian('Baik', Colors.teal, jumlahSholat);
      } else if (jumlahSholat >= 20) {
        _penilaian = Penilaian('Cukup', Colors.amber.shade800, jumlahSholat);
      } else if (jumlahSholat >= 15) {
        _penilaian = Penilaian('Kurang', Colors.orange.shade800, jumlahSholat);
      } else {
        _penilaian = Penilaian('Sangat Kurang', Colors.red, jumlahSholat);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berapa kali meninggalkan sholat wajib dalam satu minggu?',
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[800]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          style: GoogleFonts.openSans(),
          // textAlign: TextAlign.center,
          decoration: buildInputDecoration('Jumlah (0-35)'),
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
                    '${_penilaian!.jumlahDilaksanakan} kali sholat dalam satu minggu, Hasil penilaian ${_penilaian!.level}.',
                    style: GoogleFonts.openSans(
                      color: _penilaian!.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

                // Ikon Informasi "i"
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  onPressed: () {
                    // Panggil dialog baru Anda di sini
                    showDialog(
                      context: context,
                      builder: (context) => const InfoPenilaianDialog(),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class InfoPenilaianDialog extends StatelessWidget {
  const InfoPenilaianDialog({super.key});

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
                    'Penilaian Sholat 5 Waktu',
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
              'Penilaian didasarkan pada jumlah sholat 5 waktu yang dilaksanakan dalam seminggu (total 35 kali sholat).',
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
                      '34-35 kali',
                      'Selalu sholat 5 waktu tanpa ada yang terlewat. Konsisten, disiplin, dan menjadi teladan.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Sangat Baik',
                      '30-33 kali',
                      'Hampir selalu sholat 5 waktu, hanya terlewat 1-2 hari/beberapa waktu.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Baik',
                      '25-29 kali',
                      'Sebagian besar sholat dilaksanakan dengan baik, meskipun ada yang terlewat.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Cukup',
                      '20-24 kali',
                      'Masih melaksanakan sholat lebih dari setengah kewajiban, tetapi kurang konsisten.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Kurang',
                      '15-19 kali',
                      'Hanya melaksanakan sebagian kecil sholat wajib, banyak yang ditinggalkan.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Sangat Kurang',
                      '≤14 kali',
                      'Sangat jarang melaksanakan sholat, hampir seluruh kewajiban tidak dikerjakan.',
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

  // Helper untuk membuat setiap baris kriteria
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
