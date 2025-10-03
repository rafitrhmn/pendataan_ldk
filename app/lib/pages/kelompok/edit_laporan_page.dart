import 'package:app/bloc/laporan/laporan_bloc.dart';
import 'package:app/bloc/laporan/laporan_event.dart';
import 'package:app/bloc/laporan/laporan_state.dart';
import 'package:app/models/laporan_mentee_model.dart';
import 'package:app/models/mentee_model.dart';
import 'package:app/models/pertemuan_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditLaporanPage extends StatefulWidget {
  final Pertemuan pertemuan;
  final List<LaporanMentee> laporanMentees;
  final List<Mentee> allMenteesInKelompok;

  const EditLaporanPage({
    super.key,
    required this.pertemuan,
    required this.laporanMentees,
    required this.allMenteesInKelompok,
  });

  @override
  State<EditLaporanPage> createState() => _EditLaporanPageState();
}

class _EditLaporanPageState extends State<EditLaporanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _catatanController;
  late final TextEditingController _tempatController;
  late DateTime _selectedDate;

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _existingImageUrl;

  late Map<String, Map<String, dynamic>> _laporanMenteesMap;

  @override
  void initState() {
    super.initState();
    // Isi semua field dengan data yang sudah ada
    final p = widget.pertemuan;
    _catatanController = TextEditingController(text: p.catatan ?? '');
    _tempatController = TextEditingController(text: p.tempat ?? '');
    _selectedDate = p.tanggal;
    _existingImageUrl = p.fotoUrl;

    // Inisialisasi map laporan berdasarkan semua anggota kelompok
    _laporanMenteesMap = {
      for (var mentee in widget.allMenteesInKelompok)
        mentee.id: {
          'mentee_id': mentee.id,
          'hadir': false, // Default tidak hadir
          'sholat_wajib': TextEditingController(),
          'sholat_dhuha': TextEditingController(),
          'tilawah_quran': TextEditingController(),
        },
    };

    // Isi data laporan untuk mentee yang laporannya sudah ada
    for (var laporan in widget.laporanMentees) {
      if (_laporanMenteesMap.containsKey(laporan.menteeId)) {
        final entry = _laporanMenteesMap[laporan.menteeId]!;
        entry['hadir'] = laporan.hadir;
        (entry['sholat_wajib'] as TextEditingController).text =
            laporan.sholatWajib?.toString() ?? '0';
        (entry['sholat_dhuha'] as TextEditingController).text =
            laporan.sholatDhuha?.toString() ?? '0';
        (entry['tilawah_quran'] as TextEditingController).text =
            laporan.tilawahQuran?.toString() ?? '0';
      }
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    _tempatController.dispose();
    _laporanMenteesMap.forEach((_, value) {
      (value['sholat_wajib'] as TextEditingController).dispose();
      (value['sholat_dhuha'] as TextEditingController).dispose();
      (value['tilawah_quran'] as TextEditingController).dispose();
    });
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
        _existingImageUrl = null; // Hapus URL lama jika gambar baru dipilih
      });
    }
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

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl = _existingImageUrl; // Gunakan URL lama secara default
    if (_selectedImageBytes != null && _selectedImageName != null) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$_selectedImageName';
      try {
        await Supabase.instance.client.storage
            .from('foto_pertemuan')
            .uploadBinary(fileName, _selectedImageBytes!);
        imageUrl = Supabase.instance.client.storage
            .from('foto_pertemuan')
            .getPublicUrl(fileName);
      } catch (e) {
        /* ... handle error ... */
      }
    }

    final laporanList = _laporanMenteesMap.values
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

    if (mounted) {
      context.read<LaporanBloc>().add(
        UpdateLaporanPertemuan(
          pertemuanId: widget.pertemuan.id,
          tanggal: _selectedDate,
          tempat: _tempatController.text,
          catatan: _catatanController.text,
          fotoUrl: imageUrl,
          oldFotoUrl: widget.pertemuan.fotoUrl,
          laporanMentees: laporanList,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LaporanBloc, LaporanState>(
      listener: (context, state) {
        if (state is LaporanUpdateSuccess) {
          context.pop(true); // Kirim sinyal refresh
        } else if (state is LaporanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui laporan: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Edit Laporan Pertemuan')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bagian Info Umum
              _buildInfoUmumCard(),
              const SizedBox(height: 24),
              const Text(
                'Laporan Keaktifan Anggota',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...widget.allMenteesInKelompok.map(
                (mentee) => _buildMenteeReportCard(mentee),
              ),
              const SizedBox(height: 24),
              BlocBuilder<LaporanBloc, LaporanState>(
                builder: (context, state) {
                  if (state is LaporanSubmitting) {
                    return const ElevatedButton(
                      onPressed: null,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Simpan Perubahan'),
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
    // Logika untuk menentukan widget pratinjau gambar
    Widget imagePreview;
    if (_selectedImageBytes != null) {
      // Jika ada gambar baru yang dipilih, tampilkan dari memory
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          _selectedImageBytes!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } else if (_existingImageUrl != null) {
      // Jika ada gambar lama dari database, tampilkan dari network
      imagePreview = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _existingImageUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Tampilan default jika tidak ada gambar
      imagePreview = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.photo, size: 30, color: Colors.grey),
      );
    }

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
              contentPadding: EdgeInsets.zero,
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
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                imagePreview,
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Ganti Foto'),
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
    final report = _laporanMenteesMap[mentee.id]!;
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
