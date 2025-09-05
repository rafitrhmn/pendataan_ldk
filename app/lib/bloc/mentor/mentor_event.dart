import 'package:equatable/equatable.dart';

// DIUBAH: Nama base class
abstract class MentorEvent extends Equatable {
  const MentorEvent();

  @override
  List<Object?> get props => [];
}

// DIUBAH: Nama class event
class FetchMentors extends MentorEvent {}

// DIUBAH: Nama class event
class SearchMentors extends MentorEvent {
  final String query;
  const SearchMentors(this.query);

  @override
  List<Object?> get props => [query];
}

// DIUBAH: Nama class event
class SortMentors extends MentorEvent {
  final bool ascending;
  const SortMentors(this.ascending);

  @override
  List<Object?> get props => [ascending];
}

// DIUBAH: Nama class event
class CreateMentorAccount extends MentorEvent {
  final String username;
  final String phone;
  final String jabatan;
  final String password;

  const CreateMentorAccount({
    required this.username,
    required this.phone,
    required this.jabatan,
    required this.password,
  });

  @override
  List<Object?> get props => [username, phone, jabatan, password];
}

// DIUBAH: Nama class event
class UpdateMentor extends MentorEvent {
  final String id;
  final String newUsername;
  final String newJabatan;
  final String newPhone;

  const UpdateMentor({
    required this.id,
    required this.newUsername,
    required this.newJabatan,
    required this.newPhone,
  });

  @override
  List<Object> get props => [id, newUsername, newJabatan, newPhone];
}

// DIUBAH: Nama class event
class DeleteMentor extends MentorEvent {
  final String id;

  const DeleteMentor({required this.id});

  @override
  List<Object> get props => [id];
}
