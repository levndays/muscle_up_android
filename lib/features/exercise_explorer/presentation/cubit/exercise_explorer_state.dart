// lib/features/exercise_explorer/presentation/cubit/exercise_explorer_state.dart
part of 'exercise_explorer_cubit.dart';

abstract class ExerciseExplorerState extends Equatable {
  const ExerciseExplorerState();
  @override
  List<Object?> get props => [];
}

class ExerciseExplorerInitial extends ExerciseExplorerState {}
class ExerciseExplorerLoading extends ExerciseExplorerState {}
class ExerciseExplorerLoaded extends ExerciseExplorerState {
  final List<PredefinedExercise> exercises;
  const ExerciseExplorerLoaded(this.exercises);
  @override
  List<Object?> get props => [exercises];
}
class ExerciseExplorerError extends ExerciseExplorerState {
  final String message;
  const ExerciseExplorerError(this.message);
  @override
  List<Object?> get props => [message];
}