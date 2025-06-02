// lib/features/routines/presentation/cubit/user_routines_state.dart
part of 'user_routines_cubit.dart';

abstract class UserRoutinesState extends Equatable {
  const UserRoutinesState();

  @override
  List<Object> get props => [];
}

class UserRoutinesInitial extends UserRoutinesState {}

class UserRoutinesLoading extends UserRoutinesState {
  final List<UserRoutine> routines; // Може містити попередньо завантажені рутини

  // Конструктор за замовчуванням, якщо немає попередніх даних
  const UserRoutinesLoading({this.routines = const []}); 

  @override
  List<Object> get props => [routines];
}

class UserRoutinesLoaded extends UserRoutinesState {
  final List<UserRoutine> routines;

  const UserRoutinesLoaded(this.routines);

  @override
  List<Object> get props => [routines];
}

class UserRoutinesError extends UserRoutinesState {
  final String message;

  const UserRoutinesError(this.message);

  @override
  List<Object> get props => [message];
}