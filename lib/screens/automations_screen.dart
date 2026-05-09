import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../core/models/automation_task.dart';
import '../core/repositories/automation_repository.dart';
import '../data/firestore_automation_repository.dart';
import '../data/http_automation_repository.dart';
import '../data/local_auth_repository.dart';
import '../data/local_user_repository.dart';

class AutomationsScreen extends StatefulWidget {
  const AutomationsScreen({super.key});

  @override
  State<AutomationsScreen> createState() => _AutomationsScreenState();
}

class _AutomationsScreenState extends State<AutomationsScreen> {
  late final Future<List<AutomationTask>> _future;

  @override
  void initState() {
    super.initState();
    final AutomationRepository repo = kIsWeb
        ? HttpAutomationRepository(LocalAuthRepository(LocalUserRepository()))
        : FirestoreAutomationRepository();
    _future = repo.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          },
        ),
        title: const Text(
          'Автоматизації',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder<List<AutomationTask>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _EmptyView(message: 'Не вдалося завантажити дані');
          }
          final tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const _EmptyView(message: 'Автоматизацій ще немає');
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tasks.length,
            itemBuilder: (_, i) => _TaskTile(task: tasks[i]),
          );
        },
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final AutomationTask task;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3040)),
      ),
      child: Row(
        children: [
          Icon(
            task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: task.completed ? primary : Colors.white38,
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: task.completed ? Colors.white54 : Colors.white,
                decoration: task.completed ? TextDecoration.lineThrough : null,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.white54)),
    );
  }
}
