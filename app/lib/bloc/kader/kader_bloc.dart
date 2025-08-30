import 'dart:async'; // DITAMBAHKAN: Untuk StreamSubscription
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Pastikan import Supabase ada
import '../../models/user_model.dart';
import '../../setttings/supabase_config.dart';

part 'kader_event.dart';
part 'kader_state.dart';

class KaderBloc extends Bloc<KaderEvent, KaderState> {
  StreamSubscription? _kaderSubscription;

  KaderBloc() : super(KaderInitial()) {
    on<FetchKaderList>(_onFetchKaderList);
    on<SearchKader>(_onSearchKader);
    on<SortKader>(_onSortKader);
    // DITAMBAHKAN: Mendaftarkan event baru untuk membuat akun
    on<CreateKaderAccount>(_onCreateKaderAccount);
    // DITAMBAHKAN: Mulai mendengarkan perubahan saat BLoC dibuat
    _listenToKaderChanges();
  }

  // Listener ini sekarang menjadi satu-satunya sumber pembaruan data
  // setelah pengambilan data awal.
  void _listenToKaderChanges() {
    _kaderSubscription = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('role', 'kaderisasi')
        .listen(
          (payload) {
            print(
              '✅ Realtime: Perubahan terdeteksi pada tabel profiles! Mengambil data baru...',
            );
            // Jika BLoC belum ditutup, panggil event untuk mengambil semua data terbaru.
            if (!isClosed) {
              add(FetchKaderList());
            }
          },
          onError: (error) {
            // Tambahkan penanganan error untuk listener jika diperlukan
            print('🚨 Realtime Error: $error');
          },
        );
  }

  // DITAMBAHKAN: Override method close untuk membatalkan subscription
  @override
  Future<void> close() {
    _kaderSubscription?.cancel();
    return super.close();
  }

  // Method ini tidak berubah. Tetap digunakan untuk pengambilan data awal.
  Future<void> _onFetchKaderList(
    FetchKaderList event,
    Emitter<KaderState> emit,
  ) async {
    // Agar tidak menampilkan loading indicator saat realtime refresh,
    // kita cek apakah state sudah KaderLoaded.
    if (state is! KaderLoaded) {
      emit(KaderLoading());
    }
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('role', 'kaderisasi')
          .order(
            'created_at',
            ascending: false,
          ); // Urutkan berdasarkan data terbaru

      final cadres = response
          .map<UserModel>((json) => UserModel.fromJson(json))
          .toList();

      emit(KaderLoaded(allCadres: cadres, filteredCadres: cadres));
    } catch (e) {
      emit(KaderError('Gagal mengambil data kader: ${e.toString()}'));
    }
  }

  // Logika search dan sort tidak berubah, karena mereka bergantung pada
  // state KaderLoaded yang sudah benar.
  void _onSearchKader(SearchKader event, Emitter<KaderState> emit) {
    final currentState = state;
    if (currentState is KaderLoaded) {
      final query = event.query.toLowerCase();
      final filtered = currentState.allCadres.where((kader) {
        return kader.username.toLowerCase().contains(query);
      }).toList();
      emit(
        KaderLoaded(
          allCadres: currentState.allCadres,
          filteredCadres: filtered,
        ),
      );
    }
  }

  void _onSortKader(SortKader event, Emitter<KaderState> emit) {
    final currentState = state;
    if (currentState is KaderLoaded) {
      final currentList = List<UserModel>.from(currentState.filteredCadres);
      currentList.sort((a, b) {
        return event.ascending
            ? a.username.compareTo(b.username)
            : b.username.compareTo(a.username);
      });
      emit(
        KaderLoaded(
          allCadres: currentState.allCadres,
          filteredCadres: currentList,
        ),
      );
    }
  }

  // ... (kode BLoC lainnya tetap sama)

  Future<void> _onCreateKaderAccount(
    CreateKaderAccount event,
    Emitter<KaderState> emit,
  ) async {
    emit(KaderCreationLoading());
    try {
      print(
        "🚀 [KaderBloc] Memulai proses pembuatan akun untuk: ${event.username}",
      );

      final email = '${event.username.toLowerCase()}@alfaateh.com';
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: event.password,
      );

      if (authResponse.user == null) {
        throw 'Pendaftaran Auth gagal, pengguna tidak tercipta.';
      }

      print(
        "✅ [KaderBloc] Auth signUp berhasil. User ID: ${authResponse.user!.id}",
      );
      print("⏳ [KaderBloc] Mencoba memasukkan data ke tabel 'profiles'...");

      await supabase.from('profiles').insert({
        'id': authResponse.user!.id,
        'username': event.username,
        'no_hp': event.phone,
        'jabatan': event.jabatan,
        'role': 'kaderisasi',
      });

      print("✅ [KaderBloc] Insert ke 'profiles' berhasil.");

      emit(KaderCreationSuccess());

      // --- BLOK CATCH YANG DIPERBAIKI ---
    } on AuthException catch (e) {
      print("--- 🚨 ERROR: AuthException Terdeteksi! ---");
      print("Pesan Error: ${e.message}");
      print("Status Code: ${e.statusCode}");
      print("---------------------------------------------");
      emit(KaderCreationFailure('Gagal Auth: ${e.message}'));
    } on PostgrestException catch (e) {
      print(
        "--- 🚨 ERROR: PostgrestException Terdeteksi! (Masalah Database/RLS) ---",
      );
      print("Pesan Error: ${e.message}");
      print("Kode Error: ${e.code}");
      print("Detail Error: ${e.details}");
      print("Hint: ${e.hint}");
      print(
        "----------------------------------------------------------------------",
      );
      emit(KaderCreationFailure('Gagal Database: ${e.message}'));
    } catch (e) {
      print("--- 🚨 ERROR: Terjadi error yang tidak diketahui ---");
      print("Tipe Error: ${e.runtimeType}");
      print("Pesan Error: ${e.toString()}");
      print("----------------------------------------------------");
      emit(KaderCreationFailure('Terjadi error: ${e.toString()}'));
    }
  }
}
