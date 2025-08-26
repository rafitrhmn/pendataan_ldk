// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   // Variabel untuk melacak apakah password sedang ditampilkan atau tidak
//   bool _isPasswordVisible = false;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Memberi sedikit warna latar belakang agar shadow terlihat jelas
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         // SafeArea agar konten tidak menabrak status bar
//         child: SingleChildScrollView(
//           // Agar bisa di-scroll jika layar kecil
//           child: Padding(
//             // DITAMBAHKAN: Memberi jarak dari tepi layar
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               // DIUBAH: Mengatur semua anak widget agar rata kiri secara default
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 30),

//                 // DIUBAH: Dibungkus Center agar kembali ke tengah
//                 Center(
//                   child: Container(
//                     width: 168,
//                     height: 170,
//                     decoration: ShapeDecoration(
//                       color: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       shadows: const [
//                         BoxShadow(
//                           color: Color(0x28000000),
//                           blurRadius: 4,
//                           offset: Offset(0, 1),
//                           spreadRadius: 0,
//                         ),
//                       ],
//                     ),
//                     child: Stack(
//                       children: [
//                         Positioned(
//                           left: 6,
//                           top: 14,
//                           child: Container(
//                             width: 154.22,
//                             height: 142.34,
//                             decoration: const BoxDecoration(
//                               image: DecorationImage(
//                                 image: AssetImage('assets/images/logo_2.png'),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // DIUBAH: Dibungkus Center agar kembali ke tengah
//                 Center(
//                   child: Text(
//                     """Sistem Pendataan
// LDK Al - Faateh""",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.openSans(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),

//                 // Teks ini sekarang akan otomatis rata kiri karena pengaturan Column
//                 Text(
//                   "Masuk Akun",
//                   style: GoogleFonts.openSans(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 TextField(
//                   decoration: InputDecoration(
//                     // Teks petunjuk yang akan hilang saat pengguna mengetik
//                     hintText: 'Email',
//                     // Gaya teks untuk hintText
//                     hintStyle: GoogleFonts.openSans(
//                       color: Colors.black.withOpacity(0.5),
//                       fontSize: 14,
//                     ),
//                     // Memberi warna latar belakang pada field
//                     filled: true,
//                     fillColor: const Color(0x33C4C4C4),
//                     // Menghilangkan garis bawah default
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none, // Tidak ada garis tepi
//                     ),
//                     // Padding konten di dalam field
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 15.0,
//                       horizontal: 24.0,
//                     ),
//                     // DITAMBAHKAN: Ikon di ujung kanan
//                     suffixIcon: Icon(
//                       Icons.person_outline, // Ikon pengguna/user
//                       color: Colors.black.withOpacity(
//                         0.5,
//                       ), // Warna disamakan dengan hintText
//                     ),
//                   ),
//                 ),

//                 // Memberi jarak vertikal antara dua text field
//                 const SizedBox(height: 27),

//                 // 2. TEXTFIELD UNTUK PASSWORD
//                 TextField(
//                   // Menyembunyikan teks yang diketik (untuk password)
//                   obscureText: !_isPasswordVisible,
//                   decoration: InputDecoration(
//                     hintText: 'Password',
//                     hintStyle: GoogleFonts.openSans(
//                       color: Colors.black.withOpacity(0.5),
//                       fontSize: 14,
//                     ),
//                     filled: true,
//                     fillColor: const Color(0x33C4C4C4),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: BorderSide.none,
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       vertical: 15.0,
//                       horizontal: 24.0,
//                     ),
//                     // Menambahkan ikon mata di sebelah kanan
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         // Mengubah ikon berdasarkan state _isPasswordVisible
//                         _isPasswordVisible
//                             ? Icons.visibility
//                             : Icons.visibility_off,
//                         color: Colors.black.withOpacity(0.5),
//                       ),
//                       onPressed: () {
//                         // Mengubah state saat ikon ditekan
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 // Memberi jarak dari field password di atasnya
//                 const SizedBox(height: 30),

//                 // TOMBOL MASUK
//                 ElevatedButton(
//                   // Properti style untuk menata tampilan tombol
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF4198FF),
//                     minimumSize: const Size(
//                       700,
//                       50,
//                     ), // Warna latar belakang tombol

//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(
//                         10,
//                       ), // Membuat sudut melingkar
//                     ),
//                     elevation: 0, // Menghilangkan bayangan default
//                   ),
//                   // Fungsi yang akan dijalankan saat tombol ditekan
//                   onPressed: () {
//                     // TODO: Tambahkan logika untuk proses login di sini
//                     print('Tombol Masuk ditekan!');
//                   },
//                   // Konten di dalam tombol (teks)
//                   child: Text(
//                     'Masuk',
//                     style: GoogleFonts.openSans(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white, // Warna teks
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/login/login_bloc.dart';
// ... import halaman home lainnya

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Fungsi untuk memicu event ke BLoC
  void _doLogin() {
    context.read<LoginBloc>().add(
      LoginButtonPressed(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // BlocListener digunakan untuk aksi "sampingan" seperti navigasi atau SnackBar
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          } else if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Selamat datang, ${state.user.username}!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigasi berdasarkan role
            switch (state.user.role) {
              case 'admin':
                GoRouter.of(context).go('/dashadmin');
                break;
              case 'mentor':
                // Navigator.of(context).pushReplacement(... MentorHomePage ...);
                break;
              case 'kaderisasi':
                // Navigator.of(context).pushReplacement(... KaderHomePage ...);
                break;
            }
          }
        },
        // BlocBuilder digunakan untuk membangun ulang UI berdasarkan state
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                // ... [UI Anda yang lain tetap sama, saya potong agar ringkas] ...
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... [Widget Logo dan Teks Judul Anda] ...
                    const SizedBox(height: 30),
                    Center(
                      child: Container(
                        width: 168,
                        height: 170,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x28000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Image.asset('assets/images/logo_2.png'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        """Sistem Pendataan \nLDK Al - Faateh""",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Masuk Akun",
                      style: GoogleFonts.openSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        // Teks petunjuk yang akan hilang saat pengguna mengetik
                        hintText: 'Username',
                        // Gaya teks untuk hintText
                        hintStyle: GoogleFonts.openSans(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        // Memberi warna latar belakang pada field
                        filled: true,
                        fillColor: const Color(0x33C4C4C4),
                        // Menghilangkan garis bawah default
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none, // Tidak ada garis tepi
                        ),
                        // Padding konten di dalam field
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 24.0,
                        ),
                        // DITAMBAHKAN: Ikon di ujung kanan
                        suffixIcon: Icon(
                          Icons.person_outline, // Ikon pengguna/user
                          color: Colors.black.withOpacity(
                            0.5,
                          ), // Warna disamakan dengan hintText
                        ),
                      ),
                    ),
                    const SizedBox(height: 27),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: GoogleFonts.openSans(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0x33C4C4C4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 24.0,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                        /* ... dekorasi lainnya ... */
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Tombol akan berubah menjadi loading indicator sesuai state
                    state is LoginLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4198FF),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Masuk',
                              style: GoogleFonts.openSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
