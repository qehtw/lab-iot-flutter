import '../models/user.dart';

abstract interface class AuthRepository {
  Future<String?> register(User user);
  Future<(User?, String?)> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
