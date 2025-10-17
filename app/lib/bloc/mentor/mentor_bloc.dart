import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/mentor_model.dart'; // DIUBAH
import 'mentor_event.dart'; // DIUBAH
import 'mentor_state.dart'; // DIUBAH

// DIUBAH: Nama class dari KaderBloc -> MentorBloc
class MentorBloc extends Bloc<MentorEvent, MentorState> {
  final supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;
  MentorLoaded? _lastLoadedState;

  MentorBloc() : super(MentorInitial()) {
    // DIUBAH
    // DIUBAH SEMUA EVENT DAN HANDLER
    on<FetchMentors>(_onFetchMentors);
    on<SearchMentors>(_onSearchMentors);
    on<SortMentors>(_onSortMentors);
    on<CreateMentorAccount>(_onCreateMentorAccount);
    on<UpdateMentor>(_onUpdateMentor);
    on<DeleteMentor>(_onDeleteMentor);
    on<CheckMentorUsername>(_onCheckMentorUsername); //  TAMBAHKAN INI
    on<ResetMentorState>(_onResetMentorState); //  TAMBAHKAN INI
  }

  // DIUBAH: Nama fungsi
  Future<void> _onFetchMentors(
    FetchMentors event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorLoading()); // DIUBAH
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('role', 'mentor');

      // DIUBAH: Menggunakan MentorModel
      final mentors = (response as List)
          .map((e) => MentorModel.fromJson(e))
          .toList();

      final loadedState = MentorLoaded(
        allMentors: mentors,
        filteredMentors: mentors,
      );
      _lastLoadedState = loadedState; //  TAMBAHKAN INI
      emit(loadedState);

      // Listener realtime tidak perlu diubah, karena ia memantau seluruh tabel 'profiles'.
      // Setiap ada perubahan, ia akan memicu FetchMentors lagi yang sudah difilter 'mentor'.
      _subscription ??= supabase
          .channel('public:profiles')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'profiles',
            callback: (payload) {
              add(FetchMentors()); // fetch ulang kalau ada perubahan
            },
          )
          .subscribe();
    } catch (e) {
      emit(MentorError(e.toString())); // DIUBAH
    }
  }

  // DIUBAH: Nama fungsi dan tipe data
  void _onSearchMentors(SearchMentors event, Emitter<MentorState> emit) {
    if (state is MentorLoaded) {
      // DIUBAH
      final current = state as MentorLoaded; // DIUBAH
      final filtered = current
          .allMentors // DIUBAH
          .where(
            (mentor) => mentor.username.toLowerCase().contains(
              // DIUBAH
              event.query.toLowerCase(),
            ),
          )
          .toList();

      emit(current.copyWith(filteredMentors: filtered));
    }
  }

  // DIUBAH: Nama fungsi dan tipe data
  void _onSortMentors(SortMentors event, Emitter<MentorState> emit) {
    if (state is MentorLoaded) {
      // DIUBAH
      final current = state as MentorLoaded; // DIUBAH
      final sorted =
          [...current.filteredMentors] // DIUBAH
            ..sort(
              (a, b) => event.ascending
                  ? a.username.compareTo(b.username)
                  : b.username.compareTo(a.username),
            );

      emit(current.copyWith(filteredMentors: sorted));
    }
  }

  // DIUBAH: Nama fungsi dan tipe data
  Future<void> _onCreateMentorAccount(
    CreateMentorAccount event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorCreating()); // DIUBAH
    try {
      // PERHATIAN: Memanggil Edge Function yang berbeda
      final response = await supabase.functions.invoke(
        'create-mentor', // DIUBAH
        body: {
          'username': event.username,
          'phone': event.phone,
          'jabatan': event.jabatan,
          'password': event.password,
        },
      );

      if (response.data['success'] == true) {
        emit(MentorCreated(event.username)); // DIUBAH
        add(FetchMentors()); // DIUBAH
      } else {
        emit(
          MentorError(response.data['error'] ?? 'Gagal membuat akun mentor'),
        ); // DIUBAH
      }
    } catch (e) {
      emit(MentorError(e.toString())); // DIUBAH
    }
  }

  // DIUBAH: Nama fungsi dan tipe data
  Future<void> _onUpdateMentor(
    UpdateMentor event,
    Emitter<MentorState> emit,
  ) async {
    emit(MentorUpdating()); // DIUBAH
    try {
      // PERHATIAN: Memanggil Edge Function yang berbeda
      final response = await supabase.functions.invoke(
        'update-mentor', // DIUBAH
        body: {
          'id': event.id,
          'username': event.newUsername,
          'jabatan': event.newJabatan,
          'no_hp': event.newPhone,
        },
      );

      if (response.data?['success'] == true) {
        emit(MentorUpdateSuccess()); // DIUBAH
      } else {
        emit(
          MentorError(response.data?['error'] ?? 'Gagal mengupdate mentor'),
        ); // DIUBAH
      }
    } catch (e) {
      emit(MentorError(e.toString())); // DIUBAH
    }
  }

  // DIUBAH: Nama fungsi dan tipe data
  Future<void> _onDeleteMentor(
    DeleteMentor event,
    Emitter<MentorState> emit,
  ) async {
    try {
      // PERHATIAN: Memanggil Edge Function yang berbeda
      final response = await supabase.functions.invoke(
        'delete-mentor', // DIUBAH
        body: {'id': event.id},
      );

      if (response.data?['success'] == true) {
        emit(MentorDeleteSuccess()); // DIUBAH
      } else {
        emit(
          MentorError(response.data?['error'] ?? 'Gagal menghapus mentor'),
        ); // DIUBAH
      }
    } catch (e) {
      emit(MentorError(e.toString())); // DIUBAH
    }
  }

  //  TAMBAHKAN METHOD BARU INI
  void _onResetMentorState(ResetMentorState event, Emitter<MentorState> emit) {
    if (_lastLoadedState != null) {
      emit(_lastLoadedState!);
    } else {
      add(FetchMentors());
    }
  }

  //  TAMBAHKAN METHOD BARU INI
  Future<void> _onCheckMentorUsername(
    CheckMentorUsername event,
    Emitter<MentorState> emit,
  ) async {
    if (event.username.isEmpty) {
      // Jika input kosong, reset ke state loaded terakhir agar UI tidak error
      if (_lastLoadedState != null) emit(_lastLoadedState!);
      return;
    }

    emit(MentorUsernameChecking());
    try {
      await supabase
          .from('profiles')
          .select('id')
          .eq('username', event.username)
          .single();
      emit(const MentorUsernameTaken('Username ini sudah digunakan.'));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        emit(MentorUsernameAvailable());
      } else {
        emit(MentorUsernameTaken(e.message));
      }
    } catch (e) {
      emit(MentorUsernameTaken(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
