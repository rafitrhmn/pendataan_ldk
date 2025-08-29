import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Pastikan import Supabase ada
import '../../models/user_model.dart';
import '../../setttings/supabase_config.dart';

part 'kader_event.dart';
part 'kader_state.dart';

class KaderBloc extends Bloc<KaderEvent, KaderState> {
  List<UserModel> _originalCadres = [];

  KaderBloc() : super(KaderInitial()) {
    on<FetchKaderList>(_onFetchKaderList);
    on<SearchKader>(_onSearchKader);
    on<SortKader>(_onSortKader);
    // DITAMBAHKAN: Mendaftarkan event baru untuk membuat akun
    on<CreateKaderAccount>(_onCreateKaderAccount);
  }

  Future<void> _onFetchKaderList(
    FetchKaderList event,
    Emitter<KaderState> emit,
  ) async {
    // ... Logika fetch Anda yang sudah ada tidak diubah ...
    emit(KaderLoading());
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('role', 'kaderisasi');

      final cadres = response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();

      _originalCadres = cadres;
      emit(
        KaderLoaded(
          allCadres: _originalCadres,
          filteredCadres: _originalCadres,
        ),
      );
    } catch (e) {
      emit(KaderError('Gagal mengambil data kader: ${e.toString()}'));
    }
  }

  void _onSearchKader(SearchKader event, Emitter<KaderState> emit) {
    // ... Logika search Anda yang sudah ada tidak diubah ...
    final query = event.query.toLowerCase();
    final filtered = _originalCadres.where((kader) {
      return kader.username.toLowerCase().contains(query);
    }).toList();
    emit(KaderLoaded(allCadres: _originalCadres, filteredCadres: filtered));
  }

  void _onSortKader(SortKader event, Emitter<KaderState> emit) {
    // ... Logika sort Anda yang sudah ada tidak diubah ...
    if (state is KaderLoaded) {
      final currentList = (state as KaderLoaded).filteredCadres;
      currentList.sort((a, b) {
        return event.ascending
            ? a.username.compareTo(b.username)
            : b.username.compareTo(a.username);
      });
      emit(
        KaderLoaded(
          allCadres: _originalCadres,
          filteredCadres: List.from(currentList),
        ),
      );
    }
  }

  // --- HANDLER BARU UNTUK MEMBUAT AKUN ---
  Future<void> _onCreateKaderAccount(
    CreateKaderAccount event,
    Emitter<KaderState> emit,
  ) async {
    // 1. Emit state loading agar UI bisa menampilkan progress indicator
    emit(KaderCreationLoading());
    try {
      // 2. Logika pendaftaran dipindahkan ke sini
      final email = '${event.username.toLowerCase()}@alfaateh.com';

      // Langkah A: Daftarkan pengguna ke sistem Auth Supabase
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: event.password,
      );

      if (authResponse.user == null) {
        throw 'Pendaftaran Auth gagal, pengguna tidak tercipta.';
      }

      // Langkah B: Simpan profil dan perannya ke tabel 'profiles'
      await supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'username': event.username,
        'phone': event.phone,
        'jabatan': event.jabatan,
        'role': 'kaderisasi', // Peran sudah pasti kaderisasi
      });

      // 3. Emit state sukses
      emit(KaderCreationSuccess());

      // 4. (Opsional tapi sangat direkomendasikan) Panggil event FetchKaderList lagi
      // untuk me-refresh data di UI secara otomatis.
      add(FetchKaderList());
    } on AuthException catch (e) {
      emit(KaderCreationFailure('Gagal mendaftar: ${e.message}'));
    } catch (e) {
      emit(KaderCreationFailure('Terjadi error: ${e.toString()}'));
    }
  }
}
