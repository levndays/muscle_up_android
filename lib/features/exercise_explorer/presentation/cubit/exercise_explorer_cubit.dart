// lib/features/exercise_explorer/presentation/cubit/exercise_explorer_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';
import '../../../../core/domain/repositories/predefined_exercise_repository.dart'; // Абстракція

part 'exercise_explorer_state.dart';

class ExerciseExplorerCubit extends Cubit<ExerciseExplorerState> {
  final PredefinedExerciseRepository _exerciseRepository;

  ExerciseExplorerCubit(this._exerciseRepository) : super(ExerciseExplorerInitial());

  Future<void> fetchExercises() async {
    emit(ExerciseExplorerLoading());
    try {
      final exercises = await _exerciseRepository.getAllExercises();
      emit(ExerciseExplorerLoaded(exercises));
    } catch (e) {
      emit(ExerciseExplorerError(e.toString()));
    }
  }
}