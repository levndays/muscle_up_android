// lib/features/routines/data/repositories/routine_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';
import 'dart:developer' as developer; // Для логування

class RoutineRepositoryImpl implements RoutineRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth; // ЗАЛИШАЄМО, бо використовується для _currentUserId

  RoutineRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String? get _currentUserId => _firebaseAuth.currentUser?.uid; // Використовується

  @override
  Future<void> createRoutine(UserRoutine routine) async {
    final currentUserId = _currentUserId; // Зберігаємо в локальну змінну
    if (currentUserId == null) throw Exception('User not logged in');
    try {
      final docRef = _firestore.collection('userRoutines').doc();
      final routineData = routine.copyWith(
        id: docRef.id,
        userId: currentUserId, // Гарантуємо правильний userId
        createdAt: Timestamp.now(), 
        updatedAt: Timestamp.now()
      ).toMap()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(routineData);
    } catch (e) {
      developer.log("Error creating routine: $e", name: "RoutineRepositoryImpl");
      throw Exception('Failed to create routine.');
    }
  }

  @override
  Future<List<UserRoutine>> getUserRoutines(String userId) async {
    if (userId.isEmpty) throw Exception('User ID cannot be empty');
    try {
      final snapshot = await _firestore
          .collection('userRoutines')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => UserRoutine.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      developer.log("Error fetching user routines for $userId: $e", name: "RoutineRepositoryImpl");
      throw Exception('Failed to fetch user routines.');
    }
  }

  @override
  Future<void> updateRoutine(UserRoutine routine) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) throw Exception('User not logged in');
    if (routine.userId != currentUserId) throw Exception('Cannot update routine of another user');
    try {
      final routineData = routine.copyWith(updatedAt: Timestamp.now()).toMap()
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('userRoutines').doc(routine.id).update(routineData);
    } catch (e) {
      developer.log("Error updating routine ${routine.id}: $e", name: "RoutineRepositoryImpl");
      throw Exception('Failed to update routine.');
    }
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) throw Exception('User not logged in');
    try {
      final routineDoc = await _firestore.collection('userRoutines').doc(routineId).get();
      if (!routineDoc.exists || routineDoc.data()?['userId'] != currentUserId) {
        developer.log('Attempt to delete routine $routineId failed: Not found or permission denied.', name: "RoutineRepositoryImpl");
        throw Exception('Routine not found or permission denied to delete.');
      }
      await _firestore.collection('userRoutines').doc(routineId).delete();
    } catch (e) {
      developer.log("Error deleting routine $routineId: $e", name: "RoutineRepositoryImpl");
      // Не перезагортаємо у загальний Exception, якщо це вже специфічний
      if (e is! Exception || !e.toString().contains('Routine not found')) {
          throw Exception('Failed to delete routine.');
      }
      rethrow; // Перекидаємо оригінальну помилку, якщо це "Routine not found..."
    }
  }
}