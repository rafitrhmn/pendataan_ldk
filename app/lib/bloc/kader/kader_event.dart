import 'package:equatable/equatable.dart';

abstract class KaderEvent extends Equatable {
  const KaderEvent();

  @override
  List<Object?> get props => [];
}

class FetchKaderisasi extends KaderEvent {}

class SearchKader extends KaderEvent {
  final String query;
  const SearchKader(this.query);

  @override
  List<Object?> get props => [query];
}

class SortKader extends KaderEvent {
  final bool ascending;
  const SortKader(this.ascending);

  @override
  List<Object?> get props => [ascending];
}
