// lib/bloc/kelompok/kelompok_state.dart

import 'package:app/models/kelompok_model.dart';
import 'package:app/models/mentee_model.dart';
import 'package:equatable/equatable.dart';

abstract class KelompokState extends Equatable {
  const KelompokState();
  @override
  List<Object?> get props => [];
}

class KelompokInitial extends KelompokState {}

class KelompokLoading extends KelompokState {}

class KelompokLoaded extends KelompokState {
  final List<Kelompok> allKelompok; // Data asli dari database
  final List<Kelompok>
  filteredKelompok; // Data yang ditampilkan (hasil filter/search/sort)

  const KelompokLoaded({
    required this.allKelompok,
    required this.filteredKelompok,
  });

  // Method copyWith untuk mempermudah update state
  KelompokLoaded copyWith({
    List<Kelompok>? allKelompok,
    List<Kelompok>? filteredKelompok,
  }) {
    return KelompokLoaded(
      allKelompok: allKelompok ?? this.allKelompok,
      filteredKelompok: filteredKelompok ?? this.filteredKelompok,
    );
  }

  @override
  List<Object?> get props => [allKelompok, filteredKelompok];
}

class KelompokError extends KelompokState {
  final String message;
  const KelompokError(this.message);
}

// State untuk proses Create/Update/Delete
class KelompokSubmitting extends KelompokState {}

class KelompokSuccess extends KelompokState {}

class KelompokDetailLoading extends KelompokState {}

class KelompokDetailLoaded extends KelompokState {
  final Kelompok kelompok;
  final List<Mentee> mentees; //  TAMBAHKAN INI

  const KelompokDetailLoaded({required this.kelompok, required this.mentees});
}
