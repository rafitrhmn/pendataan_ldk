// lib/bloc/mentee/mentee_state.dart

import 'package:app/models/mentee_model.dart';
import 'package:equatable/equatable.dart';

abstract class MenteeState extends Equatable {
  const MenteeState();
  @override
  List<Object?> get props => [];
}

class MenteeInitial extends MenteeState {}

class MenteeLoading extends MenteeState {}

// class MenteeLoaded extends MenteeState {
//   final List<Mentee> mentees;
//   const MenteeLoaded(this.mentees);
// }

class MenteeLoaded extends MenteeState {
  final List<Mentee> allMentees; // Data asli dari database
  final List<Mentee>
  filteredMentees; // Data yang ditampilkan (hasil filter/search)

  const MenteeLoaded({required this.allMentees, required this.filteredMentees});

  // Method copyWith untuk mempermudah update state
  MenteeLoaded copyWith({
    List<Mentee>? allMentees,
    List<Mentee>? filteredMentees,
  }) {
    return MenteeLoaded(
      allMentees: allMentees ?? this.allMentees,
      filteredMentees: filteredMentees ?? this.filteredMentees,
    );
  }

  @override
  List<Object?> get props => [allMentees, filteredMentees];
}

class MenteeError extends MenteeState {
  final String message;
  const MenteeError(this.message);
}

// Aksi spesifik untuk feedback UI yang lebih baik
class MenteeSubmitting extends MenteeState {} // Untuk Create & Update

class MenteeSuccess extends MenteeState {} // Untuk Create, Update, Delete
