part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

// State awal saat halaman baru dimuat
class LoginInitial extends LoginState {}

// State saat proses login sedang berjalan (menampilkan loading)
class LoginLoading extends LoginState {}

// State saat login berhasil, membawa data pengguna
class LoginSuccess extends LoginState {
  final UserModel user;

  const LoginSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

// State saat login gagal, membawa pesan error
class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}
