// lib/features/exercise_explorer/data/repositories/predefined_exercise_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';
import '../../../../core/domain/repositories/predefined_exercise_repository.dart';
import 'dart:developer' as developer; // Для логування


class PredefinedExerciseRepositoryImpl implements PredefinedExerciseRepository {
  final FirebaseFirestore _firestore;

  PredefinedExerciseRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<PredefinedExercise>> getAllExercises() async {
    try {
      final snapshot = await _firestore.collection('predefinedExercises').orderBy('name').get(); // Сортуємо за назвою
      return snapshot.docs
          .map((doc) => PredefinedExercise.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
    } catch (e) {
      developer.log("Error fetching exercises: $e", name: "PredefinedExerciseRepo");
      throw Exception('Failed to fetch predefined exercises.');
    }
  }
}