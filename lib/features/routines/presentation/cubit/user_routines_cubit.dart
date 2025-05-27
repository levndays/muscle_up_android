// lib/features/routines/presentation/cubit/user_routines_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Для отримання UID
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';

part 'user_routines_state.dart';

class UserRoutinesCubit extends Cubit<UserRoutinesState> {
  final RoutineRepository _routineRepository;
  final FirebaseAuth _firebaseAuth; // Для отримання UID

  UserRoutinesCubit(this._routineRepository, this._firebaseAuth) : super(UserRoutinesInitial());

  Future<void> fetchUserRoutines() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const UserRoutinesError("User not logged in. Cannot fetch routines."));
      return;
    }

    emit(UserRoutinesLoading());
    try {
      final routines = await _routineRepository.getUserRoutines(userId);
      emit(UserRoutinesLoaded(routines));
    } catch (e) {
      emit(UserRoutinesError(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  // Метод для оновлення списку після видалення рутини
  void routineDeleted(String routineId) {
    if (state is UserRoutinesLoaded) {
      final currentState = state as UserRoutinesLoaded;
      final updatedRoutines = currentState.routines.where((r) => r.id != routineId).toList();
      emit(UserRoutinesLoaded(updatedRoutines));
    }
  }
   // Метод для оновлення списку після додавання/редагування рутини
  void routineAddedOrUpdated(UserRoutine routine) {
    if (state is UserRoutinesLoaded) {
      final currentState = state as UserRoutinesLoaded;
      List<UserRoutine> updatedRoutines = List.from(currentState.routines);
      final index = updatedRoutines.indexWhere((r) => r.id == routine.id);
      if (index != -1) { // Оновлення існуючої
        updatedRoutines[index] = routine;
      } else { // Додавання нової
        updatedRoutines.insert(0, routine); // Додаємо на початок для кращого UX
      }
      emit(UserRoutinesLoaded(updatedRoutines));
    } else {
      // Якщо список ще не завантажений, просто завантажуємо його знову
      fetchUserRoutines();
    }
  }
}