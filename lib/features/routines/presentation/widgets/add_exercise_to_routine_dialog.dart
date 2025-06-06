// lib/features/routines/presentation/widgets/add_exercise_to_routine_dialog.dart
import 'package:flutter/material.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../exercise_explorer/presentation/screens/exercise_explorer_screen.dart';
// Import AppLocalizations if needed for dialog titles, though exercise name is now localized via entity
import 'package:muscle_up/l10n/app_localizations.dart';


Future<RoutineExercise?> showAddExerciseToRoutineDialog(BuildContext context) async {
  final loc = AppLocalizations.of(context)!;
  final PredefinedExercise? selectedPredefinedExercise = await Navigator.of(context).push<PredefinedExercise>(
    MaterialPageRoute(
      builder: (_) => const ExerciseExplorerScreen(isSelectionMode: true),
    ),
  );

  if (selectedPredefinedExercise == null) {
    return null;
  }

  if (!context.mounted) return null;

  return await showDialog<RoutineExercise>(
    context: context,
    builder: (dialogContext) {
      final setsController = TextEditingController(text: "3");
      final notesController = TextEditingController();
      final formKey = GlobalKey<FormState>();

      return AlertDialog(
        title: Text(loc.addExerciseDialogTitle(selectedPredefinedExercise.getLocalizedName(context))), // USE LOCALIZED NAME
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: setsController,
                  decoration: InputDecoration(labelText: loc.addExerciseDialogSetsLabel),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return loc.addExerciseDialogSetsErrorEmpty;
                    final n = int.tryParse(value);
                    if (n == null || n <= 0) return loc.addExerciseDialogSetsErrorInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: InputDecoration(
                    labelText: loc.addExerciseDialogNotesLabel,
                    hintText: loc.addExerciseDialogNotesHint
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(loc.addExerciseDialogButtonCancel),
            onPressed: () => Navigator.of(dialogContext).pop(null),
          ),
          ElevatedButton(
            child: Text(loc.addExerciseDialogButtonAdd),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(RoutineExercise(
                  predefinedExerciseId: selectedPredefinedExercise.id,
                  exerciseNameSnapshot: selectedPredefinedExercise.getLocalizedName(context), // Store localized name as snapshot
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