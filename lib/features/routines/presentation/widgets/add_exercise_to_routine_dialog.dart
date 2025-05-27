// lib/features/routines/presentation/widgets/add_exercise_to_routine_dialog.dart
import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart'; // <--- ВИДАЛЕНО, якщо не використовується тут напряму
import '../../../../core/domain/entities/predefined_exercise.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../exercise_explorer/presentation/screens/exercise_explorer_screen.dart';


Future<RoutineExercise?> showAddExerciseToRoutineDialog(BuildContext context) async {
  final PredefinedExercise? selectedPredefinedExercise = await Navigator.of(context).push<PredefinedExercise>(
    MaterialPageRoute(
      builder: (_) => const ExerciseExplorerScreen(isSelectionMode: true), // <--- ВИПРАВЛЕНО
    ),
  );

  if (selectedPredefinedExercise == null) { // Перевірка mounted не потрібна перед pop
    return null;
  }

  // Подальший код залишається без змін, але переконайся, що `context` для `showDialog` є валідним.
  // Якщо `context` з попереднього екрану вже не валідний, це викличе помилку.
  // Але оскільки ми одразу викликаємо showDialog, він, ймовірно, буде валідним.
  // ignore: use_build_context_synchronously
  if (!context.mounted) return null; // Додаємо перевірку для безпеки

  return await showDialog<RoutineExercise>(
    context: context,
    builder: (dialogContext) {
      final setsController = TextEditingController(text: "3");
      final notesController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      return AlertDialog(
        title: Text('Add "${selectedPredefinedExercise.name}"'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: setsController,
                  decoration: const InputDecoration(labelText: 'Number of Sets'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Cannot be empty';
                    final n = int.tryParse(value);
                    if (n == null || n <= 0) return 'Must be a positive number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'E.g., focus on form, pyramid sets'
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(null),
          ),
          ElevatedButton(
            child: const Text('Add Exercise'),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(RoutineExercise(
                  predefinedExerciseId: selectedPredefinedExercise.id,
                  exerciseNameSnapshot: selectedPredefinedExercise.name,
                  numberOfSets: int.parse(setsController.text),
                  notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
                ));
              }
            },
          ),
        ],
      );
    },
  );
}