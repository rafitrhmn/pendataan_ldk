// lib/widgets/laporan/penilaian_dhuha_input.dart

import 'package:app/utils/style_decorations.dart'; // Sesuaikan path jika perlu
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

// Widget baru yang stateful untuk input sholat dhuha
class PenilaianDhuhaInput extends StatefulWidget {
  final TextEditingController controller;

  const PenilaianDhuhaInput({super.key, required this.controller});

  @override
  State<PenilaianDhuhaInput> createState() => _PenilaianDhuhaInputState();
}

class _PenilaianDhuhaInputState extends State<PenilaianDhuhaInput> {
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
      final jumlahDilaksanakan = int.tryParse(widget.controller.text) ?? -1;

      if (widget.controller.text.isEmpty || jumlahDilaksanakan < 0) {
        _penilaian = null;
        return;
      }

      // LOGIKA PENILAIAN SHOLAT DHUHA (TOTAL 14 RAKAAT/MINGGU)
      if (jumlahDilaksanakan >= 13) {
        _penilaian = Penilaian('Unggul', Colors.green, jumlahDilaksanakan);
      } else if (jumlahDilaksanakan >= 11) {
        _penilaian = Penilaian('Sangat Baik', Colors.blue, jumlahDilaksanakan);
      } else if (jumlahDilaksanakan >= 9) {
        _penilaian = Penilaian('Baik', Colors.teal, jumlahDilaksanakan);
      } else if (jumlahDilaksanakan >= 7) {
        _penilaian = Penilaian(
          'Cukup',
          Colors.amber.shade800,
          jumlahDilaksanakan,
        );
      } else if (jumlahDilaksanakan >= 5) {
        _penilaian = Penilaian(
          'Kurang',
          Colors.orange.shade800,
          jumlahDilaksanakan,
        );
      } else {
        _penilaian = Penilaian('Sangat Kurang', Colors.red, jumlahDilaksanakan);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berapa total rakaat sholat dhuha yang di laksanakan dalam satu minggu?',
          style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey[800]),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          style: GoogleFonts.openSans(),
          // textAlign: TextAlign.center,
          decoration: buildInputDecoration('Jumlah (0-14)'),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
        ),
        if (_penilaian != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            //  UBAH MENJADI ROW
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_penilaian!.jumlahDilaksanakan} rakaat shalat dhuha dalam satu minggu, Hasil penilaian ${_penilaian!.level}.',
                    style: GoogleFonts.openSans(
                      color: _penilaian!.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                //  TAMBAHKAN TOMBOL INFO
                InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const InfoPenilaianDhuhaDialog(),
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

class InfoPenilaianDhuhaDialog extends StatelessWidget {
  const InfoPenilaianDhuhaDialog({super.key});

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
                    'Penilaian Sholat Dhuha',
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
              'Penilaian didasarkan pada jumlah rakaat yang dilaksanakan dalam seminggu (target 14 rakaat).',
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
                      'Unggual',
                      '13-14 rakaat',
                      'Melaksanakan sholat dhuha setiap hari tanpa terlewat, penuh konsistensi.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Sangat Baik',
                      '11-12 rakaat',
                      'Hampir selalu melaksanakan sholat dhuha, hanya terlewat 1-2 hari.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Baik',
                      '9-10 rakaat',
                      'Sebagian besar dilaksanakan, namun ada beberapa hari terlewat.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Cukup',
                      '7-8 rakaat',
                      'Melaksanakan lebih dari setengah target, tapi kurang rutin.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Kurang',
                      '5-6 rakaat',
                      'Hanya sebagian kecil target tercapai, masih kurang konsistensi.',
                    ),
                    const Divider(),
                    _buildKriteriaRow(
                      'Sangat Kurang',
                      '≤4 rakaat',
                      'Jarang melaksanakan sholat dhuha, jauh dari target yang ditentukan.',
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
