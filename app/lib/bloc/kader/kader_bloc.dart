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
    on<CreateKaderAccount>(_onCreateKaderAccount);
    on<UpdateKader>(_onUpdateKader);
    on<DeleteKader>(_onDeleteKader);
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

  // Method baru di dalam KaderBloc
  Future<void> _onUpdateKader(
    UpdateKader event,
    Emitter<KaderState> emit,
  ) async {
    emit(KaderUpdating());
    try {
      final response = await supabase.functions.invoke(
        'update-kader',
        body: {
          'id': event.id,
          'username': event.newUsername,
          'jabatan': event.newJabatan,
          'no_hp': event.newPhone, // Sesuaikan dengan nama kolom di tabel
        },
      );

      if (response.data?['success'] == true) {
        emit(KaderUpdateSuccess());
        // CATATAN: Kita tidak perlu fetch ulang di sini!
        // Listener realtime kita akan otomatis mendeteksi perubahan
        // dan memicu FetchKaderisasi. Sangat efisien!
      } else {
        emit(KaderError(response.data?['error'] ?? 'Gagal mengupdate kader'));
      }
    } catch (e) {
      emit(KaderError(e.toString()));
    }
  }

  // Method baru di dalam KaderBloc
  Future<void> _onDeleteKader(
    DeleteKader event,
    Emitter<KaderState> emit,
  ) async {
    // Kita bisa emit state loading jika ingin menampilkan feedback spesifik
    // emit(KaderDeleting()); // Opsional

    try {
      final response = await supabase.functions.invoke(
        'delete-kader',
        body: {'id': event.id},
      );

      if (response.data?['success'] == true) {
        emit(KaderDeleteSuccess());
        // Lagi-lagi, kita tidak perlu fetch ulang.
        // Realtime akan menangani refresh UI secara otomatis!
      } else {
        emit(KaderError(response.data?['error'] ?? 'Gagal menghapus kader'));
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
