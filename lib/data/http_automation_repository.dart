import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/automation_task.dart';
import '../core/repositories/auth_repository.dart';
import '../core/repositories/automation_repository.dart';

class HttpAutomationRepository implements AutomationRepository {
  HttpAutomationRepository(this._authRepo);

  final AuthRepository _authRepo;

  static const _url =
      'https://jsonplaceholder.typicode.com/todos?_limit=15';
  static const _cacheKey = 'cached_tasks';

  @override
  Future<List<AutomationTask>> getTasks() async {
    try {
      final token = await _authRepo.getToken();
      final headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : <String, String>{};
      final response = await http
          .get(Uri.parse(_url), headers: headers)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final tasks = (jsonDecode(response.body) as List)
            .map((e) => AutomationTask.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveCache(tasks);
        return tasks;
      }
    } catch (_) {}
    return _loadCache();
  }

  Future<void> _saveCache(List<AutomationTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<List<AutomationTask>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => AutomationTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
