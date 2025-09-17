import 'dart:io';
import 'package:app/bloc/laporan/laporan_bloc.dart';
import 'package:app/bloc/laporan/laporan_event.dart';
import 'package:app/bloc/laporan/laporan_state.dart';
import 'package:app/models/mentee_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddLaporanPage extends StatefulWidget {
  final String kelompokId;
  final List<Mentee> mentees;
  final int pertemuanKe;

  const AddLaporanPage({
    super.key,
    required this.kelompokId,
    required this.mentees,
    required this.pertemuanKe,
  });

  @override
  State<AddLaporanPage> createState() => _AddLaporanPageState();
}

class _AddLaporanPageState extends State<AddLaporanPage> {
  final _formKey = GlobalKey<FormState>();
  final _catatanController = TextEditingController();
  final _tempatController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  // DIUBAH: Simpan data gambar sebagai bytes dan nama file
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  // Map untuk menyimpan state laporan dari setiap mentee
  late final Map<String, Map<String, dynamic>> _laporanMentees;

  @override
  void initState() {
    super.initState();
    // Inisialisasi map laporan, set semua mentee hadir secara default
    _laporanMentees = {
      for (var mentee in widget.mentees)
        mentee.id: {
          'mentee_id': mentee.id,
          'hadir': true,
          'sholat_wajib': TextEditingController(),
          'sholat_dhuha': TextEditingController(),
          'tilawah_quran': TextEditingController(),
        },
    };
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _tempatController.dispose();
    // Penting: dispose semua controller yang dibuat secara dinamis
    _laporanMentees.forEach((_, value) {
      (value['sholat_wajib'] as TextEditingController).dispose();
      (value['sholat_dhuha'] as TextEditingController).dispose();
      (value['tilawah_quran'] as TextEditingController).dispose();
    });
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      // DIUBAH: Baca gambar sebagai bytes
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });
    }
  }

  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) return;
    String? imageUrl;

    if (_selectedImageBytes != null && _selectedImageName != null) {
      // Buat nama file unik di server
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$_selectedImageName';
      try {
        // DIUBAH: Gunakan .uploadBinary() untuk mengunggah bytes
        await Supabase.instance.client.storage
            .from('foto_pertemuan')
            .uploadBinary(fileName, _selectedImageBytes!);

        imageUrl = Supabase.instance.client.storage
            .from('foto_pertemuan')
            .getPublicUrl(fileName);
      } catch (e) {
        print('--- ERROR SAAT UNGGAH FOTO ---');
        print(e); // Tampilkan error mentah di Debug Console
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunggah foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // 2. Kumpulkan data laporan dari mentee yang hadir
    final laporanList = _laporanMentees.values
        .where((report) => report['hadir'] == true)
        .map((report) {
          return {
            'mentee_id': report['mentee_id'],
            'hadir': report['hadir'],
            'sholat_wajib':
                int.tryParse(
                  (report['sholat_wajib'] as TextEditingController).text,
                ) ??
                0,
            'sholat_dhuha':
                int.tryParse(
                  (report['sholat_dhuha'] as TextEditingController).text,
                ) ??
                0,
            'tilawah_quran':
                int.tryParse(
                  (report['tilawah_quran'] as TextEditingController).text,
                ) ??
                0,
          };
        })
        .toList();

    final dataUntukDikirim = {
      'kelompokId': widget.kelompokId,
      'tanggal': _selectedDate,
      'tempat': _tempatController.text,
      'catatan': _catatanController.text,
      'fotoUrl': imageUrl,
      'laporanMentees': laporanList,
    };

    print('--- [DEBUG UI] Mengirim data ke BLoC: ---');
    print(dataUntukDikirim);

    // 3. Kirim event ke BLoC
    if (mounted) {
      context.read<LaporanBloc>().add(
        CreateLaporanPertemuan(
          kelompokId: widget.kelompokId,
          tanggal: _selectedDate,
          catatan: _catatanController.text,
          tempat: _tempatController.text,
          fotoUrl: imageUrl,
          laporanMentees: laporanList,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LaporanBloc, LaporanState>(
      listener: (context, state) {
        if (state is LaporanSubmitSuccess) {
          // Kirim sinyal 'true' agar halaman detail me-refresh riwayat
          context.pop(true);
        } else if (state is LaporanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan laporan: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Laporan Pertemuan ke-${widget.pertemuanKe}'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bagian Info Umum
              _buildInfoUmumCard(),
              const SizedBox(height: 24),

              // Bagian Laporan Anggota
              const Text(
                'Laporan Keaktifan Anggota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...widget.mentees.map((mentee) => _buildMenteeReportCard(mentee)),
              const SizedBox(height: 24),

              // Tombol Simpan
              BlocBuilder<LaporanBloc, LaporanState>(
                builder: (context, state) {
                  if (state is LaporanSubmitting) {
                    return const ElevatedButton(
                      onPressed: null,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }
                  return ElevatedButton(
                    onPressed: _submitLaporan,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Simpan Laporan'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoUmumCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Pertemuan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Tanggal Pertemuan'),
              subtitle: Text(
                DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
              ),
              onTap: _selectDate,
            ),
            TextFormField(
              controller: _tempatController,
              decoration: const InputDecoration(labelText: 'Tempat Pertemuan'),
              validator: (v) => v!.isEmpty ? 'Tempat tidak boleh kosong' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _catatanController,
              decoration: const InputDecoration(
                labelText: 'Catatan Pertemuan (Opsional)',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // DIUBAH: Gunakan Image.memory untuk menampilkan preview
                  child: _selectedImageBytes != null
                      ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                      : const Icon(Icons.photo, size: 30, color: Colors.grey),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Unggah Foto (Opsional)'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenteeReportCard(Mentee mentee) {
    final report = _laporanMentees[mentee.id]!;
    final bool isHadir = report['hadir'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(
              mentee.namaLengkap,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Kehadiran'),
            value: isHadir,
            onChanged: (val) => setState(() => report['hadir'] = val!),
          ),
          if (isHadir)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  TextFormField(
                    controller: report['sholat_wajib'],
                    decoration: const InputDecoration(
                      labelText: 'Sholat Wajib (kali)',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: report['sholat_dhuha'],
                    decoration: const InputDecoration(
                      labelText: 'Sholat Dhuha (kali)',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: report['tilawah_quran'],
                    decoration: const InputDecoration(
                      labelText: 'Tilawah (lembar)',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
