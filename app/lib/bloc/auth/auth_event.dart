part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

// Event untuk memberitahu BLoC bahwa status autentikasi berubah (login/logout)
class AuthStatusChanged extends AuthEvent {
  final UserModel? user;
  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

// Event untuk meminta logout
class AuthLogoutRequested extends AuthEvent {}
