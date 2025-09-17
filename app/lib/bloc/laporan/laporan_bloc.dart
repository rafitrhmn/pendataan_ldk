import 'package:app/models/pertemuan_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'laporan_event.dart';
import 'laporan_state.dart';

class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  final supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;

  LaporanBloc() : super(LaporanInitial()) {
    on<FetchRiwayatPertemuan>(_onFetchRiwayatPertemuan);
    on<CreateLaporanPertemuan>(_onCreateLaporanPertemuan);
  }

  Future<void> _onFetchRiwayatPertemuan(
    FetchRiwayatPertemuan event,
    Emitter<LaporanState> emit,
  ) async {
    emit(LaporanLoading());
    try {
      final data = await supabase
          .from('pertemuan')
          .select()
          .eq('kelompok_id', event.kelompokId)
          .order('tanggal', ascending: false);

      final riwayat = (data as List).map((e) => Pertemuan.fromJson(e)).toList();
      emit(RiwayatPertemuanLoaded(riwayat));

      _subscription?.unsubscribe();
      _subscription = supabase
          .channel('public:pertemuan:kelompok_id=${event.kelompokId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'pertemuan',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'kelompok_id',
              value: event.kelompokId,
            ),

            callback: (payload) {
              add(FetchRiwayatPertemuan(event.kelompokId));
            },
          )
          .subscribe();
    } catch (e) {
      emit(LaporanError(e.toString()));
    }
  }
  // lib/bloc/laporan/laporan_bloc.dart

  Future<void> _onCreateLaporanPertemuan(
    CreateLaporanPertemuan event,
    Emitter<LaporanState> emit,
  ) async {
    emit(LaporanSubmitting());
    try {
      final body = {
        'kelompok_id': event.kelompokId,
        'tanggal': event.tanggal.toIso8601String(),
        'tempat': event.tempat,
        'catatan': event.catatan,
        'foto_url': event.fotoUrl,
        'laporan_mentees': event.laporanMentees,
      };

      // ================== TAMBAHKAN DEBUG DI SINI ==================
      print('--- [DEBUG BLOC] Mengirim body ke Edge Function: ---');
      print(body);
      // =============================================================

      await supabase.functions.invoke('create-laporan-pertemuan', body: body);
      emit(LaporanSubmitSuccess());
    } catch (e) {
      // ================== TAMBAHKAN DEBUG DI SINI ==================
      print('--- [ERROR BLOC] Terjadi kesalahan saat invoke function: ---');
      print(e);
      // =============================================================
      emit(LaporanError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
