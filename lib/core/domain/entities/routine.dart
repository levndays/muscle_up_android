// lib/core/domain/entities/routine.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart'; // Додай, якщо ще не маєш, для порівняння

// --- RoutineExercise ---
class RoutineExercise extends Equatable { // Зробимо Equatable для зручності
  final String predefinedExerciseId;
  final String exerciseNameSnapshot;
  final int numberOfSets;
  final String? notes;

  const RoutineExercise({ // Додай const
    required this.predefinedExerciseId,
    required this.exerciseNameSnapshot,
    required this.numberOfSets,
    this.notes,
  });

  factory RoutineExercise.fromMap(Map<String, dynamic> map) {
    return RoutineExercise(
      predefinedExerciseId: map['predefinedExerciseId'] ?? '',
      exerciseNameSnapshot: map['exerciseNameSnapshot'] ?? '',
      numberOfSets: map['numberOfSets'] is String
          ? int.tryParse(map['numberOfSets']) ?? 0
          : map['numberOfSets'] ?? 0, // Обробка, якщо numberOfSets приходить як String
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'predefinedExerciseId': predefinedExerciseId,
      'exerciseNameSnapshot': exerciseNameSnapshot,
      'numberOfSets': numberOfSets,
      'notes': notes,
    };
  }

  RoutineExercise copyWith({
    String? predefinedExerciseId,
    String? exerciseNameSnapshot,
    int? numberOfSets,
    String? notes, // Nullable для скидання значення
    bool allowNullNotes = false, // Прапорець для дозволу встановлення notes в null
  }) {
    return RoutineExercise(
      predefinedExerciseId: predefinedExerciseId ?? this.predefinedExerciseId,
      exerciseNameSnapshot: exerciseNameSnapshot ?? this.exerciseNameSnapshot,
      numberOfSets: numberOfSets ?? this.numberOfSets,
      notes: allowNullNotes ? notes : (notes ?? this.notes),
    );
  }

  @override
  List<Object?> get props => [predefinedExerciseId, exerciseNameSnapshot, numberOfSets, notes];
}

// --- UserRoutine ---
class UserRoutine extends Equatable { // Зробимо Equatable
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<RoutineExercise> exercises;
  final List<String> scheduledDays;
  final bool isPublic;
  // Додай інші поля згідно з дизайн-документом (communityRatingSum і т.д.)
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const UserRoutine({ // Додай const
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.exercises,
    required this.scheduledDays,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserRoutine.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("Routine data is null!");
    return UserRoutine(
      id: snapshot.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      exercises: (data['exercises'] as List<dynamic>?)
              ?.map((e) => RoutineExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      scheduledDays: List<String>.from(data['scheduledDays'] ?? []),
      isPublic: data['isPublic'] ?? false,
      // Важливо правильно обробляти Timestamps
      createdAt: data['createdAt'] is Timestamp ? data['createdAt'] : Timestamp.now(),
      updatedAt: data['updatedAt'] is Timestamp ? data['updatedAt'] : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'description': description,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'scheduledDays': scheduledDays,
      'isPublic': isPublic,
      // createdAt та updatedAt краще встановлювати через FieldValue.serverTimestamp() при записі
      // 'createdAt': createdAt, // Закоментуй, якщо встановлюєш через FieldValue
      // 'updatedAt': updatedAt, // Закоментуй, якщо встановлюєш через FieldValue
      // Додай інші поля
    };
  }

  UserRoutine copyWith({
    String? id,
    String? userId,
    String? name,
    String? description, // Nullable для скидання
    List<RoutineExercise>? exercises,
    List<String>? scheduledDays,
    bool? isPublic,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    bool allowNullDescription = false, // Прапорець для дозволу встановлення description в null
  }) {
    return UserRoutine(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: allowNullDescription ? description : (description ?? this.description),
      exercises: exercises ?? this.exercises,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        exercises,
        scheduledDays,
        isPublic,
        createdAt,
        updatedAt
      ];
}