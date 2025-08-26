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
    emit(LoginLoading());
    try {
      // 2. Lakukan proses autentikasi dan ambil profil (logika yang sama seperti di controller)
      final email = '${event.username.toLowerCase()}@alfaateh.com';
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: event.password,
      );

      if (authResponse.user == null) {
        throw 'User tidak ditemukan setelah autentikasi.';
      }

      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single();
      final user = UserModel.fromJson(profileResponse);

      // LAPORKAN KE AuthBloc BAHWA LOGIN BERHASIL
      _authBloc.add(AuthStatusChanged(user));

      emit(LoginSuccess(user: user));
    } on AuthException catch (e) {
      // 4. Jika gagal, keluarkan state LoginFailure dengan pesan error
      emit(LoginFailure(error: e.message));
    } catch (e) {
      emit(LoginFailure(error: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
