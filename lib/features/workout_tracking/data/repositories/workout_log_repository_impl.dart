// lib/features/workout_tracking/data/repositories/workout_log_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;

import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/repositories/workout_log_repository.dart';

class WorkoutLogRepositoryImpl implements WorkoutLogRepository {
  final FirebaseFirestore _firestore;

  WorkoutLogRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userWorkoutLogsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('workoutLogs');
  }

  @override
  Future<String> startWorkoutSession(WorkoutSession session) async {
    developer.log('Starting workout session for user ${session.userId}', name: 'WorkoutLogRepoImpl');
    try {
      final docRef = _userWorkoutLogsCollection(session.userId).doc();
      final sessionToSave = session.copyWith(
        id: docRef.id,
        startedAt: session.startedAt, 
        status: WorkoutStatus.inProgress,
      );
      
      Map<String, dynamic> sessionData = sessionToSave.toMap();
      await docRef.set(sessionData);
      developer.log('Workout session ${docRef.id} started.', name: 'WorkoutLogRepoImpl');
      return docRef.id;
    } catch (e, s) {
      developer.log('Error starting workout session: $e', error: e, stackTrace: s, name: 'WorkoutLogRepoImpl');
      throw Exception('Failed to start workout session: ${e.toString()}');
    }
  }

  @override
  Future<void> updateWorkoutSession(WorkoutSession session) async {
    developer.log('Updating workout session ${session.id} for user ${session.userId}', name: 'WorkoutLogRepoImpl');
    if (session.id.isEmpty) throw ArgumentError("Session ID cannot be empty for update.");
    try {
      await _userWorkoutLogsCollection(session.userId).doc(session.id).update(session.toMap());
      developer.log('Workout session ${session.id} updated.', name: 'WorkoutLogRepoImpl');
    } catch (e, s) {
      developer.log('Error updating workout session ${session.id}: $e', error: e, stackTrace: s, name: 'WorkoutLogRepoImpl');
      throw Exception('Failed to update workout session: ${e.toString()}');
    }
  }

  @override
  Future<void> completeWorkoutSession(WorkoutSession session) async {
    developer.log('Completing workout session ${session.id} for user ${session.userId}', name: 'WorkoutLogRepoImpl');
    if (session.id.isEmpty) throw ArgumentError("Session ID cannot be empty for completion.");
    try {
      final endedAt = session.endedAt ?? Timestamp.now(); 
      final duration = endedAt.seconds - session.startedAt.seconds;
      final totalVolume = session.calculateTotalVolume();

      final sessionToComplete = session.copyWith(
        endedAt: endedAt,
        durationSeconds: duration > 0 ? duration : 0,
        status: WorkoutStatus.completed,
        totalVolume: totalVolume,
      );
      await _userWorkoutLogsCollection(session.userId).doc(session.id).update(sessionToComplete.toMap());
      developer.log('Workout session ${session.id} completed. Total Volume: $totalVolume', name: 'WorkoutLogRepoImpl');
    } catch (e, s) {
      developer.log('Error completing workout session ${session.id}: $e', error: e, stackTrace: s, name: 'WorkoutLogRepoImpl');
      throw Exception('Failed to complete workout session: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelWorkoutSession(String userId, String sessionId) async {
    developer.log('Cancelling workout session $sessionId for user $userId', name: 'WorkoutLogRepoImpl');
    if (sessionId.isEmpty) throw ArgumentError("Session ID cannot be empty for cancellation.");
    try {
      await _userWorkoutLogsCollection(userId).doc(sessionId).update({
        'status': WorkoutStatus.cancelled.name,
        'endedAt': FieldValue.serverTimestamp(),
      });
      developer.log('Workout session $sessionId cancelled.', name: 'WorkoutLogRepoImpl');
    } catch (e, s) {
      developer.log('Error cancelling workout session $sessionId: $e', error: e, stackTrace: s, name: 'WorkoutLogRepoImpl');
      throw Exception('Failed to cancel workout session: ${e.toString()}');
    }
  }

  @override
  Future<WorkoutSession?> getWorkoutSession(String userId, String sessionId) async {
    developer.log('Getting workout session $sessionId for user $userId', name: 'WorkoutLogRepoImpl');
    try {
      final docSnapshot = await _userWorkoutLogsCollection(userId).doc(sessionId).get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return WorkoutSession.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e, s) {
      developer.log('Error getting workout session $sessionId: $e', error: e, stackTrace: s, name: 'WorkoutLogRepoImpl');
      throw Exception('Failed to get workout session: ${e.toString()}');
    }
  }

  @override
  Future<List<WorkoutSession>> getUserWorkoutHistory(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit = 20,
  }) async {
    developer.log('Fetching workout history for user $userId. Limit: $limit', name: 'WorkoutLogRepoImpl');
    try {
      Query<Map<String, dynamic>> query = _userWorkoutLogsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.completed.name) 
          .orderBy('startedAt', descending: true); 

      if (startDate != null) {
        query = query.where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        DateTime endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query.where('startedAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
      }
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => WorkoutSession.fromFirestore(doc)).toList();
    } catch (e, s) {
      developer.log('Error fetching workout history for user $userId: $e', error: e, stackTrace: s, name: 'WorkoutLogRepoImpl');
      throw Exception('Failed to fetch workout history: ${e.toString()}');
    }
  }

  @override
  Stream<WorkoutSession?> getActiveWorkoutSessionStream(String userId) {
    developer.log('Subscribing to active workout session for user $userId', name: 'WorkoutLogRepoImpl');
    return _userWorkoutLogsCollection(userId)
        .where('status', isEqualTo: WorkoutStatus.inProgress.name)
        .limit(1) 
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        developer.log('Active workout session found for user $userId: ${snapshot.docs.first.id}', name: 'WorkoutLogRepoImpl');
        return WorkoutSession.fromFirestore(snapshot.docs.first);
      }
      developer.log('No active workout session found for user $userId', name: 'WorkoutLogRepoImpl');
      return null;
    }).handleError((error, stackTrace) {
      developer.log('Error in active workout session stream for $userId: $error', error: error, stackTrace: stackTrace, name: 'WorkoutLogRepoImpl');
      return null; 
    });
  }

  // NEW METHOD IMPLEMENTATION
  @override
  Future<double?> getAverageWorkingWeightForExercise(String userId, String predefinedExerciseId, {int lookbackLimit = 10}) async {
    developer.log('Fetching average working weight for exercise $predefinedExerciseId, user $userId, limit $lookbackLimit sessions.', name: 'WorkoutLogRepoImpl');
    if (userId.isEmpty || predefinedExerciseId.isEmpty) return null;

    try {
      // 1. Get the last 'lookbackLimit' completed workout sessions for the user.
      final querySnapshot = await _userWorkoutLogsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.completed.name)
          .orderBy('startedAt', descending: true)
          .limit(lookbackLimit)
          .get();

      if (querySnapshot.docs.isEmpty) {
        developer.log('No completed workout sessions found for user $userId to calculate average weight.', name: 'WorkoutLogRepoImpl');
        return null;
      }

      List<double> allWeightsForExercise = [];

      // 2. Iterate through these sessions and their exercises.
      for (var sessionDoc in querySnapshot.docs) {
        final session = WorkoutSession.fromFirestore(sessionDoc);
        for (var loggedExercise in session.completedExercises) {
          if (loggedExercise.predefinedExerciseId == predefinedExerciseId) {
            for (var loggedSet in loggedExercise.completedSets) {
              if (loggedSet.isCompleted && loggedSet.weightKg != null && loggedSet.weightKg! > 0 && loggedSet.reps != null && loggedSet.reps! > 0) {
                allWeightsForExercise.add(loggedSet.weightKg!);
              }
            }
          }
        }
      }

      if (allWeightsForExercise.isEmpty) {
        developer.log('No valid sets found for exercise $predefinedExerciseId in the last $lookbackLimit sessions for user $userId.', name: 'WorkoutLogRepoImpl');
        return null;
      }

      // 3. Calculate the average weight.
      final double sum = allWeightsForExercise.reduce((a, b) => a + b);
      final double averageWeight = sum / allWeightsForExercise.length;
      
      // Round to nearest 0.5 or 1 (e.g., 22.5, 23.0)
      final double roundedAverageWeight = (averageWeight * 2).round() / 2.0;

      developer.log('Calculated average weight for exercise $predefinedExerciseId: $roundedAverageWeight (from ${allWeightsForExercise.length} sets)', name: 'WorkoutLogRepoImpl');
      return roundedAverageWeight;

    } catch (e, s) {
      developer.log('Error fetching average working weight for exercise $predefinedExerciseId: $e', error: e, stackTrace: s, name: 'WorkoutLogRepoImpl');
      return null; // Return null on error, Cubit can handle it
    }
  }
}