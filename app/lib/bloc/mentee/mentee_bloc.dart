// lib/bloc/mentee/mentee_bloc.dart

import 'package:app/models/mentee_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mentee_event.dart';
import 'mentee_state.dart';

class MenteeBloc extends Bloc<MenteeEvent, MenteeState> {
  final supabase = Supabase.instance.client;
  // BARIS BARU: Variabel untuk menampung channel realtime
  RealtimeChannel? _subscription;

  MenteeBloc() : super(MenteeInitial()) {
    on<FetchMentees>(_onFetchMentees);
    on<CreateMentee>(_onCreateMentee);
    on<UpdateMentee>(_onUpdateMentee);
    on<DeleteMentee>(_onDeleteMentee);
    on<SearchMentees>(_onSearchMentees); // BARIS BARU: Menambahkan event search
    on<SortMentees>(_onSortMentees);
  }

  Future<void> _onFetchMentees(
    FetchMentees event,
    Emitter<MenteeState> emit,
  ) async {
    emit(MenteeLoading());
    try {
      final data = await supabase
          .from('mentee')
          .select()
          .order('nama_lengkap', ascending: true);
      final mentees = (data as List).map((e) => Mentee.fromJson(e)).toList();

      // DIUBAH: Mengirim dua list, satu untuk data asli, satu untuk tampilan
      emit(MenteeLoaded(allMentees: mentees, filteredMentees: mentees));

      // ================== LOGIKA REALTIME DITAMBAHKAN ==================
      // Hanya subscribe sekali saja saat pertama kali fetch berhasil
      _subscription ??= supabase
          .channel('public:mentee')
          .onPostgresChanges(
            event: PostgresChangeEvent.all, // INSERT, UPDATE, DELETE
            schema: 'public',
            table: 'mentee', // Pantau tabel 'mentee'
            callback: (payload) {
              // Jika ada perubahan, panggil ulang FetchMentees
              add(FetchMentees());
            },
          )
          .subscribe();
      // ================================================================
    } catch (e) {
      emit(MenteeError(e.toString()));
    }
  }

  // BARIS BARU: Method untuk menangani search
  void _onSearchMentees(SearchMentees event, Emitter<MenteeState> emit) {
    if (state is MenteeLoaded) {
      final current = state as MenteeLoaded;
      final filtered = current.allMentees
          .where(
            (mentee) => mentee.namaLengkap.toLowerCase().contains(
              event.query.toLowerCase(),
            ),
          )
          .toList();

      emit(current.copyWith(filteredMentees: filtered));
    }
  }

  Future<void> _onCreateMentee(
    CreateMentee event,
    Emitter<MenteeState> emit,
  ) async {
    emit(MenteeSubmitting());
    try {
      await supabase.functions.invoke(
        'create-mentee',
        body: {
          'nama_lengkap': event.namaLengkap,
          'gender': event.gender,
          'prodi': event.prodi,
          'semester': event.semester,
          'angkatan': event.angkatan,
          'no_hp': event.noHp,
        },
      );
      emit(MenteeCreateSuccess());
      // DIHAPUS: add(FetchMentees()); - Realtime akan menanganinya
    } catch (e) {
      emit(MenteeError(e.toString()));
    }
  }

  Future<void> _onUpdateMentee(
    UpdateMentee event,
    Emitter<MenteeState> emit,
  ) async {
    emit(MenteeSubmitting());
    try {
      await supabase.functions.invoke(
        'update-mentee',
        body: {
          'id': event.id,
          'nama_lengkap': event.namaLengkap,
          'gender': event.gender,
          'prodi': event.prodi,
          'semester': event.semester,
          'angkatan': event.angkatan,
          'no_hp': event.noHp,
        },
      );
      emit(MenteeUpdateSuccess());
      // DIHAPUS: add(FetchMentees());
    } catch (e) {
      emit(MenteeError(e.toString()));
    }
  }

  Future<void> _onDeleteMentee(
    DeleteMentee event,
    Emitter<MenteeState> emit,
  ) async {
    try {
      await supabase.functions.invoke('delete-mentee', body: {'id': event.id});
      emit(MenteeDeleteSuccess());
      // DIHAPUS: add(FetchMentees());
    } catch (e) {
      emit(MenteeError(e.toString()));
    }
  }

  // BARIS BARU: Override 'close' untuk unsubscribe dari channel
  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }

  void _onSortMentees(SortMentees event, Emitter<MenteeState> emit) {
    if (state is MenteeLoaded) {
      final current = state as MenteeLoaded;
      final sorted =
          [
              ...current.filteredMentees,
            ] // Urutkan dari daftar yang sudah difilter
            ..sort(
              (a, b) => event.ascending
                  ? a.namaLengkap.compareTo(b.namaLengkap)
                  : b.namaLengkap.compareTo(a.namaLengkap),
            );

      emit(current.copyWith(filteredMentees: sorted));
    }
  }
}
