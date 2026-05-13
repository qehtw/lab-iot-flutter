import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/automation_task.dart';
import '../cubits/automations_cubit.dart';

class AutomationsScreen extends StatelessWidget {
  const AutomationsScreen({super.key});

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
      body: BlocBuilder<AutomationsCubit, AutomationsState>(
        builder: (context, state) {
          return switch (state) {
            AutomationsLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            AutomationsError() => const _EmptyView(
              message: 'Не вдалося завантажити дані',
            ),
            AutomationsLoaded(:final tasks) =>
              tasks.isEmpty
                  ? const _EmptyView(message: 'Автоматизацій ще немає')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: tasks.length,
                      itemBuilder: (_, i) => _TaskTile(task: tasks[i]),
                    ),
          };
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
