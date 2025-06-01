// lib/features/workout_tracking/presentation/cubit/active_workout_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart'; // Імпорт пакету bloc
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/entities/logged_exercise.dart';
import '../../../../core/domain/entities/logged_set.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';

part 'active_workout_state.dart';

class ActiveWorkoutCubit extends Cubit<ActiveWorkoutState> {
  final WorkoutLogRepository _workoutLogRepository;
  final UserProfileRepository _userProfileRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;
  Timer? _durationTimer;
  StreamSubscription<WorkoutSession?>? _activeSessionSubscription;

  ActiveWorkoutCubit(
    this._workoutLogRepository,
    this._userProfileRepository,
    this._firebaseAuth,
  ) : super(ActiveWorkoutInitial()) { // Створюємо екземпляр стану
    _subscribeToActiveSession();
  }

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  void _subscribeToActiveSession() {
    final userId = _currentUserId;
    if (userId == null) {
      developer.log('ActiveWorkoutCubit: No user logged in, cannot subscribe.', name: 'ActiveWorkoutCubit');
      emit(ActiveWorkoutNone()); // Створюємо екземпляр стану
      return;
    }

    emit(const ActiveWorkoutLoading(message: 'Checking for active workout...'));
    _activeSessionSubscription?.cancel();
    _activeSessionSubscription = _workoutLogRepository.getActiveWorkoutSessionStream(userId).listen(
      (session) {
        if (session != null) {
          developer.log('ActiveWorkoutCubit: Active session found: ${session.id}', name: 'ActiveWorkoutCubit');
          _startDurationTimer(session);
          emit(ActiveWorkoutInProgress(session: session, currentDuration: _calculateDuration(session.startedAt.toDate())));
        } else {
          developer.log('ActiveWorkoutCubit: No active session found via stream.', name: 'ActiveWorkoutCubit');
          _durationTimer?.cancel();
          if (state is! ActiveWorkoutLoading || (state as ActiveWorkoutLoading).message?.contains('Starting new') == false ) {
             emit(ActiveWorkoutNone()); // Створюємо екземпляр стану
          }
        }
      },
      onError: (error, stackTrace) {
        developer.log('ActiveWorkoutCubit: Error in active session stream: $error', error: error, stackTrace: stackTrace, name: 'ActiveWorkoutCubit');
        emit(ActiveWorkoutError('Failed to check for active session: ${error.toString()}'));
      },
    );
  }

  Duration _calculateDuration(DateTime startTime) {
    return DateTime.now().difference(startTime);
  }

