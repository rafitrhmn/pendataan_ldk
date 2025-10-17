import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/kader_model.dart';
import 'kader_event.dart';
import 'kader_state.dart';

class KaderBloc extends Bloc<KaderEvent, KaderState> {
  final supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;
  KaderLoaded? _lastLoadedState;

  KaderBloc() : super(KaderInitial()) {
    on<FetchKaderisasi>(_onFetchKaderisasi);
    on<SearchKader>(_onSearchKader);
    on<SortKader>(_onSortKader);
    on<CreateKaderAccount>(_onCreateKaderAccount);
    on<UpdateKader>(_onUpdateKader);
    on<DeleteKader>(_onDeleteKader);
    on<CheckKaderUsername>(_onCheckKaderUsername);
    on<ResetKaderState>(_onResetKaderState);
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

      // DIUBAH: Simpan state loaded ke dalam variabel
      final loadedState = KaderLoaded(
        allCadres: cadres,
        filteredCadres: cadres,
      );
      _lastLoadedState = loadedState;
      emit(loadedState);

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

  // BARU: Method untuk menangani event reset
  void _onResetKaderState(ResetKaderState event, Emitter<KaderState> emit) {
    // Jika ada state loaded yang tersimpan, kembalikan state tersebut
    if (_lastLoadedState != null) {
      emit(_lastLoadedState!);
    } else {
      // Sebagai pengaman, jika belum ada data, fetch dari awal
      add(FetchKaderisasi());
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

  Future<void> _onUpdateKader(
    UpdateKader event,
    Emitter<KaderState> emit,
  ) async {
    emit(KaderUpdating());
    try {
      // Memanggil Edge Function 'update-kader' yang baru saja kita buat
      final response = await supabase.functions.invoke(
        'update-kader',
        body: {
          'id': event.id,
          'username': event.newUsername,
          'jabatan': event.newJabatan,
          'no_hp': event.newPhone,
        },
      );

      if (response.data?['success'] == true) {
        emit(KaderUpdateSuccess());
        // Realtime akan menangani refresh, jadi tidak perlu add(FetchKaderisasi())
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

  /// Lokasi: lib/bloc/kader/kader_bloc.dart

  Future<void> _onCheckKaderUsername(
    CheckKaderUsername event,
    Emitter<KaderState> emit,
  ) async {
    if (event.username.isEmpty) {
      emit(KaderInitial());
      return;
    }

    emit(KaderUsernameChecking());
    try {
      //  PERBAIKAN DI SINI: Hapus 'final response ='
      await supabase
          .from('profiles')
          .select('id')
          .eq('username', event.username)
          .single();

      // Jika baris di atas berhasil tanpa error, berarti data ditemukan.
      // Artinya username sudah diambil.
      emit(const KaderUsernameTaken('Username ini sudah digunakan.'));
    } on PostgrestException catch (e) {
      // Jika Supabase melempar error 'PGRST116' (no rows found),
      // berarti username TERSEDIA.
      if (e.code == 'PGRST116') {
        emit(KaderUsernameAvailable());
      } else {
        emit(KaderUsernameTaken(e.message)); // Error lain dari Supabase
      }
    } catch (e) {
      emit(KaderUsernameTaken(e.toString())); // Error umum (misal: jaringan)
    }
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
