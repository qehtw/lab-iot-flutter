import '../models/automation_task.dart';

abstract interface class AutomationRepository {
  Future<List<AutomationTask>> getTasks();
}
