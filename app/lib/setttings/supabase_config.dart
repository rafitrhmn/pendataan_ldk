import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Simpan URL dan Anon Key Anda di sini
const String supabaseUrl = 'https://qymixvjfmmetvwzbsxqt.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5bWl4dmpmbW1ldHZ3emJzeHF0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYwMDA5MzAsImV4cCI6MjA3MTU3NjkzMH0.i5lF69NSet1tSRnYSC0EF1UeSldZZ8395nWkrIlx1Hs';

// 2. Buat fungsi inisialisasi yang akan kita panggil dari main.dart
Future<void> initializeSupabase() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

// 3. Buat instance client Supabase agar bisa diakses dari mana saja di aplikasi
// Ini adalah cara mudah untuk memanggil supabase tanpa perlu menulis Supabase.instance.client berulang kali
final supabase = Supabase.instance.client;
