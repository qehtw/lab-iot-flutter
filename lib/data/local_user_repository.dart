import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/user.dart';
import '../core/repositories/user_repository.dart';

class LocalUserRepository implements UserRepository {
  static String _key(String email) => 'user_${email.toLowerCase()}';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<User?> findByEmail(String email) async {
    final prefs = await _prefs;
    final json = prefs.getString(_key(email));
    if (json == null) return null;
    return User.fromJsonString(json);
  }

  @override
  Future<void> save(User user) async {
    final prefs = await _prefs;
    await prefs.setString(_key(user.email), user.toJsonString());
  }

  @override
  Future<void> update(User user) => save(user);

  @override
  Future<void> delete(String email) async {
    final prefs = await _prefs;
    await prefs.remove(_key(email));
  }
}
