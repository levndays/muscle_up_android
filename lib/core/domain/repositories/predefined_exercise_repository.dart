// lib/core/domain/repositories/predefined_exercise_repository.dart
import '../entities/predefined_exercise.dart';

abstract class PredefinedExerciseRepository {
  Future<List<PredefinedExercise>> getAllExercises();
  // В майбутньому: Future<List<PredefinedExercise>> searchExercises(String query);
  // В майбутньому: Future<List<PredefinedExercise>> filterExercises(Map<String, dynamic> filters);
}