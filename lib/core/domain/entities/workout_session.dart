// lib/core/domain/entities/workout_session.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'logged_exercise.dart';

enum WorkoutStatus { inProgress, completed, cancelled }

class WorkoutSession extends Equatable {
  final String id;
  final String userId;
  final String? routineId; // ID рутини, якщо тренування на її основі
  final String? routineNameSnapshot; // Назва рутини на момент початку
  final Timestamp startedAt;
  final Timestamp? endedAt;
  final int? durationSeconds; // Розраховується при завершенні
  final List<LoggedExercise> completedExercises;
  final String? notes; // Загальні нотатки до тренування
  final WorkoutStatus status;
  final double? totalVolume; // Розраховується при завершенні

  const WorkoutSession({
    required this.id,
    required this.userId,
    this.routineId,
    this.routineNameSnapshot,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.completedExercises = const [],
    this.notes,
    required this.status,
    this.totalVolume,
  });

  // Розраховує загальний об'єм для всієї сесії
  double calculateTotalVolume() {
    return completedExercises.fold(0.0, (sum, exercise) => sum + exercise.totalVolume);
  }

  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? routineId,
    bool allowNullRoutineId = false,
    String? routineNameSnapshot,
    bool allowNullRoutineNameSnapshot = false,
    Timestamp? startedAt,
    Timestamp? endedAt,
    bool allowNullEndedAt = false,
    int? durationSeconds,
    bool allowNullDurationSeconds = false,
    List<LoggedExercise>? completedExercises,
    String? notes,
    bool allowNullNotes = false,
    WorkoutStatus? status,
    double? totalVolume,
    bool allowNullTotalVolume = false,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routineId: allowNullRoutineId ? routineId : (routineId ?? this.routineId),
      routineNameSnapshot: allowNullRoutineNameSnapshot ? routineNameSnapshot : (routineNameSnapshot ?? this.routineNameSnapshot),
      startedAt: startedAt ?? this.startedAt,
      endedAt: allowNullEndedAt ? endedAt : (endedAt ?? this.endedAt),
      durationSeconds: allowNullDurationSeconds ? durationSeconds : (durationSeconds ?? this.durationSeconds),
      completedExercises: completedExercises ?? this.completedExercises,
      notes: allowNullNotes ? notes : (notes ?? this.notes),
      status: status ?? this.status,
      totalVolume: allowNullTotalVolume ? totalVolume : (totalVolume ?? this.totalVolume),
    );
  }

  factory WorkoutSession.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw Exception("WorkoutSession data is null!");

    WorkoutStatus status;
    try {
      status = WorkoutStatus.values.byName(data['status'] as String? ?? 'inProgress');
    } catch (e) {
      status = WorkoutStatus.inProgress; // Default if parsing fails
    }

    return WorkoutSession(
      id: snapshot.id,
      userId: data['userId'] as String? ?? '',
      routineId: data['routineId'] as String?,
      routineNameSnapshot: data['routineNameSnapshot'] as String?,
      startedAt: data['startedAt'] as Timestamp? ?? Timestamp.now(),
      endedAt: data['endedAt'] as Timestamp?,
      durationSeconds: data['durationSeconds'] as int?,
      completedExercises: (data['completedExercises'] as List<dynamic>?)
              ?.map((e) => LoggedExercise.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: data['notes'] as String?,
      status: status,
      totalVolume: (data['totalVolume'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id' is document ID, not part of the map
      'userId': userId,
      if (routineId != null) 'routineId': routineId,
      if (routineNameSnapshot != null) 'routineNameSnapshot': routineNameSnapshot,
      'startedAt': startedAt, // Should be FieldValue.serverTimestamp() on create if not set
      if (endedAt != null) 'endedAt': endedAt,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      'completedExercises': completedExercises.map((e) => e.toMap()).toList(),
      if (notes != null) 'notes': notes,
      'status': status.name, // Store enum as string
      if (totalVolume != null) 'totalVolume': totalVolume,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        routineId,
        routineNameSnapshot,
        startedAt,
        endedAt,
        durationSeconds,
        completedExercises,
        notes,
        status,
        totalVolume,
      ];
}