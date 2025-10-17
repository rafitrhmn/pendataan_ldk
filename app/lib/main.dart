import 'package:app/bloc/auth/auth_bloc.dart';
import 'package:app/bloc/kader/kader_bloc.dart';
import 'package:app/bloc/kelompok/kelompok_bloc.dart';
import 'package:app/bloc/laporan/laporan_bloc.dart';
import 'package:app/bloc/login/login_bloc.dart';
import 'package:app/bloc/mentee/mentee_bloc.dart';
import 'package:app/bloc/mentor/mentor_bloc.dart';
import 'package:app/setttings/app_local.dart';
import 'package:app/setttings/supabase_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'setttings/app_router.dart';
import 'package:flutter_localization/flutter_localization.dart';

Future<void> main() async {
  // Pastikan Flutter binding sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // Panggil fungsi inisialisasi Supabase
  await initializeSupabase();
  await FlutterLocalization.instance.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  @override
  void initState() {
    localization.init(
      mapLocales: [
        const MapLocale('en', AppLocale.EN),
        const MapLocale('id', AppLocale.ID),
      ],
      initLanguageCode: 'id', // Bahasa default
    );
    localization.onTranslatedLanguage = _onTranslatedLanguage;
    super.initState();
  }

  void _onTranslatedLanguage(Locale? locale) {
    setState(() {});
  }

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
        BlocProvider(create: (context) => LaporanBloc()),
      ],
      child: MaterialApp.router(
        title: 'Aplikasi Flutter Saya',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        supportedLocales: localization.supportedLocales,
        localizationsDelegates: localization.localizationsDelegates,
      ),
    );
  }
}
