// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'kader_event.dart';
// import 'kader_state.dart';

// class KaderBloc extends Bloc<KaderEvent, KaderState> {
//   final supabase = Supabase.instance.client;
//   RealtimeChannel? _channel;

//   KaderBloc() : super(KaderInitial()) {
//     on<FetchKaderisasi>(_onFetchKaderisasi);
//     _subscribeRealtime(); // langsung pas init
//   }

//   Future<void> _onFetchKaderisasi(
//     FetchKaderisasi event,
//     Emitter<KaderState> emit,
//   ) async {
//     emit(KaderLoading());
//     try {
//       final response = await supabase
//           .from('profiles')
//           .select()
//           .eq('role', 'kaderisasi');

//       final profiles = (response as List).cast<Map<String, dynamic>>();
//       emit(KaderLoaded(profiles));
//     } catch (e) {
//       emit(KaderError(e.toString()));
//     }
//   }

//   void _subscribeRealtime() {
//     _channel = supabase.channel('profiles-channel')
//       ..onPostgresChanges(
//         event: PostgresChangeEvent.all, // INSERT, UPDATE, DELETE
//         schema: 'public',
//         table: 'profiles',
//         callback: (payload) {
//           // setiap ada perubahan → fetch ulang data
//           add(FetchKaderisasi());
//         },
//       )
//       ..subscribe();
//   }

//   @override
//   Future<void> close() {
//     _channel?.unsubscribe();
//     return super.close();
//   }
// }

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

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
