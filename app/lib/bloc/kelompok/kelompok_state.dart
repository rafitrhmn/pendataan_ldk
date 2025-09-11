// lib/bloc/kelompok/kelompok_state.dart

import 'package:app/models/kelompok_model.dart';
import 'package:equatable/equatable.dart';

abstract class KelompokState extends Equatable {
  const KelompokState();
  @override
  List<Object?> get props => [];
}

class KelompokInitial extends KelompokState {}

class KelompokLoading extends KelompokState {}

class KelompokLoaded extends KelompokState {
  final List<Kelompok> kelompok;
  const KelompokLoaded(this.kelompok);
}

class KelompokError extends KelompokState {
  final String message;
  const KelompokError(this.message);
}

// State untuk proses Create/Update/Delete
class KelompokSubmitting extends KelompokState {}

class KelompokSuccess extends KelompokState {}
