// FILE: lib/features/dashboard/presentation/cubit/upcoming_schedule_state.dart
part of 'upcoming_schedule_cubit.dart';

abstract class UpcomingScheduleState extends Equatable {
  const UpcomingScheduleState();

  @override
  List<Object?> get props => [];
}

class UpcomingScheduleInitial extends UpcomingScheduleState {}

class UpcomingScheduleLoading extends UpcomingScheduleState {}

// Стан для відображення розкладу
// Ключ - дата, значення - список назв рутин, запланованих на цей день
class UpcomingScheduleLoaded extends UpcomingScheduleState {
  final Map<DateTime, List<String>> schedule; // Розклад на 7 днів
  final DateTime startDate; // Дата початку 7-денного періоду

  const UpcomingScheduleLoaded({required this.schedule, required this.startDate});

  @override
  List<Object?> get props => [schedule, startDate];
}

class UpcomingScheduleEmpty extends UpcomingScheduleState {
  final String message;
  const UpcomingScheduleEmpty(this.message);
  @override
  List<Object?> get props => [message];
}

class UpcomingScheduleError extends UpcomingScheduleState {
  final String message;
  const UpcomingScheduleError(this.message);
  @override
  List<Object?> get props => [message];
}