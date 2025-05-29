// lib/core/domain/entities/logged_exercise.dart
import 'package:equatable/equatable.dart';
import 'logged_set.dart';

class LoggedExercise extends Equatable {
  final String predefinedExerciseId; // ID з бібліотеки вправ
  final String exerciseNameSnapshot; // Назва вправи на момент логування
  final int targetSets; // Цільова кількість сетів (з рутини)
  final List<LoggedSet> completedSets; // Список виконаних/запланованих сетів
  final String? notes; // Нотатки до цієї вправи в рамках сесії

  const LoggedExercise({
    required this.predefinedExerciseId,
    required this.exerciseNameSnapshot,
    required this.targetSets,
    this.completedSets = const [],
    this.notes,
  });

  // Розрахунок загального об'єму для цієї вправи
  double get totalVolume {
    return completedSets.fold(0.0, (sum, set) => sum + set.volume);
  }

  LoggedExercise copyWith({
    String? predefinedExerciseId,
    String? exerciseNameSnapshot,
    int? targetSets,
    List<LoggedSet>? completedSets,
    String? notes,
    bool allowNullNotes = false,
  }) {
    return LoggedExercise(
      predefinedExerciseId: predefinedExerciseId ?? this.predefinedExerciseId,
      exerciseNameSnapshot: exerciseNameSnapshot ?? this.exerciseNameSnapshot,
      targetSets: targetSets ?? this.targetSets,
      completedSets: completedSets ?? this.completedSets,
      notes: allowNullNotes ? notes : (notes ?? this.notes),
    );
  }

  factory LoggedExercise.fromMap(Map<String, dynamic> map) {
    return LoggedExercise(
      predefinedExerciseId: map['predefinedExerciseId'] as String? ?? '',
      exerciseNameSnapshot: map['exerciseNameSnapshot'] as String? ?? '',
      targetSets: map['targetSets'] as int? ?? 0,
      completedSets: (map['completedSets'] as List<dynamic>?)
              ?.map((e) => LoggedSet.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'predefinedExerciseId': predefinedExerciseId,
      'exerciseNameSnapshot': exerciseNameSnapshot,
      'targetSets': targetSets,
      'completedSets': completedSets.map((set) => set.toMap()).toList(),
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [
        predefinedExerciseId,
        exerciseNameSnapshot,
        targetSets,
        completedSets,
        notes,
      ];
}