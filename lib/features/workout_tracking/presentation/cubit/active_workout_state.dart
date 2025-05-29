// lib/features/workout_tracking/presentation/cubit/active_workout_state.dart
part of 'active_workout_cubit.dart';

abstract class ActiveWorkoutState extends Equatable {
  const ActiveWorkoutState();

  @override
  List<Object?> get props => [];
}

class ActiveWorkoutInitial extends ActiveWorkoutState {}

class ActiveWorkoutLoading extends ActiveWorkoutState {
  final String? message;
  const ActiveWorkoutLoading({this.message});
  @override
  List<Object?> get props => [message];
}

class ActiveWorkoutInProgress extends ActiveWorkoutState {
  final WorkoutSession session;
  final Duration currentDuration;

  const ActiveWorkoutInProgress({required this.session, required this.currentDuration});

  @override
  List<Object?> get props => [session, currentDuration];

  ActiveWorkoutInProgress copyWith({
    WorkoutSession? session,
    Duration? currentDuration,
  }) {
    return ActiveWorkoutInProgress(
      session: session ?? this.session,
      currentDuration: currentDuration ?? this.currentDuration,
    );
  }
}

class ActiveWorkoutNone extends ActiveWorkoutState {}

// Новий стан для успішного завершення з XP
class ActiveWorkoutSuccessfullyCompleted extends ActiveWorkoutState {
  final WorkoutSession completedSession;
  final int xpGained;
  // Можна додати інші дані, наприклад, чи був новий рівень

  const ActiveWorkoutSuccessfullyCompleted({
    required this.completedSession,
    required this.xpGained,
  });

  @override
  List<Object?> get props => [completedSession, xpGained];
}

// Стан для скасованого тренування
class ActiveWorkoutCancelled extends ActiveWorkoutState {
  final String message;
  const ActiveWorkoutCancelled({required this.message});
   @override
  List<Object?> get props => [message];
}


class ActiveWorkoutError extends ActiveWorkoutState {
  final String message;
  const ActiveWorkoutError(this.message);
  @override
  List<Object?> get props => [message];
}