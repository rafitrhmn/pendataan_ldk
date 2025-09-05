import 'package:app/models/mentor_model.dart'; // DIUBAH
import 'package:equatable/equatable.dart';

// DIUBAH: Nama base class
abstract class MentorState extends Equatable {
  const MentorState();

  @override
  List<Object?> get props => [];
}

// DIUBAH: Nama-nama class state
class MentorInitial extends MentorState {}

class MentorLoading extends MentorState {}

class MentorLoaded extends MentorState {
  final List<MentorModel> allMentors; // DIUBAH
  final List<MentorModel> filteredMentors; // DIUBAH
  final int count;

  const MentorLoaded({
    required this.allMentors,
    required this.filteredMentors,
  }) // DIUBAH
  : count = filteredMentors.length;

  // DIUBAH: Menggunakan MentorLoaded, MentorModel, dan nama variabel baru
  MentorLoaded copyWith({
    List<MentorModel>? allMentors,
    List<MentorModel>? filteredMentors,
  }) {
    return MentorLoaded(
      allMentors: allMentors ?? this.allMentors,
      filteredMentors: filteredMentors ?? this.filteredMentors,
    );
  }

  @override
  List<Object?> get props => [allMentors, filteredMentors, count];
}

class MentorError extends MentorState {
  final String message;
  const MentorError(this.message);

  @override
  List<Object?> get props => [message];
}

// 🔹 State khusus saat buat akun
class MentorCreating extends MentorState {}

class MentorCreated extends MentorState {
  final String username;
  const MentorCreated(this.username);

  @override
  List<Object?> get props => [username];
}

// 🔹 State khusus saat update akun
class MentorUpdating extends MentorState {}

class MentorUpdateSuccess extends MentorState {}

// 🔹 State khusus saat hapus akun
class MentorDeleting extends MentorState {}

class MentorDeleteSuccess extends MentorState {}
