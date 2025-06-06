// lib/features/dashboard/presentation/cubit/dashboard_stats_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;
import 'package:intl/intl.dart'; 

import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/routine_repository.dart'; 
import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/entities/routine.dart'; 

part 'dashboard_stats_state.dart';

class DashboardStatsCubit extends Cubit<DashboardStatsState> {
  final WorkoutLogRepository _workoutLogRepository;
  final RoutineRepository _routineRepository; 
  final fb_auth.FirebaseAuth _firebaseAuth;

  DashboardStatsCubit(
    this._workoutLogRepository,
    this._routineRepository, 
    this._firebaseAuth,
  ) : super(DashboardStatsInitial()) {
    fetchAllDashboardStats();
  }

  Future<void> fetchAllDashboardStats() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const DashboardStatsError("User not authenticated."));
      return;
    }

    emit(DashboardStatsLoading());
    try {
      // Fetch volume trend data
      final workoutHistoryForVolume = await _workoutLogRepository.getUserWorkoutHistory(
        userId,
        limit: 7,
      );
      final List<double> volumes = workoutHistoryForVolume
          .where((session) => session.status == WorkoutStatus.completed && session.totalVolume != null)
          .map((session) => session.totalVolume!)
          .toList()
          .reversed
          .toList();
      developer.log("DashboardStatsCubit: Fetched ${volumes.length} volumes for trend: $volumes", name: "DashboardStatsCubit");

      // Fetch adherence data
      final allUserRoutines = await _routineRepository.getUserRoutines(userId);
      final workoutHistoryForAdherence = await _workoutLogRepository.getUserWorkoutHistory(
        userId,
        startDate: DateTime.now().subtract(const Duration(days: 6)), 
        limit: null, 
      );
      
      final adherence = _calculateAdherence(
        allUserRoutines, 
        workoutHistoryForAdherence
      );
      developer.log("DashboardStatsCubit: Calculated adherence: $adherence%", name: "DashboardStatsCubit");

      emit(DashboardStatsLoaded(volumes: volumes, adherencePercentage: adherence));
    } catch (e, s) {
      developer.log("Error fetching dashboard stats: $e", name: "DashboardStatsCubit", error: e, stackTrace: s);
      emit(DashboardStatsError("Failed to load dashboard stats: ${e.toString()}"));
    }
  }

  double? _calculateAdherence(
    List<UserRoutine> allUserRoutines, 
    List<WorkoutSession> recentWorkoutLogs
  ) {
    int totalScheduledSlots = 0;
    Set<String> distinctCompletedScheduledInstances = {}; 

    final todayUtc = DateTime.now().toUtc();
    final DateFormat dayKeyFormatter = DateFormat('E'); 
    final DateFormat dateKeyFormatter = DateFormat('yyyy-MM-dd');

    for (int i = 0; i < 7; i++) { 
      final date = todayUtc.subtract(Duration(days: i));
      final dayKey = dayKeyFormatter.format(date).toUpperCase();

      for (final routine in allUserRoutines) {
        if (routine.scheduledDays.map((d) => d.toUpperCase()).contains(dayKey)) {
          totalScheduledSlots++;
        }
      }
    }

    if (totalScheduledSlots == 0) {
      developer.log("AdherenceCalc: No scheduled slots in the last 7 days.", name: "DashboardStatsCubit");
      return null; 
    }

    final sevenDaysAgoStart = DateTime(todayUtc.year, todayUtc.month, todayUtc.day - 6); 

    for (final session in recentWorkoutLogs) {
      if (session.status != WorkoutStatus.completed || session.routineId == null) continue;

      final sessionDateUtc = session.startedAt.toDate().toUtc();
      
      if (sessionDateUtc.isBefore(sevenDaysAgoStart)) continue;

      UserRoutine? routine;
      try {
        routine = allUserRoutines.firstWhere((r) => r.id == session.routineId);
      } catch (e) {
        // Routine not found in the user's list, might have been deleted after workout was logged.
        // Or if orElse was not used in previous version.
        developer.log("AdherenceCalc: Routine with ID ${session.routineId} not found in user's routines for session ${session.id}.", name: "DashboardStatsCubit");
        continue; 
      }
      
      if (routine.scheduledDays.isEmpty) continue; 

      final sessionDayKey = dayKeyFormatter.format(sessionDateUtc).toUpperCase();
      if (routine.scheduledDays.map((d) => d.toUpperCase()).contains(sessionDayKey)) {
        final distinctKey = "${dateKeyFormatter.format(sessionDateUtc)}_${routine.id}";
        distinctCompletedScheduledInstances.add(distinctKey);
      }
    }
    
    final completedScheduledSlots = distinctCompletedScheduledInstances.length;
    developer.log("AdherenceCalc: TotalScheduled: $totalScheduledSlots, CompletedDistinct: $completedScheduledSlots", name: "DashboardStatsCubit");
    
    return (completedScheduledSlots / totalScheduledSlots) * 100.0;
  }
}