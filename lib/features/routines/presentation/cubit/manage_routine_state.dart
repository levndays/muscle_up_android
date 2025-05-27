// lib/features/routines/presentation/cubit/manage_routine_state.dart
part of 'manage_routine_cubit.dart';

abstract class ManageRoutineState extends Equatable {
  const ManageRoutineState();

  @override
  List<Object?> get props => [];
}

class ManageRoutineInitial extends ManageRoutineState {
  final UserRoutine routine; // Поточний стан рутини, що редагується/створюється
  final bool isEditing;

  const ManageRoutineInitial({required this.routine, this.isEditing = false});

  @override
  List<Object?> get props => [routine, isEditing];
}

class ManageRoutineLoading extends ManageRoutineState {
    final String? loadingMessage;
    const ManageRoutineLoading({this.loadingMessage});

    @override
    List<Object?> get props => [loadingMessage];
}

class ManageRoutineSuccess extends ManageRoutineState {
  final String message;
  final UserRoutine savedRoutine; // Повертаємо збережену рутину

  const ManageRoutineSuccess(this.message, this.savedRoutine);

  @override
  List<Object?> get props => [message, savedRoutine];
}

class ManageRoutineFailure extends ManageRoutineState {
  final String error;

  const ManageRoutineFailure(this.error);

  @override
  List<Object?> get props => [error];
}

// Додатковий стан для оновлення UI при зміні вправ у рутині
class ManageRoutineExercisesUpdated extends ManageRoutineState {
  final UserRoutine updatedRoutine;

  const ManageRoutineExercisesUpdated(this.updatedRoutine);

   @override
  List<Object?> get props => [updatedRoutine];
}