import 'package:app/models/pertemuan_model.dart';
import 'package:equatable/equatable.dart';

abstract class LaporanState extends Equatable {
  const LaporanState();
  @override
  List<Object?> get props => [];
}

class LaporanInitial extends LaporanState {}

class LaporanLoading extends LaporanState {}

// Kondisi saat riwayat pertemuan berhasil dimuat
class RiwayatPertemuanLoaded extends LaporanState {
  final List<Pertemuan> riwayat;
  const RiwayatPertemuanLoaded(this.riwayat);
}

class LaporanError extends LaporanState {
  final String message;
  const LaporanError(this.message);
}

// State untuk proses submit form
class LaporanSubmitting extends LaporanState {}

class LaporanSubmitSuccess extends LaporanState {}
