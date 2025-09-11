// lib/bloc/kelompok/kelompok_bloc.dart

import 'package:app/models/kelompok_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kelompok_event.dart';
import 'kelompok_state.dart';

class KelompokBloc extends Bloc<KelompokEvent, KelompokState> {
  final supabase = Supabase.instance.client;
  // BARIS BARU: Variabel untuk menampung channel realtime
  RealtimeChannel? _subscription;

  KelompokBloc() : super(KelompokInitial()) {
    on<FetchKelompok>(_onFetchKelompok);
    on<CreateKelompok>(_onCreateKelompok);
    on<UpdateKelompok>(_onUpdateKelompok);
    on<DeleteKelompok>(_onDeleteKelompok);
    on<SearchKelompok>(_onSearchKelompok); //  TAMBAHKAN INI
    on<SortKelompok>(_onSortKelompok); //  TAMBAHKAN INI
  }

  Future<void> _onFetchKelompok(
    FetchKelompok event,
    Emitter<KelompokState> emit,
  ) async {
    emit(KelompokLoading());
    try {
      final data = await supabase
          .from('kelompok')
          .select('*, profiles(id, username)')
          .order('created_at', ascending: false);

      final kelompokList = (data as List)
          .map((e) => Kelompok.fromJson(e))
          .toList();
      emit(
        KelompokLoaded(
          allKelompok: kelompokList,
          filteredKelompok: kelompokList,
        ),
      );
      // Hanya subscribe sekali saja saat pertama kali fetch berhasil
      _subscription ??= supabase
          .channel('public:kelompok') // Channel spesifik untuk tabel kelompok
          .onPostgresChanges(
            event: PostgresChangeEvent.all, // INSERT, UPDATE, DELETE
            schema: 'public',
            table: 'kelompok', // Pantau tabel 'kelompok'
            callback: (payload) {
              // Jika ada perubahan, panggil ulang FetchKelompok
              add(FetchKelompok());
            },
          )
          .subscribe();
    } catch (e) {
      emit(KelompokError(e.toString()));
    }
  }

  //  TAMBAHKAN METHOD BARU UNTUK SEARCH
  void _onSearchKelompok(SearchKelompok event, Emitter<KelompokState> emit) {
    if (state is KelompokLoaded) {
      final current = state as KelompokLoaded;
      final filtered = current.allKelompok
          .where(
            (kelompok) => kelompok.namaKelompok.toLowerCase().contains(
              event.query.toLowerCase(),
            ),
          )
          .toList();
      emit(current.copyWith(filteredKelompok: filtered));
    }
  }

  //  TAMBAHKAN METHOD BARU UNTUK SORT
  void _onSortKelompok(SortKelompok event, Emitter<KelompokState> emit) {
    if (state is KelompokLoaded) {
      final current = state as KelompokLoaded;
      final sorted = [...current.filteredKelompok]
        ..sort(
          (a, b) => event.ascending
              ? a.namaKelompok.compareTo(b.namaKelompok)
              : b.namaKelompok.compareTo(a.namaKelompok),
        );
      emit(current.copyWith(filteredKelompok: sorted));
    }
  }

  Future<void> _onCreateKelompok(
    CreateKelompok event,
    Emitter<KelompokState> emit,
  ) async {
    emit(KelompokSubmitting());
    try {
      await supabase.from('kelompok').insert({
        'nama_kelompok': event.namaKelompok,
        'jadwal_pertemuan': event.jadwalPertemuan,
        'mentor_id': event.mentorId,
      });
      emit(KelompokSuccess());
      // DIHAPUS: add(FetchKelompok()); - Realtime akan menanganinya
    } catch (e) {
      emit(KelompokError(e.toString()));
    }
  }

  //  TAMBAHKAN METHOD BARU INI
  Future<void> _onUpdateKelompok(
    UpdateKelompok event,
    Emitter<KelompokState> emit,
  ) async {
    emit(KelompokSubmitting());
    try {
      // Update langsung ke tabel 'kelompok'
      await supabase
          .from('kelompok')
          .update({
            'nama_kelompok': event.namaKelompok,
            'jadwal_pertemuan': event.jadwalPertemuan,
            'mentor_id': event.mentorId,
          })
          .eq('id', event.id); // Filter berdasarkan ID

      emit(KelompokSuccess());
      // Realtime akan menangani refresh UI secara otomatis
    } catch (e) {
      emit(KelompokError(e.toString()));
    }
  }

  Future<void> _onDeleteKelompok(
    DeleteKelompok event,
    Emitter<KelompokState> emit,
  ) async {
    try {
      await supabase.from('kelompok').delete().eq('id', event.id);
      emit(KelompokSuccess()); // Realtime akan menangani refresh UI
    } catch (e) {
      emit(KelompokError(e.toString()));
    }
  }

  // BARIS BARU: Override 'close' untuk unsubscribe dari channel
  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
