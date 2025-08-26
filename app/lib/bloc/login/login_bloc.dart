import 'package:app/models/user_model.dart';
import 'package:app/setttings/supabase_config.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  Future<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    // 1. Keluarkan state LoginLoading untuk menampilkan indicator
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

      // 3. Jika berhasil, keluarkan state LoginSuccess beserta data user
      emit(LoginSuccess(user: user));
    } on AuthException catch (e) {
      // 4. Jika gagal, keluarkan state LoginFailure dengan pesan error
      emit(LoginFailure(error: e.message));
    } catch (e) {
      emit(LoginFailure(error: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
