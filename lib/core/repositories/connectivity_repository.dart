abstract interface class ConnectivityRepository {
  Future<bool> get isOnline;
  Stream<bool> get statusStream;
}
