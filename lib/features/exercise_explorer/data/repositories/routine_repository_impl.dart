// lib/features/routines/data/repositories/routine_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Для отримання поточного userId
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth; // Додано

  RoutineRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth}) // Оновлено
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance; // Оновлено

  @override
  Future<void> createRoutine(UserRoutine routine) async {
    try {
      final docRef = _firestore.collection('userRoutines').doc();
      // Встановлюємо createdAt та updatedAt на серверний час при створенні
      final routineData = routine.toMap()
        ..['createdAt'] = FieldValue.serverTimestamp()
        ..['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(routineData);
    } catch (e) {
      print("Error creating routine: $e");
      throw Exception('Failed to create routine.');
    }
  }

  @override
  Future<List<UserRoutine>> getUserRoutines(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('userRoutines')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true) // Сортування за датою створення
          .get();
      return snapshot.docs
          .map((doc) => UserRoutine.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      print("Error fetching user routines: $e");
      throw Exception('Failed to fetch user routines.');
    }
  }

  @override
  Future<void> updateRoutine(UserRoutine routine) async {
    try {
      final routineData = routine.toMap()..['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('userRoutines').doc(routine.id).update(routineData);
    } catch (e) {
      print("Error updating routine: $e");
      throw Exception('Failed to update routine.');
    }
  }

  @override
  Future<void> deleteRoutine(String routineId) async {
    try {
      await _firestore.collection('userRoutines').doc(routineId).delete();
    } catch (e) {
      print("Error deleting routine: $e");
      throw Exception('Failed to delete routine.');
    }
  }
}