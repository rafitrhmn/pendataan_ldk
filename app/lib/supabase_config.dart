import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Simpan URL dan Anon Key Anda di sini
const String supabaseUrl = 'https://kvclpdfqckimnoiunlhm.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt2Y2xwZGZxY2tpbW5vaXVubGhtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4NDU2NjEsImV4cCI6MjA3MTQyMTY2MX0.oHnHH-pMRhfHv4ClFUvjusBinRuwFI5ObmCu14U96W0';

// 2. Buat fungsi inisialisasi yang akan kita panggil dari main.dart
Future<void> initializeSupabase() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

// 3. Buat instance client Supabase agar bisa diakses dari mana saja di aplikasi
// Ini adalah cara mudah untuk memanggil supabase tanpa perlu menulis Supabase.instance.client berulang kali
final supabase = Supabase.instance.client;
