// lib/features/exercise_explorer/presentation/widgets/exercise_list_item.dart
import 'package:flutter/material.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';

class ExerciseListItem extends StatelessWidget {
  final PredefinedExercise exercise;
  final bool isSelectionMode; // <--- ДОДАНО

  const ExerciseListItem({
    super.key, 
    required this.exercise,
    this.isSelectionMode = false, // <--- ДОДАНО
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(exercise.name),
        subtitle: Text(exercise.primaryMuscleGroup),
        trailing: isSelectionMode ? const Icon(Icons.add_circle_outline) : const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (isSelectionMode) {
            Navigator.pop(context, exercise); // Повертаємо обрану вправу
          } else {
            // TODO: Навігація на детальний екран вправи
            // Наприклад: Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)));
            // log('Tapped on ${exercise.name} for details'); // Використовуй логгер
          }
        },
      ),
    );
  }
}