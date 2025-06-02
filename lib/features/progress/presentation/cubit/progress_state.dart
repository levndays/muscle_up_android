// lib/features/progress/presentation/cubit/progress_state.dart
part of 'progress_cubit.dart';

// Базовий абстрактний клас для всіх станів ProgressCubit.
// Використання Equatable дозволяє легко порівнювати об'єкти станів.
abstract class ProgressState extends Equatable {
  const ProgressState();

  @override
  List<Object?> get props => [];
}

// Початковий стан кубіта, коли дані ще не завантажувалися.
class ProgressInitial extends ProgressState {}

// Стан, що вказує на процес завантаження даних.
// Може містити опціональне повідомлення для відображення користувачеві.
class ProgressLoading extends ProgressState {
  final String? message;
  const ProgressLoading({this.message});
  @override
  List<Object?> get props => [message];
}

// Стан, що вказує на успішне завантаження всіх необхідних даних для екрану прогресу.
class ProgressLoaded extends ProgressState {
  final UserProfile userProfile; // Профіль поточного користувача.
  final LeagueInfo currentLeague; // Інформація про поточну лігу користувача.
  final int xpForCurrentLevelStart; // Кількість XP, необхідна для досягнення початку поточного рівня.
  final int xpForNextLevelTotal; // Загальна кількість XP для завершення поточного рівня (відносно початку рівня).
  final Map<String, double> volumePerMuscleGroup7Days; // Мапа: ID групи м'язів (з SVG) -> Об'єм тренувань (наприклад, кількість сетів) за останні 7 днів.
  
  final Map<String, double> avgRpePerExercise30Days;
  final Map<String, List<double>> rpePerWorkoutTrend;

  final Map<String, double> avgWorkingWeights90Days; 
  // Нове поле для тренду робочої ваги за останні N тренувань
  // Ключ - exerciseId, значення - список середніх робочих ваг для цієї вправи за кожне тренування (де вона була)
  final Map<String, List<double>> workingWeightPerWorkoutTrend;


  const ProgressLoaded({
    required this.userProfile,
    required this.currentLeague,
    required this.xpForCurrentLevelStart,
    required this.xpForNextLevelTotal,
    this.volumePerMuscleGroup7Days = const {},
    this.avgRpePerExercise30Days = const {},
    this.rpePerWorkoutTrend = const {},
    this.avgWorkingWeights90Days = const {},
    this.workingWeightPerWorkoutTrend = const {}, // Ініціалізація нового поля
  });

  @override
  List<Object?> get props => [
        userProfile,
        currentLeague,
        xpForCurrentLevelStart,
        xpForNextLevelTotal,
        volumePerMuscleGroup7Days,
        avgRpePerExercise30Days,
        rpePerWorkoutTrend,
        avgWorkingWeights90Days,
        workingWeightPerWorkoutTrend, // Додано в props
      ];

  ProgressLoaded copyWith({
    UserProfile? userProfile,
    LeagueInfo? currentLeague,
    int? xpForCurrentLevelStart,
    int? xpForNextLevelTotal,
    Map<String, double>? volumePerMuscleGroup7Days,
    Map<String, double>? avgRpePerExercise30Days,
    Map<String, List<double>>? rpePerWorkoutTrend,
    Map<String, double>? avgWorkingWeights90Days,
    Map<String, List<double>>? workingWeightPerWorkoutTrend, // Оновлено тип
  }) {
    return ProgressLoaded(
      userProfile: userProfile ?? this.userProfile,
      currentLeague: currentLeague ?? this.currentLeague,
      xpForCurrentLevelStart: xpForCurrentLevelStart ?? this.xpForCurrentLevelStart,
      xpForNextLevelTotal: xpForNextLevelTotal ?? this.xpForNextLevelTotal,
      volumePerMuscleGroup7Days: volumePerMuscleGroup7Days ?? this.volumePerMuscleGroup7Days,
      avgRpePerExercise30Days: avgRpePerExercise30Days ?? this.avgRpePerExercise30Days,
      rpePerWorkoutTrend: rpePerWorkoutTrend ?? this.rpePerWorkoutTrend,
      avgWorkingWeights90Days: avgWorkingWeights90Days ?? this.avgWorkingWeights90Days,
      workingWeightPerWorkoutTrend: workingWeightPerWorkoutTrend ?? this.workingWeightPerWorkoutTrend, // Оновлено
    );
  }
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  @override
  List<Object?> get props => [message];
}

class WorkoutDataPoint extends Equatable {
  final DateTime date;
  final double value;

  const WorkoutDataPoint(this.date, this.value);

  @override
  List<Object?> get props => [date, value];
}