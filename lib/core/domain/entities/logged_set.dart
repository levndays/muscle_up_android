// lib/core/domain/entities/logged_set.dart
import 'package:equatable/equatable.dart';

class LoggedSet extends Equatable {
  final int setNumber; // Порядковий номер сету в рамках вправи
  final double? weightKg;
  final int? reps;
  final bool isCompleted;
  final String? notes; // Нотатки до конкретного сету
  // final int? restTimeSeconds; // Час відпочинку ПІСЛЯ цього сету (можна додати пізніше)

  const LoggedSet({
    required this.setNumber,
    this.weightKg,
    this.reps,
    this.isCompleted = false,
    this.notes,
  });

  // Метод для розрахунку об'єму цього сету
  double get volume {
    if (weightKg != null && reps != null && weightKg! > 0 && reps! > 0) {
      return weightKg! * reps!;
    }
    return 0.0;
  }

  LoggedSet copyWith({
    int? setNumber,
    double? weightKg,
    bool allowNullWeightKg = false,
    int? reps,
    bool allowNullReps = false,
    bool? isCompleted,
    String? notes,
    bool allowNullNotes = false,
  }) {
    return LoggedSet(
      setNumber: setNumber ?? this.setNumber,
      weightKg: allowNullWeightKg ? weightKg : (weightKg ?? this.weightKg),
      reps: allowNullReps ? reps : (reps ?? this.reps),
      isCompleted: isCompleted ?? this.isCompleted,
      notes: allowNullNotes ? notes : (notes ?? this.notes),
    );
  }

  factory LoggedSet.fromMap(Map<String, dynamic> map) {
    return LoggedSet(
      setNumber: map['setNumber'] as int? ?? 0,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      reps: map['reps'] as int?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      if (weightKg != null) 'weightKg': weightKg,
      if (reps != null) 'reps': reps,
      'isCompleted': isCompleted,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [setNumber, weightKg, reps, isCompleted, notes];
}