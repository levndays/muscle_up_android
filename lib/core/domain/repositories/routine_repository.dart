// lib/core/domain/repositories/routine_repository.dart
import '../entities/routine.dart'; // Перевір цей імпорт також

abstract class RoutineRepository { // <-- Ключове слово "abstract class"
  Future<void> createRoutine(UserRoutine routine);
  Future<List<UserRoutine>> getUserRoutines(String userId);
  Future<void> updateRoutine(UserRoutine routine);
  Future<void> deleteRoutine(String routineId);
  // NEW METHOD
  Future<void> copyRoutineFromSnapshot(Map<String, dynamic> routineSnapshot, String targetUserId);
}