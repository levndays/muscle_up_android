// lib/features/routines/presentation/cubit/manage_routine_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';

part 'manage_routine_state.dart';

class ManageRoutineCubit extends Cubit<ManageRoutineState> {
  final RoutineRepository _routineRepository;
  final FirebaseAuth _firebaseAuth;
  UserRoutine _currentRoutine; // Внутрішній стан рутини, що редагується
  final bool _isEditing;

  ManageRoutineCubit(
    this._routineRepository,
    this._firebaseAuth, {
    UserRoutine? initialRoutine,
  })  : _currentRoutine = initialRoutine ??
            UserRoutine(
              // Значення за замовчуванням для нової рутини
              id: '', // Буде встановлено репозиторієм
              userId: _firebaseAuth.currentUser?.uid ?? '',
              name: '',
              exercises: [],
              scheduledDays: [],
              isPublic: false,
              createdAt: Timestamp.now(), // Попереднє значення
              updatedAt: Timestamp.now(), // Попереднє значення
            ),
        _isEditing = initialRoutine != null,
        super(ManageRoutineInitial(
            routine: initialRoutine ??
                UserRoutine(
                  id: '',
                  userId: _firebaseAuth.currentUser?.uid ?? '',
                  name: '',
                  exercises: [],
                  scheduledDays: [],
                  isPublic: false,
                  createdAt: Timestamp.now(),
                  updatedAt: Timestamp.now(),
                ),
            isEditing: initialRoutine != null));

  UserRoutine get currentRoutineSnapshot => _currentRoutine;
  bool get isEditingMode => _isEditing;

  void updateRoutineName(String name) {
    _currentRoutine = _currentRoutine.copyWith(name: name);
    emit(ManageRoutineExercisesUpdated(_currentRoutine)); // Щоб UI оновився
  }

  void updateRoutineDescription(String description) {
    _currentRoutine = _currentRoutine.copyWith(description: description);
     emit(ManageRoutineExercisesUpdated(_currentRoutine));
  }

  void updateScheduledDays(List<String> days) {
    _currentRoutine = _currentRoutine.copyWith(scheduledDays: days);
     emit(ManageRoutineExercisesUpdated(_currentRoutine));
  }

  void addExerciseToRoutine(RoutineExercise exercise) {
    final updatedExercises = List<RoutineExercise>.from(_currentRoutine.exercises)..add(exercise);
    _currentRoutine = _currentRoutine.copyWith(exercises: updatedExercises);
    emit(ManageRoutineExercisesUpdated(_currentRoutine));
  }

  void updateExerciseInRoutine(int index, RoutineExercise exercise) {
    if (index < 0 || index >= _currentRoutine.exercises.length) return;
    final updatedExercises = List<RoutineExercise>.from(_currentRoutine.exercises);
    updatedExercises[index] = exercise;
    _currentRoutine = _currentRoutine.copyWith(exercises: updatedExercises);
    emit(ManageRoutineExercisesUpdated(_currentRoutine));
  }

  void removeExerciseFromRoutine(int index) {
    if (index < 0 || index >= _currentRoutine.exercises.length) return;
    final updatedExercises = List<RoutineExercise>.from(_currentRoutine.exercises)..removeAt(index);
    _currentRoutine = _currentRoutine.copyWith(exercises: updatedExercises);
    emit(ManageRoutineExercisesUpdated(_currentRoutine));
  }

  Future<void> saveRoutine() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const ManageRoutineFailure("User not logged in."));
      return;
    }
    if (_currentRoutine.name.trim().isEmpty) {
      emit(const ManageRoutineFailure("Routine name cannot be empty."));
      return;
    }
    if (_currentRoutine.exercises.isEmpty) {
      emit(const ManageRoutineFailure("Routine must have at least one exercise."));
      return;
    }

    emit(const ManageRoutineLoading(loadingMessage: "Saving routine..."));
    
    // Оновлюємо userId та timestamps перед збереженням
    _currentRoutine = _currentRoutine.copyWith(
        userId: userId, 
        // createdAt тут не оновлюємо, якщо isEditing, timestamp оновлюється в репо
        updatedAt: Timestamp.now(), // оновлюємо локально для консистентності
    );

    try {
      if (_isEditing) {
        await _routineRepository.updateRoutine(_currentRoutine);
        emit(ManageRoutineSuccess("Routine updated successfully!", _currentRoutine));
      } else {
        // Для нової рутини ID буде присвоєно в репозиторії,
        // але ми можемо створити тимчасовий локальний ID або чекати на повернення з репозиторію.
        // Краще, щоб репозиторій повертав створений об'єкт або його ID.
        // Наразі, припустимо, що репозиторій обробляє ID.
        // Або, якщо `createRoutine` повертає `UserRoutine`:
        // final savedRoutine = await _routineRepository.createRoutine(_currentRoutine);
        // emit(ManageRoutineSuccess("Routine created successfully!", savedRoutine));
        
        // Поточна реалізація createRoutine не повертає об'єкт, тому ми просто
        // передаємо _currentRoutine, припускаючи, що ID буде встановлено в Firestore
        // і для наступного завантаження воно буде коректним.
        await _routineRepository.createRoutine(_currentRoutine);
        emit(ManageRoutineSuccess("Routine created successfully!", _currentRoutine));
      }
    } catch (e) {
      emit(ManageRoutineFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }

   Future<void> deleteRoutine() async {
    if (!_isEditing || _currentRoutine.id.isEmpty) {
      emit(const ManageRoutineFailure("Cannot delete a new or unsaved routine."));
      return;
    }
     final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const ManageRoutineFailure("User not logged in."));
      return;
    }

    emit(const ManageRoutineLoading(loadingMessage: "Deleting routine..."));
    try {
      await _routineRepository.deleteRoutine(_currentRoutine.id);
      emit(ManageRoutineSuccess("Routine deleted successfully!", _currentRoutine)); // Повертаємо видалену рутину для обробки в UI
    } catch (e) {
      emit(ManageRoutineFailure(e.toString().replaceFirst("Exception: ", "")));
    }
  }
}