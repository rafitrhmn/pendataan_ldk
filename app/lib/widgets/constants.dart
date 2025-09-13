// lib/shared/constants.dart (buat file baru jika perlu)

class AppConstants {
  static const List<String> programStudi = [
    'Manajemen',
    'Akuntansi',
    'Hukum',
    'Informatika',
    'Sistem Informasi',
    'Rekayasa Sistem Komputer',
    'Agroteknologi',
    'Ilmu Perikanan',
  ];
  static final List<int> semesterOptions = List.generate(
    14,
    (index) => index + 1,
  );

  static const List<String> gender = ['Laki-laki', 'Perempuan'];

  static const List<String> hariPertemuan = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
}
