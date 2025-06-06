// lib/features/exercise_explorer/presentation/widgets/exercise_list_item.dart
import 'package:flutter/material.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';

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
    final secondaryMuscles = exercise.getLocalizedSecondaryMuscleGroups(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(exercise.getLocalizedName(context), style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.getLocalizedPrimaryMuscleGroup(context).toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            if (secondaryMuscles.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                secondaryMuscles.join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        isThreeLine: secondaryMuscles.isNotEmpty,
        trailing: isSelectionMode ? const Icon(Icons.add_circle_outline) : const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (isSelectionMode) {
            Navigator.pop(context, exercise);
          } else {
            // TODO: Навігація на детальний екран вправи
          }
        },
      ),
    );
  }
}