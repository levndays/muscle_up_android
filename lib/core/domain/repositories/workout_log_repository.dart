// lib/core/domain/repositories/workout_log_repository.dart
import '../entities/workout_session.dart';

abstract class WorkoutLogRepository {
  Future<String> startWorkoutSession(WorkoutSession session); // Повертає ID створеної сесії
  Future<void> updateWorkoutSession(WorkoutSession session);
  Future<void> completeWorkoutSession(WorkoutSession session);
  Future<void> cancelWorkoutSession(String userId, String sessionId);
  
  Future<WorkoutSession?> getWorkoutSession(String userId, String sessionId);
  Future<List<WorkoutSession>> getUserWorkoutHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });
  Stream<WorkoutSession?> getActiveWorkoutSessionStream(String userId);

  // NEW METHOD
  Future<double?> getAverageWorkingWeightForExercise(String userId, String predefinedExerciseId, {int lookbackLimit = 10});
}