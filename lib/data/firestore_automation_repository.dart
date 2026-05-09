import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/automation_task.dart';
import '../core/repositories/automation_repository.dart';

class FirestoreAutomationRepository implements AutomationRepository {
  static const _cacheKey = 'cached_tasks';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Future<List<AutomationTask>> getTasks() async {
    try {
      final snapshot = await _db
          .collection('tasks')
          .get()
          .timeout(const Duration(seconds: 8));
      final tasks = snapshot.docs.asMap().entries.map((e) {
        final data = e.value.data();
        return AutomationTask(
          id: e.key,
          title: data['title'] as String? ?? e.value.id,
          completed: data['completed'] as bool? ?? false,
        );
      }).toList();
      await _saveCache(tasks);
      return tasks;
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
