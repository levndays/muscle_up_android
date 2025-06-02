// lib/features/routines/presentation/cubit/user_routines_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';
import 'dart:developer' as developer; // Додано для логування

part 'user_routines_state.dart';

class UserRoutinesCubit extends Cubit<UserRoutinesState> {
  final RoutineRepository _routineRepository;
  final FirebaseAuth _firebaseAuth;

  UserRoutinesCubit(this._routineRepository, this._firebaseAuth) : super(UserRoutinesInitial());

  Future<void> fetchUserRoutines() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const UserRoutinesError("User not logged in. Cannot fetch routines."));
      return;
    }
    
    developer.log("UserRoutinesCubit: Fetching user routines for $userId", name: "UserRoutinesCubit");

    // Якщо вже є завантажені дані, переходимо в UserRoutinesLoading з ними
    if (state is UserRoutinesLoaded) {
      final currentRoutines = (state as UserRoutinesLoaded).routines;
      emit(UserRoutinesLoading(routines: currentRoutines));
    } else {
      emit(const UserRoutinesLoading(routines: [])); // Початкове завантаження
    }

    try {
      final routines = await _routineRepository.getUserRoutines(userId);
      emit(UserRoutinesLoaded(routines));
      developer.log("UserRoutinesCubit: Fetched ${routines.length} routines.", name: "UserRoutinesCubit");
    } catch (e) {
      developer.log("UserRoutinesCubit: Error fetching routines: ${e.toString()}", name: "UserRoutinesCubit", error: e);
      emit(UserRoutinesError(e.toString().replaceFirst("Exception: ", "")));
    }
  }

  void routineDeleted(String routineId) {
    if (state is UserRoutinesLoaded) {
      final currentState = state as UserRoutinesLoaded;
      final updatedRoutines = currentState.routines.where((r) => r.id != routineId).toList();
      emit(UserRoutinesLoaded(updatedRoutines));
      developer.log("UserRoutinesCubit: Routine $routineId deleted locally.", name: "UserRoutinesCubit");
    } else if (state is UserRoutinesLoading && (state as UserRoutinesLoading).routines.isNotEmpty) {
      // Якщо ми в стані завантаження, але маємо старі дані
      final currentRoutines = (state as UserRoutinesLoading).routines;
      final updatedRoutines = currentRoutines.where((r) => r.id != routineId).toList();
      // Залишаємося в UserRoutinesLoading, але з оновленим списком, поки основне завантаження не завершиться
      emit(UserRoutinesLoading(routines: updatedRoutines));
      developer.log("UserRoutinesCubit: Routine $routineId deleted locally during loading.", name: "UserRoutinesCubit");
    }
  }

  void routineAddedOrUpdated(UserRoutine routine) {
    List<UserRoutine> currentRoutines = [];
    if (state is UserRoutinesLoaded) {
      currentRoutines = List.from((state as UserRoutinesLoaded).routines);
    } else if (state is UserRoutinesLoading && (state as UserRoutinesLoading).routines.isNotEmpty) {
      currentRoutines = List.from((state as UserRoutinesLoading).routines);
    }
    
    final index = currentRoutines.indexWhere((r) => r.id == routine.id);
    if (index != -1) { 
      currentRoutines[index] = routine;
      developer.log("UserRoutinesCubit: Routine ${routine.id} updated locally.", name: "UserRoutinesCubit");
    } else { 
      currentRoutines.insert(0, routine);
      developer.log("UserRoutinesCubit: Routine ${routine.id} added locally.", name: "UserRoutinesCubit");
    }
    // Оновлюємо стан на UserRoutinesLoaded, навіть якщо були в UserRoutinesLoading,
    // бо це дія користувача, яка має миттєво відобразитися.
    // Потім, якщо потрібно, можна викликати fetchUserRoutines для синхронізації.
    emit(UserRoutinesLoaded(currentRoutines));
    // Розгляньте можливість викликати fetchUserRoutines() тут,
    // якщо є ймовірність, що серверні дані змінилися інакше.
    // fetchUserRoutines(); 
  }
}