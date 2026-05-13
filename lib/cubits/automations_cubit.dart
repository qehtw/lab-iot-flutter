import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/automation_task.dart';
import '../core/repositories/automation_repository.dart';

sealed class AutomationsState {}

final class AutomationsLoading extends AutomationsState {}

final class AutomationsLoaded extends AutomationsState {
  AutomationsLoaded(this.tasks);
  final List<AutomationTask> tasks;
}

final class AutomationsError extends AutomationsState {
  AutomationsError(this.message);
  final String message;
}

class AutomationsCubit extends Cubit<AutomationsState> {
  AutomationsCubit(this._repo) : super(AutomationsLoading());

  final AutomationRepository _repo;

  Future<void> loadTasks() async {
    emit(AutomationsLoading());
    try {
      final tasks = await _repo.getTasks();
      emit(AutomationsLoaded(tasks));
    } catch (e) {
      emit(AutomationsError(e.toString()));
    }
  }
}
