part of 'kader_bloc.dart';

abstract class KaderState extends Equatable {
  const KaderState();
  @override
  List<Object> get props => [];
}

class KaderInitial extends KaderState {}

class KaderLoading extends KaderState {}

class KaderLoaded extends KaderState {
  // Menyimpan daftar asli yang tidak akan berubah saat difilter
  final List<UserModel> allCadres;
  // Menyimpan daftar yang akan ditampilkan di UI (hasil filter & sort)
  final List<UserModel> filteredCadres;

  const KaderLoaded({required this.allCadres, required this.filteredCadres});

  @override
  List<Object> get props => [allCadres, filteredCadres];
}

class KaderError extends KaderState {
  final String message;
  const KaderError(this.message);
  @override
  List<Object> get props => [message];
}

class KaderCreationLoading extends KaderState {}

class KaderCreationSuccess extends KaderState {}

class KaderCreationFailure extends KaderState {
  final String error;
  KaderCreationFailure(this.error);
}
