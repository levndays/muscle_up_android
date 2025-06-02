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
  final Map<String, double> avgRpePerExercise30Days;   // Мапа: ID predefinedExercise -> Середнє RPE за останні 30 днів.
  final Map<String, double> avgWorkingWeights90Days; // Мапа: ID predefinedExercise -> Середня робоча вага за останні 90 днів.

  const ProgressLoaded({
    required this.userProfile,
    required this.currentLeague,
    required this.xpForCurrentLevelStart,
    required this.xpForNextLevelTotal,
    this.volumePerMuscleGroup7Days = const {},
    this.avgRpePerExercise30Days = const {},
    this.avgWorkingWeights90Days = const {},
  });

  @override
  List<Object?> get props => [
        userProfile,
        currentLeague,
        xpForCurrentLevelStart,
        xpForNextLevelTotal,
        volumePerMuscleGroup7Days,
        avgRpePerExercise30Days,
        avgWorkingWeights90Days,
      ];

  // Метод для створення копії стану з можливістю оновлення окремих полів.
  ProgressLoaded copyWith({
    UserProfile? userProfile,
    LeagueInfo? currentLeague,
    int? xpForCurrentLevelStart,
    int? xpForNextLevelTotal,
    Map<String, double>? volumePerMuscleGroup7Days,
    Map<String, double>? avgRpePerExercise30Days,
    Map<String, double>? avgWorkingWeights90Days,
  }) {
    return ProgressLoaded(
      userProfile: userProfile ?? this.userProfile,
      currentLeague: currentLeague ?? this.currentLeague,
      xpForCurrentLevelStart: xpForCurrentLevelStart ?? this.xpForCurrentLevelStart,
      xpForNextLevelTotal: xpForNextLevelTotal ?? this.xpForNextLevelTotal,
      volumePerMuscleGroup7Days: volumePerMuscleGroup7Days ?? this.volumePerMuscleGroup7Days,
      avgRpePerExercise30Days: avgRpePerExercise30Days ?? this.avgRpePerExercise30Days,
      avgWorkingWeights90Days: avgWorkingWeights90Days ?? this.avgWorkingWeights90Days,
    );
  }
}

// Стан, що вказує на помилку під час завантаження або обробки даних.
class ProgressError extends ProgressState {
  final String message; // Повідомлення про помилку.
  const ProgressError(this.message);
  @override
  List<Object?> get props => [message];
}

// Допоміжний клас для представлення точки даних на графіку (наприклад, для робочої ваги).
// Хоча `avgWorkingWeights90Days` тепер зберігає лише середнє значення,
// цей клас може бути корисним, якщо в майбутньому знадобиться відображати історію ваги.
class WorkoutDataPoint extends Equatable {
  final DateTime date; // Дата тренування.
  final double value;  // Значення (наприклад, вага або RPE).

  const WorkoutDataPoint(this.date, this.value);

  @override
  List<Object?> get props => [date, value];
}