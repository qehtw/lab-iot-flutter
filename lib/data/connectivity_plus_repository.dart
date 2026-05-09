import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/repositories/connectivity_repository.dart';

class ConnectivityPlusRepository implements ConnectivityRepository {
  final _connectivity = Connectivity();

  @override
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Stream<bool> get statusStream => _connectivity.onConnectivityChanged.map(
    (results) => results.any((r) => r != ConnectivityResult.none),
  );
}
