// lib/features/progress/presentation/cubit/progress_state.dart
part of 'progress_cubit.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

class ProgressInitial extends ProgressState {}

class ProgressLoading extends ProgressState {
  final String? message;
  const ProgressLoading({this.message});
  @override
  List<Object?> get props => [message];
}

class ProgressLoaded extends ProgressState {
  final UserProfile userProfile;
  final LeagueInfo currentLeague;
  final int xpForCurrentLevelStart;
  final int xpForNextLevelTotal; // Загальна кількість XP для завершення поточного рівня (відносно початку рівня)
  final Map<String, double> volumePerMuscleGroup7Days; // SVG_ID -> Volume
  final Map<String, double> avgRpePerExercise30Days;   // PredefinedExerciseId -> Avg RPE
  final Map<String, List<WorkoutDataPoint>> workingWeights90Days; // PredefinedExerciseId -> List<DataPoint(date, weight)>

  const ProgressLoaded({
    required this.userProfile,
    required this.currentLeague,
    required this.xpForCurrentLevelStart,
    required this.xpForNextLevelTotal,
    this.volumePerMuscleGroup7Days = const {},
    this.avgRpePerExercise30Days = const {},
    this.workingWeights90Days = const {},
  });

  @override
  List<Object?> get props => [
        userProfile,
        currentLeague,
        xpForCurrentLevelStart,
        xpForNextLevelTotal,
        volumePerMuscleGroup7Days,
        avgRpePerExercise30Days,
        workingWeights90Days,
      ];

  ProgressLoaded copyWith({
    UserProfile? userProfile,
    LeagueInfo? currentLeague,
    int? xpForCurrentLevelStart,
    int? xpForNextLevelTotal,
    Map<String, double>? volumePerMuscleGroup7Days,
    Map<String, double>? avgRpePerExercise30Days,
    Map<String, List<WorkoutDataPoint>>? workingWeights90Days,
  }) {
    return ProgressLoaded(
      userProfile: userProfile ?? this.userProfile,
      currentLeague: currentLeague ?? this.currentLeague,
      xpForCurrentLevelStart: xpForCurrentLevelStart ?? this.xpForCurrentLevelStart,
      xpForNextLevelTotal: xpForNextLevelTotal ?? this.xpForNextLevelTotal,
      volumePerMuscleGroup7Days: volumePerMuscleGroup7Days ?? this.volumePerMuscleGroup7Days,
      avgRpePerExercise30Days: avgRpePerExercise30Days ?? this.avgRpePerExercise30Days,
      workingWeights90Days: workingWeights90Days ?? this.workingWeights90Days,
    );
  }
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  @override
  List<Object?> get props => [message];
}

// Допоміжний клас для графіка робочої ваги
class WorkoutDataPoint extends Equatable {
  final DateTime date;
  final double value; // Вага або RPE

  const WorkoutDataPoint(this.date, this.value);

  @override
  List<Object?> get props => [date, value];
}