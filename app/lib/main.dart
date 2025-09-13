import 'package:app/bloc/auth/auth_bloc.dart';
import 'package:app/bloc/kader/kader_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/login/login_bloc.dart';
import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentor/mentor_bloc.dart';
import 'package:app/setttings/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'setttings/app_router.dart';

Future<void> main() async {
  // Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Panggil fungsi inisialisasi Supabase
  await initializeSupabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(
          create: (context) => LoginBloc(authBloc: context.read<AuthBloc>()),
        ),
        BlocProvider(create: (context) => KaderBloc()),
        BlocProvider(create: (context) => MentorBloc()),
        BlocProvider(create: (context) => MenteeBloc()),
        BlocProvider(create: (context) => KelompokBloc()),
      ],
      child: MaterialApp.router(
        title: 'Aplikasi Flutter Saya',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
