import 'package:app/models/kader_model.dart';
import 'package:equatable/equatable.dart';

abstract class KaderState extends Equatable {
  const KaderState();

  @override
  List<Object?> get props => [];
}

class KaderInitial extends KaderState {}

class KaderLoading extends KaderState {}

class KaderLoaded extends KaderState {
  final List<Kader> allCadres; // semua kaderisasi hasil fetch
  final List<Kader> filteredCadres; // hasil search + sort
  final int count;

  const KaderLoaded({required this.allCadres, required this.filteredCadres})
    : count = filteredCadres.length;

  KaderLoaded copyWith({List<Kader>? allCadres, List<Kader>? filteredCadres}) {
    return KaderLoaded(
      allCadres: allCadres ?? this.allCadres,
      filteredCadres: filteredCadres ?? this.filteredCadres,
    );
  }

  @override
  List<Object?> get props => [allCadres, filteredCadres, count];
}

class KaderError extends KaderState {
  final String message;
  const KaderError(this.message);

  @override
  List<Object?> get props => [message];
}