  void _startDurationTimer(WorkoutSession session) {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is ActiveWorkoutInProgress) {
        final currentSessionState = state as ActiveWorkoutInProgress;
        if (currentSessionState.session.id == session.id && currentSessionState.session.status == WorkoutStatus.inProgress) {
          emit(currentSessionState.copyWith(currentDuration: _calculateDuration(session.startedAt.toDate())));
        } else {
          timer.cancel(); 
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> startNewWorkout({UserRoutine? fromRoutine}) async {
    final userId = _currentUserId;
    if (userId == null) {
      emit(const ActiveWorkoutError("User not logged in. Cannot start workout."));
      return;
    }
    emit(const ActiveWorkoutLoading(message: 'Starting new workout...'));
    try {
      List<LoggedExercise> initialExercises = [];
      if (fromRoutine != null) {
        initialExercises = fromRoutine.exercises.map((re) {
          List<LoggedSet> sets = List.generate(
            re.numberOfSets > 0 ? re.numberOfSets : 1,
            (index) => LoggedSet(setNumber: index + 1),
          );
          return LoggedExercise(
            predefinedExerciseId: re.predefinedExerciseId,
            exerciseNameSnapshot: re.exerciseNameSnapshot,
            targetSets: re.numberOfSets,
            completedSets: sets,
            notes: re.notes,
          );
        }).toList();
      }

      final newSession = WorkoutSession(
        id: '', 
        userId: userId,
        routineId: fromRoutine?.id,
        routineNameSnapshot: fromRoutine?.name,
        startedAt: Timestamp.now(),
        status: WorkoutStatus.inProgress,
        completedExercises: initialExercises,
      );

      final sessionId = await _workoutLogRepository.startWorkoutSession(newSession);
      final startedSession = newSession.copyWith(id: sessionId); 
      
       _startDurationTimer(startedSession);
       emit(ActiveWorkoutInProgress(session: startedSession, currentDuration: Duration.zero));
      developer.log('ActiveWorkoutCubit: New workout started, session ID: $sessionId', name: 'ActiveWorkoutCubit');

    } catch (e,s) {
      developer.log('ActiveWorkoutCubit: Error starting new workout: $e', error: e, stackTrace: s, name: 'ActiveWorkoutCubit');
      emit(ActiveWorkoutError('Failed to start workout: ${e.toString()}'));
    }
  }

  Future<void> updateLoggedSet({
    required int exerciseIndex,
    required int setIndex,
    double? weight,
    int? reps,
    bool? isCompleted,
    String? notes,
  }) async {
    if (state is! ActiveWorkoutInProgress) return;
    final currentSessionState = state as ActiveWorkoutInProgress;
    final currentSession = currentSessionState.session;

    if (exerciseIndex < 0 || exerciseIndex >= currentSession.completedExercises.length) return;
    final targetExercise = currentSession.completedExercises[exerciseIndex];

    if (setIndex < 0 || setIndex >= targetExercise.completedSets.length) return;
    final targetSet = targetExercise.completedSets[setIndex];

    final updatedSet = targetSet.copyWith(
      weightKg: weight,
      reps: reps,
      isCompleted: isCompleted ?? ((weight != null && weight > 0 && reps != null && reps > 0) || targetSet.isCompleted),
      notes: notes,
      allowNullNotes: notes == null && targetSet.notes != null,
    );

    final updatedCompletedSets = List<LoggedSet>.from(targetExercise.completedSets);
    updatedCompletedSets[setIndex] = updatedSet;

    final updatedExercise = targetExercise.copyWith(completedSets: updatedCompletedSets);
    final updatedExercisesList = List<LoggedExercise>.from(currentSession.completedExercises);
    updatedExercisesList[exerciseIndex] = updatedExercise;

    final updatedSession = currentSession.copyWith(completedExercises: updatedExercisesList);

    emit(currentSessionState.copyWith(session: updatedSession));

    try {
      await _workoutLogRepository.updateWorkoutSession(updatedSession);
      developer.log('ActiveWorkoutCubit: Set updated in Firestore. Ex: $exerciseIndex, Set: $setIndex', name: 'ActiveWorkoutCubit');
    } catch (e) {
      developer.log('ActiveWorkoutCubit: Error updating set in Firestore: $e', name: 'ActiveWorkoutCubit');
      emit(ActiveWorkoutError('Failed to save set update: ${e.toString()}'));
      emit(currentSessionState.copyWith(session: currentSession));
    }
  }
  
  Future<void> addSetToExercise(int exerciseIndex) async {
    if (state is! ActiveWorkoutInProgress) return;
    final currentSessionState = state as ActiveWorkoutInProgress;
    final currentSession = currentSessionState.session;

    if (exerciseIndex < 0 || exerciseIndex >= currentSession.completedExercises.length) return;
    final targetExercise = currentSession.completedExercises[exerciseIndex];

    final newSetNumber = targetExercise.completedSets.length + 1;
    final newSet = LoggedSet(setNumber: newSetNumber);

    final updatedCompletedSets = List<LoggedSet>.from(targetExercise.completedSets)..add(newSet);
    final updatedExercise = targetExercise.copyWith(completedSets: updatedCompletedSets);
    
    final updatedExercisesList = List<LoggedExercise>.from(currentSession.completedExercises);
    updatedExercisesList[exerciseIndex] = updatedExercise;
    
    final updatedSession = currentSession.copyWith(completedExercises: updatedExercisesList);

    emit(currentSessionState.copyWith(session: updatedSession));
    try {
      await _workoutLogRepository.updateWorkoutSession(updatedSession);
      developer.log('ActiveWorkoutCubit: New set added to ex: $exerciseIndex', name: 'ActiveWorkoutCubit');
    } catch (e) {
       developer.log('ActiveWorkoutCubit: Error adding set in Firestore: $e', name: 'ActiveWorkoutCubit');
       emit(ActiveWorkoutError('Failed to save added set: ${e.toString()}'));
       final originalCompletedSets = List<LoggedSet>.from(targetExercise.completedSets);
       final originalExercise = targetExercise.copyWith(completedSets: originalCompletedSets);
       final originalExercisesList = List<LoggedExercise>.from(currentSession.completedExercises);
       originalExercisesList[exerciseIndex] = originalExercise;
       final originalSession = currentSession.copyWith(completedExercises: originalExercisesList);
       emit(currentSessionState.copyWith(session: originalSession));
    }
  }

  Future<void> completeWorkout() async {
    if (state is! ActiveWorkoutInProgress) return;
    final currentSessionState = state as ActiveWorkoutInProgress;
    final currentSession = currentSessionState.session;
    final userId = _currentUserId;

    if (userId == null) {
      emit(const ActiveWorkoutError("User not logged in."));
      return;
    }

    emit(const ActiveWorkoutLoading(message: 'Completing workout...'));
    try {
      final endedAt = Timestamp.now();
      final duration = endedAt.seconds - currentSession.startedAt.seconds;
      final totalVolume = currentSession.calculateTotalVolume();

      final sessionToComplete = currentSession.copyWith(
        endedAt: endedAt,
        durationSeconds: duration > 0 ? duration : 0,
        status: WorkoutStatus.completed,
        totalVolume: totalVolume,
      );

      // Викликаємо оновлення сесії, що ініціює Cloud Function
      await _workoutLogRepository.completeWorkoutSession(sessionToComplete);
      developer.log('ActiveWorkoutCubit: Workout ${sessionToComplete.id} marked as completed. Waiting for Cloud Function to update profile.', name: 'ActiveWorkoutCubit');
      
      _durationTimer?.cancel();

      // Після того, як Cloud Function оновила профіль, зчитуємо його знову для UI
      // Цей запит може бути швидшим, ніж оновлення через загальний стрім,
      // оскільки ми явно запитуємо документ.
      UserProfile? userProfile = await _userProfileRepository.getUserProfile(userId);
      
      if (userProfile == null) {
          emit(const ActiveWorkoutError("Could not retrieve user profile after workout completion."));
          return;
      }

      // Для екрану завершення, нам все одно потрібно передати xpGained,
      // оскільки Cloud Function не повертає його клієнту.
      // XP GAINED ТУТ ЦЕ БУДЕ ОЦІНКА НА ОСНОВІ ТРИВАЛОСТІ/ОБ'ЄМУ, що збігається з функцією.
      int xpGainedEstimated = 50; 
      if (totalVolume > 0) xpGainedEstimated += (totalVolume / 100).round();
      if (duration > 0) xpGainedEstimated += (duration / (5 * 60)).round();
      xpGainedEstimated = xpGainedEstimated.clamp(10, 200);


      emit(ActiveWorkoutSuccessfullyCompleted(
          completedSession: sessionToComplete, 
          xpGained: xpGainedEstimated, // Передаємо оцінене XP
          updatedUserProfile: userProfile // Передаємо оновлений профіль
      ));
    } catch (e, s) {
      developer.log('ActiveWorkoutCubit: Error completing workout: $e', error:e, stackTrace:s, name: 'ActiveWorkoutCubit');
      emit(ActiveWorkoutError('Failed to complete workout: ${e.toString()}'));
      emit(currentSessionState.copyWith());
    }
  }

  Future<void> cancelWorkout() async {
    if (state is! ActiveWorkoutInProgress) return;
    final currentSessionState = state as ActiveWorkoutInProgress;
    final currentSession = currentSessionState.session;
    final userId = _currentUserId;
     if (userId == null) {
      emit(const ActiveWorkoutError("User not logged in."));
      return;
    }

    emit(const ActiveWorkoutLoading(message: 'Cancelling workout...'));
    try {
      await _workoutLogRepository.cancelWorkoutSession(userId, currentSession.id);
      developer.log('ActiveWorkoutCubit: Workout ${currentSession.id} cancelled.', name: 'ActiveWorkoutCubit');
      _durationTimer?.cancel();
      emit(const ActiveWorkoutCancelled(message: 'Workout cancelled.'));
    } catch (e) {
      developer.log('ActiveWorkoutCubit: Error cancelling workout: $e', name: 'ActiveWorkoutCubit');
      emit(ActiveWorkoutError('Failed to cancel workout: ${e.toString()}'));
      emit(currentSessionState.copyWith());
    }
  }

  @override
  Future<void> close() {
    developer.log('ActiveWorkoutCubit: Closing and cancelling subscriptions.', name: 'ActiveWorkoutCubit');
    _durationTimer?.cancel();
    _activeSessionSubscription?.cancel();
    return super.close();
  }
}