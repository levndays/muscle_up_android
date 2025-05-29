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
  ) : super(ActiveWorkoutInitial()) {
    _subscribeToActiveSession();
  }

  String? get _currentUserId => _firebaseAuth.currentUser?.uid;

  void _subscribeToActiveSession() {
    final userId = _currentUserId;
    if (userId == null) {
      developer.log('ActiveWorkoutCubit: No user logged in, cannot subscribe.', name: 'ActiveWorkoutCubit');
      emit(ActiveWorkoutNone());
      return;
    }

    emit(const ActiveWorkoutLoading(message: 'Checking for active workout...'));
    _activeSessionSubscription?.cancel(); // Скасувати попередню підписку
    _activeSessionSubscription = _workoutLogRepository.getActiveWorkoutSessionStream(userId).listen(
      (session) {
        if (session != null) {
          developer.log('ActiveWorkoutCubit: Active session found: ${session.id}', name: 'ActiveWorkoutCubit');
          _startDurationTimer(session);
          emit(ActiveWorkoutInProgress(session: session, currentDuration: _calculateDuration(session.startedAt.toDate())));
        } else {
          developer.log('ActiveWorkoutCubit: No active session found.', name: 'ActiveWorkoutCubit');
          _durationTimer?.cancel();
          emit(ActiveWorkoutNone());
        }
      },
      onError: (error, stackTrace) {
        developer.log('ActiveWorkoutCubit: Error in active session stream.', name: 'ActiveWorkoutCubit', error: error, stackTrace: stackTrace);
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
        // Перевіряємо, чи сесія в стані все ще та сама, що й при запуску таймера
        if (currentSessionState.session.id == session.id && currentSessionState.session.status == WorkoutStatus.inProgress) {
          emit(currentSessionState.copyWith(currentDuration: _calculateDuration(session.startedAt.toDate())));
        } else {
          timer.cancel(); // Зупиняємо, якщо сесія змінилася або вже не inProgress
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
    // Якщо вже є активна сесія, не починаємо нову (стрім має це обробити)
    if (state is ActiveWorkoutInProgress) {
        developer.log('ActiveWorkoutCubit: Attempted to start new workout while one is in progress.', name: 'ActiveWorkoutCubit');
        // Можна нічого не робити, бо UI має оновитися на основі ActiveWorkoutInProgress
        return;
    }

    emit(const ActiveWorkoutLoading(message: 'Starting new workout...'));
    try {
      List<LoggedExercise> initialExercises = [];
      if (fromRoutine != null) {
        initialExercises = fromRoutine.exercises.map((re) {
          List<LoggedSet> sets = List.generate(
            re.numberOfSets > 0 ? re.numberOfSets : 1,
            (index) => LoggedSet(setNumber: index + 1), // isCompleted: false за замовчуванням
          );
          return LoggedExercise(
            predefinedExerciseId: re.predefinedExerciseId,
            exerciseNameSnapshot: re.exerciseNameSnapshot,
            targetSets: re.numberOfSets,
            completedSets: sets,
            notes: re.notes, // Переносимо нотатки з рутини, якщо є
          );
        }).toList();
      }

      final newSession = WorkoutSession(
        id: '', // Буде присвоєно репозиторієм
        userId: userId,
        routineId: fromRoutine?.id,
        routineNameSnapshot: fromRoutine?.name,
        startedAt: Timestamp.now(),
        status: WorkoutStatus.inProgress,
        completedExercises: initialExercises,
      );

      // Репозиторій поверне ID, але ми покладаємося на стрім для оновлення стану
      await _workoutLogRepository.startWorkoutSession(newSession);
      // Стрім _activeSessionSubscription має автоматично підхопити цю нову сесію
      // і оновити стан на ActiveWorkoutInProgress.
      developer.log('ActiveWorkoutCubit: Request to start new workout sent.', name: 'ActiveWorkoutCubit');
    } catch (e,s) {
      developer.log('ActiveWorkoutCubit: Error starting new workout.', name: 'ActiveWorkoutCubit', error: e, stackTrace: s);
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
      isCompleted: isCompleted ?? targetSet.isCompleted, // Якщо isCompleted не передано, залишаємо поточне
      notes: notes, // Якщо notes null, старе значення залишиться, якщо notes не null, воно оновиться
      allowNullNotes: notes == null && targetSet.notes != null, // Дозволяє скинути нотатку, якщо передано null
    );

    final updatedCompletedSets = List<LoggedSet>.from(targetExercise.completedSets);
    updatedCompletedSets[setIndex] = updatedSet;

    final updatedExercise = targetExercise.copyWith(completedSets: updatedCompletedSets);
    final updatedExercisesList = List<LoggedExercise>.from(currentSession.completedExercises);
    updatedExercisesList[exerciseIndex] = updatedExercise;

    final updatedSession = currentSession.copyWith(completedExercises: updatedExercisesList);

    // Оновлюємо стан локально
    emit(currentSessionState.copyWith(session: updatedSession));

    try {
      await _workoutLogRepository.updateWorkoutSession(updatedSession);
      developer.log('ActiveWorkoutCubit: Set updated in Firestore. Ex: $exerciseIndex, Set: $setIndex', name: 'ActiveWorkoutCubit');
    } catch (e,s) {
      developer.log('ActiveWorkoutCubit: Error updating set in Firestore.', name: 'ActiveWorkoutCubit', error: e, stackTrace: s);
      // Відновлюємо попередній стан сесії в UI, якщо збереження не вдалося
      emit(currentSessionState.copyWith(session: currentSession)); // Повертаємо оригінальну сесію
      // Можна також емітити помилку, яку UI покаже користувачу
      // emit(ActiveWorkoutError('Failed to save set update: ${e.toString()}'));
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
    } catch (e,s) {
       developer.log('ActiveWorkoutCubit: Error adding set in Firestore.', name: 'ActiveWorkoutCubit', error:e, stackTrace:s);
       // Відкат UI
       emit(currentSessionState.copyWith(session: currentSession));
       // emit(ActiveWorkoutError('Failed to save added set: ${e.toString()}'));
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

    emit(ActiveWorkoutLoading(message: 'Finishing workout...')); // Змінено повідомлення
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
      developer.log('ActiveWorkoutCubit: Workout ${sessionToComplete.id} completed. Total Volume: $totalVolume', name: 'ActiveWorkoutCubit');
      
      int xpGained = 50; // Базовий XP
      if (totalVolume > 0) xpGained += (totalVolume / 100).round();
      if (duration > 0) xpGained += (duration / (5 * 60)).round();
      xpGained = xpGained.clamp(10, 200);

      UserProfile? userProfile = await _userProfileRepository.getUserProfile(userId);
      if (userProfile != null) {
        DateTime lastWorkoutDate = userProfile.lastWorkoutTimestamp?.toDate() ?? DateTime(1970);
        DateTime currentWorkoutDate = sessionToComplete.startedAt.toDate();
        
        int newCurrentStreak = userProfile.currentStreak;
        bool isSameDayAsLastWorkout = 
            lastWorkoutDate.year == currentWorkoutDate.year &&
            lastWorkoutDate.month == currentWorkoutDate.month &&
            lastWorkoutDate.day == currentWorkoutDate.day;

        if (!isSameDayAsLastWorkout) {
            DateTime nextDayAfterLast = lastWorkoutDate.add(const Duration(days: 1));
            bool isConsecutiveDay = 
                nextDayAfterLast.year == currentWorkoutDate.year &&
                nextDayAfterLast.month == currentWorkoutDate.month &&
                nextDayAfterLast.day == currentWorkoutDate.day;
            if (isConsecutiveDay) {
                newCurrentStreak++;
            } else {
                newCurrentStreak = 1;
            }
        }

        int newLongestStreak = userProfile.longestStreak;
        if (newCurrentStreak > newLongestStreak) {
          newLongestStreak = newCurrentStreak;
        }
        
        int newXp = userProfile.xp + xpGained;
        // TODO: Логіка підвищення рівня
        // int newLevel = userProfile.level;
        // if (newXp >= someThresholdForNextLevel(userProfile.level)) { newLevel++; newXp = newXp - someThreshold; }

        UserProfile updatedProfile = userProfile.copyWith(
            currentStreak: newCurrentStreak,
            longestStreak: newLongestStreak,
            lastWorkoutTimestamp: () => sessionToComplete.endedAt ?? Timestamp.now(), // Використовуємо ValueGetter для nullable
            xp: newXp,
            // level: newLevel,
        );
        // Оновлюємо профіль, тільки якщо були зміни, щоб уникнути зайвих записів
        if (updatedProfile != userProfile) {
             await _userProfileRepository.updateUserProfile(updatedProfile);
             developer.log('ActiveWorkoutCubit: User profile updated. XP: $newXp, Streak: $newCurrentStreak', name: 'ActiveWorkoutCubit');
        }
      }

      _durationTimer?.cancel();
      emit(ActiveWorkoutSuccessfullyCompleted(completedSession: sessionToComplete, xpGained: xpGained));
    } catch (e,s) {
      developer.log('ActiveWorkoutCubit: Error completing workout.', name: 'ActiveWorkoutCubit', error:e, stackTrace:s);
      emit(ActiveWorkoutError('Failed to complete workout: ${e.toString()}'));
      // Повертаємо до стану InProgress з оригінальною сесією, щоб користувач міг спробувати знову
      emit(ActiveWorkoutInProgress(session: currentSession, currentDuration: currentSessionState.currentDuration));
    }
  }

  Future<void> cancelWorkout() async {
    if (state is! ActiveWorkoutInProgress) return;
    final currentSessionState = state as ActiveWorkoutInProgress; // Отримуємо поточний стан
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
    } catch (e,s) {
      developer.log('ActiveWorkoutCubit: Error cancelling workout.', name: 'ActiveWorkoutCubit', error:e, stackTrace:s);
      emit(ActiveWorkoutError('Failed to cancel workout: ${e.toString()}'));
      emit(ActiveWorkoutInProgress(session: currentSession, currentDuration: currentSessionState.currentDuration));
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