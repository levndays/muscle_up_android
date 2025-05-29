// lib/features/workout_tracking/data/repositories/workout_log_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

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
        // Переконуємось, що startedAt встановлено, якщо не встановлено раніше,
        // або використовуємо серверний час, якщо це перше збереження.
        startedAt: session.startedAt, // Припускаємо, що startedAt встановлюється перед викликом
        status: WorkoutStatus.inProgress,
      );
      
      Map<String, dynamic> sessionData = sessionToSave.toMap();
      // Якщо startedAt ще не є Firebase Timestamp, а локальний DateTime, то
      // при першому збереженні може бути доцільно використовувати FieldValue.serverTimestamp()
      // Але якщо ми створюємо об'єкт WorkoutSession з Timestamp.now() перед викликом, то все ОК.
      // Для консистентності, можна додати перевірку та встановлення серверного часу:
      // if (sessionData['startedAt'] == null ) { // Або якась інша умова
      //   sessionData['startedAt'] = FieldValue.serverTimestamp();
      // }

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
      // `updatedAt` не є частиною моделі WorkoutSession, але може бути додано на рівні Firestore
      // Тут ми просто оновлюємо дані сесії.
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
      final endedAt = session.endedAt ?? Timestamp.now(); // Якщо не встановлено, беремо поточний
      final duration = endedAt.seconds - session.startedAt.seconds;
      final totalVolume = session.calculateTotalVolume();

      final sessionToComplete = session.copyWith(
        endedAt: endedAt,
        durationSeconds: duration,
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
        'endedAt': FieldValue.serverTimestamp(), // Позначаємо час скасування
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
    int? limit = 20, // Default limit
  }) async {
    developer.log('Fetching workout history for user $userId. Limit: $limit', name: 'WorkoutLogRepoImpl');
    try {
      Query<Map<String, dynamic>> query = _userWorkoutLogsCollection(userId)
          .where('status', isEqualTo: WorkoutStatus.completed.name) // Тільки завершені
          .orderBy('startedAt', descending: true); // Останні спочатку

      if (startDate != null) {
        query = query.where('startedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        // Для endDate, якщо ми хочемо включити весь день, треба брати кінець дня
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
        .limit(1) // Має бути тільки одна активна сесія
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
      // Важливо обробити помилку, можна повернути null або передати помилку далі
      // throw Exception('Active workout session stream error: ${error.toString()}');
      return null; // Повертаємо null у випадку помилки, щоб UI міг це обробити
    });
  }
}