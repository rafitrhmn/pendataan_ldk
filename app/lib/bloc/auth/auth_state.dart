part of 'auth_bloc.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;

  const AuthState._({this.status = AuthStatus.unknown, this.user});

  // State awal
  const AuthState.unknown() : this._();

  // State ketika user berhasil login
  const AuthState.authenticated(UserModel user)
    : this._(status: AuthStatus.authenticated, user: user);

  // State ketika user logout
  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  @override
  List<Object?> get props => [status, user];
}
