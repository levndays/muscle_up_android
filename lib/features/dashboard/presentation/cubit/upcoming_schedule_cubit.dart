// FILE: lib/features/dashboard/presentation/cubit/upcoming_schedule_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';

part 'upcoming_schedule_state.dart';

class UpcomingScheduleCubit extends Cubit<UpcomingScheduleState> {
  final RoutineRepository _routineRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;

  UpcomingScheduleCubit(this._routineRepository, this._firebaseAuth)
      : super(UpcomingScheduleInitial()) {
    fetchUpcomingSchedule();
  }

  Future<void> fetchUpcomingSchedule() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const UpcomingScheduleError("User not authenticated."));
      return;
    }

    emit(UpcomingScheduleLoading());
    try {
      final routines = await _routineRepository.getUserRoutines(userId);
      if (routines.isEmpty) {
        emit(const UpcomingScheduleEmpty("No routines found to build a schedule."));
        return;
      }

      final Map<DateTime, List<String>> weeklySchedule = {};
      final DateTime today = DateTime.now();
      final DateFormat dayKeyFormat = DateFormat('E');

      for (int i = 0; i < 7; i++) {
        final date = DateTime(today.year, today.month, today.day + i);
        final dayKey = dayKeyFormat.format(date).toUpperCase();
        weeklySchedule[date] = [];

        for (final routine in routines) {
          if (routine.scheduledDays.map((d) => d.toUpperCase()).contains(dayKey)) {
            weeklySchedule[date]!.add(routine.name);
          }
        }
      }
      
      // Перевіряємо, чи є хоч одне тренування в розкладі
      bool hasScheduledWorkouts = weeklySchedule.values.any((routinesForDay) => routinesForDay.isNotEmpty);

      if (!hasScheduledWorkouts) {
         emit(const UpcomingScheduleEmpty("No workouts scheduled for the next 7 days."));
      } else {
        emit(UpcomingScheduleLoaded(schedule: weeklySchedule, startDate: DateTime(today.year, today.month, today.day)));
      }
      developer.log("UpcomingScheduleCubit: Schedule loaded: ${weeklySchedule.length} days", name: "UpcomingScheduleCubit");

    } catch (e, s) {
      developer.log("Error fetching upcoming schedule: $e", name: "UpcomingScheduleCubit", error: e, stackTrace: s);
      emit(UpcomingScheduleError("Failed to load schedule: ${e.toString()}"));
    }
  }
}