import 'package:equatable/equatable.dart';

abstract class KelompokEvent extends Equatable {
  const KelompokEvent();
  @override
  List<Object?> get props => [];
}

class FetchKelompok extends KelompokEvent {}

class CreateKelompok extends KelompokEvent {
  final String namaKelompok;
  final String jadwalPertemuan;
  final String mentorId;

  const CreateKelompok({
    required this.namaKelompok,
    required this.jadwalPertemuan,
    required this.mentorId,
  });
}

class UpdateKelompok extends KelompokEvent {
  final String id;
  final String namaKelompok;
  final String jadwalPertemuan;
  final String mentorId;

  const UpdateKelompok({
    required this.id,
    required this.namaKelompok,
    required this.jadwalPertemuan,
    required this.mentorId,
  });
}

class DeleteKelompok extends KelompokEvent {
  final String id;
  const DeleteKelompok({required this.id});
}

class SearchKelompok extends KelompokEvent {
  final String query;
  const SearchKelompok(this.query);
}

class SortKelompok extends KelompokEvent {
  final bool ascending;
  const SortKelompok(this.ascending);
}

class FetchKelompokDetail extends KelompokEvent {
  final String id;
  const FetchKelompokDetail(this.id);
}
