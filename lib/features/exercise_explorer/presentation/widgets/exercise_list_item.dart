// lib/features/exercise_explorer/presentation/widgets/exercise_list_item.dart
import 'package:flutter/material.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';
// No need to import AppLocalizations if using getLocalizedName(context) from entity

class ExerciseListItem extends StatelessWidget {
  final PredefinedExercise exercise;
  final bool isSelectionMode;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(exercise.getLocalizedName(context)), // USE LOCALIZED
        subtitle: Text(exercise.getLocalizedPrimaryMuscleGroup(context)), // USE LOCALIZED
        trailing: isSelectionMode ? const Icon(Icons.add_circle_outline) : const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (isSelectionMode) {
            Navigator.pop(context, exercise);
          } else {
            // TODO: Навігація на детальний екран вправи
            // Наприклад: Navigator.push(context, MaterialPageRoute(builder: (_) => ExerciseDetailScreen(exercise: exercise)));
            // developer.log('Tapped on ${exercise.getLocalizedName(context)} for details');
          }
        },
      ),
    );
  }
}