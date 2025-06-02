// lib/features/dashboard/presentation/cubit/dashboard_stats_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/entities/workout_session.dart';

part 'dashboard_stats_state.dart';

class DashboardStatsCubit extends Cubit<DashboardStatsState> {
  final WorkoutLogRepository _workoutLogRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;

  DashboardStatsCubit(this._workoutLogRepository, this._firebaseAuth)
      : super(DashboardStatsInitial()) {
    fetchVolumeTrend();
  }

  Future<void> fetchVolumeTrend() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const DashboardStatsError("User not authenticated."));
      return;
    }

    emit(DashboardStatsLoading());
    try {
      final workoutHistory = await _workoutLogRepository.getUserWorkoutHistory(
        userId,
        limit: 7, // Останні 7 тренувань
      );
      
      // WorkoutLogRepository повертає від найновішого до найстарішого,
      // для графіка нам потрібен зворотній порядок.
      final List<double> volumes = workoutHistory
          .where((session) => session.status == WorkoutStatus.completed && session.totalVolume != null)
          .map((session) => session.totalVolume!)
          .toList()
          .reversed // Від старого до нового
          .toList();

      developer.log("DashboardStatsCubit: Fetched ${volumes.length} volumes for trend: $volumes", name: "DashboardStatsCubit");
      emit(DashboardStatsLoaded(volumes: volumes));
    } catch (e, s) {
      developer.log("Error fetching volume trend: $e", name: "DashboardStatsCubit", error: e, stackTrace: s);
      emit(DashboardStatsError("Failed to load volume trend: ${e.toString()}"));
    }
  }
}