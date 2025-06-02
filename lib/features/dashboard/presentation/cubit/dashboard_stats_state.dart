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
  final List<double> volumes; // Last 7 workouts, oldest to newest
  final double? adherencePercentage; // Adherence for the last 7 days

  const DashboardStatsLoaded({
    required this.volumes,
    this.adherencePercentage,
  });

  @override
  List<Object?> get props => [volumes, adherencePercentage];
}

class DashboardStatsError extends DashboardStatsState {
  final String message;

  const DashboardStatsError(this.message);

  @override
  List<Object?> get props => [message];
}