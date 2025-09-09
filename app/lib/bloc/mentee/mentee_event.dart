// lib/bloc/mentee/mentee_event.dart

import 'package:equatable/equatable.dart';

abstract class MenteeEvent extends Equatable {
  const MenteeEvent();
  @override
  List<Object?> get props => [];
}

class FetchMentees extends MenteeEvent {}

class CreateMentee extends MenteeEvent {
  final String namaLengkap;
  final String gender;
  final String prodi;
  final int semester;
  final int angkatan;
  final String noHp;

  const CreateMentee({
    required this.namaLengkap,
    required this.gender,
    required this.prodi,
    required this.semester,
    required this.angkatan,
    required this.noHp,
  });
}

class UpdateMentee extends MenteeEvent {
  final String id;
  final String namaLengkap;
  final String gender;
  final String prodi;
  final int semester;
  final int angkatan;
  final String noHp;

  const UpdateMentee({
    required this.id,
    required this.namaLengkap,
    required this.gender,
    required this.prodi,
    required this.semester,
    required this.angkatan,
    required this.noHp,
  });
}

class DeleteMentee extends MenteeEvent {
  final String id;
  const DeleteMentee({required this.id});
}

class SearchMentees extends MenteeEvent {
  final String query;
  const SearchMentees(this.query);

  @override
  List<Object?> get props => [query];
}

class SortMentees extends MenteeEvent {
  final bool ascending;
  const SortMentees(this.ascending);

  @override
  List<Object?> get props => [ascending];
}
