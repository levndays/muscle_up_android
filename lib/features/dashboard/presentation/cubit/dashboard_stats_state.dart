// lib/features/dashboard/presentation/cubit/dashboard_stats_state.dart
part of 'dashboard_stats_cubit.dart';

abstract class DashboardStatsState extends Equatable {
  const DashboardStatsState();

  @override
  List<Object?> get props => [];
}

class DashboardStatsInitial extends DashboardStatsState {}

class DashboardStatsLoading extends DashboardStatsState {}

class DashboardStatsLoaded extends DashboardStatsState {
  // Об'єми в кілограмах (не в тисячах), для точності передачі
  final List<double> volumes; // Останні 7 тренувань, від старого до нового

  const DashboardStatsLoaded({required this.volumes});

  @override
  List<Object?> get props => [volumes];
}

class DashboardStatsError extends DashboardStatsState {
  final String message;

  const DashboardStatsError(this.message);

  @override
  List<Object?> get props => [message];
}