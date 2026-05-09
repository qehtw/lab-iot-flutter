import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/repositories/connectivity_repository.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._repo) : super(true);

  final ConnectivityRepository _repo;
  StreamSubscription<bool>? _sub;

  Future<void> monitor() async {
    final online = await _repo.isOnline;
    emit(online);
    _sub = _repo.statusStream.listen(emit, onError: (_) {});
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
