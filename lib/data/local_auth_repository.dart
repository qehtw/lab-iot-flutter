import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/user.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/user_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._userRepo);

  final UserRepository _userRepo;
  static const _sessionKey = 'session_email';
  static const _tokenKey = 'auth_token';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String?> register(User user) async {
    final existing = await _userRepo.findByEmail(user.email);
    if (existing != null) return 'Email already registered';
    await _userRepo.save(user);
    final prefs = await _prefs;
    await prefs.setString(_sessionKey, user.email);
    await prefs.setString(_tokenKey, _generateToken());
    return null;
  }

  @override
  Future<(User?, String?)> login(String email, String password) async {
    final user = await _userRepo.findByEmail(email.trim());
    if (user == null) return (null, 'No account with this email');
    if (user.password != password) return (null, 'Incorrect password');
    final prefs = await _prefs;
    await prefs.setString(_sessionKey, user.email);
    await prefs.setString(_tokenKey, _generateToken());
    return (user, null);
  }

  @override
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionKey);
    await prefs.remove(_tokenKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await _prefs;
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;
    return _userRepo.findByEmail(email);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  String _generateToken() => 'tk_${DateTime.now().millisecondsSinceEpoch}';
}
