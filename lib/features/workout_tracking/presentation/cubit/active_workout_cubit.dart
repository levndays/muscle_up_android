// lib/features/workout_tracking/presentation/cubit/active_workout_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/entities/logged_exercise.dart';
import '../../../../core/domain/entities/logged_set.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/entities/predefined_exercise.dart'; // NEW
import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../../../../core/domain/repositories/predefined_exercise_repository.dart'; // NEW

part 'active_workout_state.dart';

class ActiveWorkoutCubit extends Cubit<ActiveWorkoutState> {
  final WorkoutLogRepository _workoutLogRepository;
  final UserProfileRepository _userProfileRepository;
  final PredefinedExerciseRepository _predefinedExerciseRepository; // NEW
  final fb_auth.FirebaseAuth _firebaseAuth;
  Timer? _durationTimer;
  StreamSubscription<WorkoutSession?>? _activeSessionSubscription;

  List<PredefinedExercise> _allPredefinedExercises = []; // NEW: Cache for exercise details

  ActiveWorkoutCubit(
    this._workoutLogRepository,
    this._userProfileRepository,
    this._predefinedExerciseRepository, // NEW
    this._firebaseAuth,
  ) : super(ActiveWorkoutInitial()) { 
    _subscribeToActiveSession();
  }

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  // NEW: Getter to access exercise details
  PredefinedExercise? getPredefinedExerciseById(String exerciseId) {
    try {
      return _allPredefinedExercises.firstWhere((ex) => ex.id == exerciseId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadPredefinedExercises() async {
    if (_allPredefinedExercises.isNotEmpty) return; // Load only once
    try {
      _allPredefinedExercises = await _predefinedExerciseRepository.getAllExercises();
      developer.log("ActiveWorkoutCubit: Loaded ${_allPredefinedExercises.length} predefined exercises.", name: "ActiveWorkoutCubit");
    } catch (e) {
      developer.log("ActiveWorkoutCubit: Failed to load predefined exercises: $e", name: "ActiveWorkoutCubit");
      // Handle error if necessary, maybe emit an error state
    }
  }

  void _subscribeToActiveSession() {
    final userId = _currentUserId;
    if (userId == null) {
      developer.log('ActiveWorkoutCubit: No user logged in, cannot subscribe.', name: 'ActiveWorkoutCubit');
      emit(ActiveWorkoutNone()); 
      return;
    }

    emit(const ActiveWorkoutLoading(message: 'Checking for active workout...'));
    _activeSessionSubscription?.cancel();
    _activeSessionSubscription = _workoutLogRepository.getActiveWorkoutSessionStream(userId).listen(
      (session) async { // Make async to load exercises
        if (session != null) {
          developer.log('ActiveWorkoutCubit: Active session found: ${session.id}', name: 'ActiveWorkoutCubit');
          await _loadPredefinedExercises(); // NEW: Load exercise details
          _startDurationTimer(session);
          emit(ActiveWorkoutInProgress(session: session, currentDuration: _calculateDuration(session.startedAt.toDate())));
        } else {
          developer.log('ActiveWorkoutCubit: No active session found via stream.', name: 'ActiveWorkoutCubit');
          _durationTimer?.cancel();
          if (state is! ActiveWorkoutLoading || (state as ActiveWorkoutLoading).message?.contains('Starting new') == false ) {
             emit(ActiveWorkoutNone()); 
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
      await _loadPredefinedExercises(); // NEW: Ensure exercise details are loaded
      List<LoggedExercise> initialExercises = [];
      if (fromRoutine != null) {
        for (final routineExercise in fromRoutine.exercises) {
          double? suggestedWeight;
          try {
            suggestedWeight = await _workoutLogRepository.getAverageWorkingWeightForExercise(userId, routineExercise.predefinedExerciseId);
            developer.log("Suggested weight for ${routineExercise.exerciseNameSnapshot}: $suggestedWeight kg", name: "ActiveWorkoutCubit.StartWorkout");
          } catch (e) {
            developer.log("Error getting suggested weight for ${routineExercise.exerciseNameSnapshot}: $e", name: "ActiveWorkoutCubit.StartWorkout");
          }

          List<LoggedSet> sets = List.generate(
            routineExercise.numberOfSets > 0 ? routineExercise.numberOfSets : 1,
            (index) => LoggedSet(
              setNumber: index + 1,
              weightKg: (index == 0 && suggestedWeight != null) ? suggestedWeight : null, 
            ),
          );
          initialExercises.add(LoggedExercise(
            predefinedExerciseId: routineExercise.predefinedExerciseId,
            exerciseNameSnapshot: routineExercise.exerciseNameSnapshot,
            targetSets: routineExercise.numberOfSets,
            completedSets: sets,
            notes: routineExercise.notes,
          ));
        }
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

  // ... (rest of the methods: updateLoggedSet, addSetToExercise, completeWorkout, cancelWorkout, close) remain the same
  
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

      await _workoutLogRepository.completeWorkoutSession(sessionToComplete);
      developer.log('ActiveWorkoutCubit: Workout ${sessionToComplete.id} marked as completed. Waiting for Cloud Function to update profile.', name: 'ActiveWorkoutCubit');
      
      _durationTimer?.cancel();

      UserProfile? userProfile = await _userProfileRepository.getUserProfile(userId);
      
      if (userProfile == null) {
          emit(const ActiveWorkoutError("Could not retrieve user profile after workout completion."));
          return;
      }

      int xpGainedEstimated = 50; 
      if (totalVolume > 0) xpGainedEstimated += (totalVolume / 100).round();
      if (duration > 0) xpGainedEstimated += (duration / (5 * 60)).round();
      xpGainedEstimated = xpGainedEstimated.clamp(10, 200);


      emit(ActiveWorkoutSuccessfullyCompleted(
          completedSession: sessionToComplete, 
          xpGained: xpGainedEstimated, 
          updatedUserProfile: userProfile 
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