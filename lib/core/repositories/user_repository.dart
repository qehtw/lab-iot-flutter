import '../models/user.dart';

abstract interface class UserRepository {
  Future<User?> findByEmail(String email);
  Future<void> save(User user);
  Future<void> update(User user);
  Future<void> delete(String email);
}
