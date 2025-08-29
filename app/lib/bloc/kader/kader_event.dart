part of 'kader_bloc.dart';

abstract class KaderEvent extends Equatable {
  const KaderEvent();
  @override
  List<Object> get props => [];
}

class FetchKaderList extends KaderEvent {}

// Event baru untuk memfilter daftar berdasarkan query pencarian
class SearchKader extends KaderEvent {
  final String query;
  const SearchKader(this.query);
  @override
  List<Object> get props => [query];
}

// Event baru untuk mengurutkan daftar
class SortKader extends KaderEvent {
  final bool ascending;
  const SortKader(this.ascending);
  @override
  List<Object> get props => [ascending];
}

// --- EVENT BARU DITAMBAHKAN DI SINI ---
class CreateKaderAccount extends KaderEvent {
  final String username;
  final String phone;
  final String jabatan;
  final String password;

  const CreateKaderAccount({
    required this.username,
    required this.phone,
    required this.jabatan,
    required this.password,
  });

  @override
  List<Object> get props => [username, phone, jabatan, password];
}
