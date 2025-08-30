import 'package:app/bloc/auth/auth_bloc.dart';
import 'package:app/models/user_model.dart';
import 'package:app/setttings/supabase_config.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'login_event.dart';
part 'login_state.dart';

// Tambahkan AuthBloc sebagai dependency
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthBloc _authBloc; // TAMBAHKAN INI

  LoginBloc({required AuthBloc authBloc}) // UBAH CONSTRUCTOR
    : _authBloc = authBloc,
      super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    // <-- DEBUG 1: Memastikan event diterima dan handler dimulai
    print('[LoginBloc] Proses login dimulai untuk username: ${event.username}');

    emit(LoginLoading());
    try {
      final email = '${event.username.toLowerCase()}@alfaateh.com';
      // <-- DEBUG 2: Memeriksa email yang dibuat
      print('[LoginBloc] Mencoba login dengan email: $email');

      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: event.password,
      );

      // <-- DEBUG 3: Memeriksa hasil dari Supabase Auth
      print(
        '[LoginBloc] Respon autentikasi diterima. User ID: ${authResponse.user?.id}',
      );

      if (authResponse.user == null) {
        throw 'User tidak ditemukan setelah autentikasi.';
      }

      // <-- DEBUG 4: Memeriksa query ke tabel profiles
      print('[LoginBloc] Mengambil profil untuk ID: ${authResponse.user!.id}');
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      // <-- DEBUG 5: Melihat data mentah profil dari database
      print('[LoginBloc] Data mentah profil: $profileResponse');

      final user = UserModel.fromJson(profileResponse);

      // <-- DEBUG 6: Memastikan parsing data berhasil
      print('[LoginBloc] Parsing UserModel berhasil. Role: ${user.role}');

      _authBloc.add(AuthStatusChanged(user));

      emit(LoginSuccess(user: user));
    } on AuthException catch (e) {
      // <-- DEBUG 7: Menangkap error spesifik dari Supabase Auth
      print('[LoginBloc] AuthException Terjadi: ${e.message}');
      emit(LoginFailure(error: e.message));
    } catch (e) {
      // <-- DEBUG 8: Menangkap error umum lainnya
      print('[LoginBloc] Error Umum Terjadi: ${e.toString()}');
      emit(LoginFailure(error: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
