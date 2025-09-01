import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/kader_model.dart';
import 'kader_event.dart';
import 'kader_state.dart';

class KaderBloc extends Bloc<KaderEvent, KaderState> {
  final supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;

  KaderBloc() : super(KaderInitial()) {
    on<FetchKaderisasi>(_onFetchKaderisasi);
    on<SearchKader>(_onSearchKader);
    on<SortKader>(_onSortKader);
    // Tambah akun kader
    on<CreateKaderAccount>(_onCreateKaderAccount);
  }

  Future<void> _onFetchKaderisasi(
    FetchKaderisasi event,
    Emitter<KaderState> emit,
  ) async {
    emit(KaderLoading());
    try {
      // fetch awal
      final response = await supabase
          .from('profiles')
          .select()
          .eq('role', 'kaderisasi');

      final cadres = (response as List).map((e) => Kader.fromJson(e)).toList();

      emit(KaderLoaded(allCadres: cadres, filteredCadres: cadres));

      // listen realtime sekali saja
      _subscription ??= supabase
          .channel('public:profiles')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'profiles',
            callback: (payload) {
              add(FetchKaderisasi()); // fetch ulang kalau ada perubahan
            },
          )
          .subscribe();
    } catch (e) {
      emit(KaderError(e.toString()));
    }
  }

  void _onSearchKader(SearchKader event, Emitter<KaderState> emit) {
    if (state is KaderLoaded) {
      final current = state as KaderLoaded;
      final filtered = current.allCadres
          .where(
            (kader) => kader.username.toLowerCase().contains(
              event.query.toLowerCase(),
            ),
          )
          .toList();

      emit(current.copyWith(filteredCadres: filtered));
    }
  }

  void _onSortKader(SortKader event, Emitter<KaderState> emit) {
    if (state is KaderLoaded) {
      final current = state as KaderLoaded;
      final sorted = [...current.filteredCadres]
        ..sort(
          (a, b) => event.ascending
              ? a.username.compareTo(b.username)
              : b.username.compareTo(a.username),
        );

      emit(current.copyWith(filteredCadres: sorted));
    }
  }

  Future<void> _onCreateKaderAccount(
    CreateKaderAccount event,
    Emitter<KaderState> emit,
  ) async {
    emit(KaderCreating());
    try {
      final response = await supabase.functions.invoke(
        'create-kader',
        body: {
          'username': event.username,
          'phone': event.phone,
          'jabatan': event.jabatan,
          'password': event.password,
        },
      );

      if (response.data['success'] == true) {
        emit(KaderCreated(event.username));

        // ✅ Setelah buat akun, langsung fetch ulang list
        add(FetchKaderisasi());
      } else {
        emit(KaderError(response.data['error'] ?? 'Gagal membuat akun kader'));
      }
    } catch (e) {
      emit(KaderError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
