// lib/features/routines/presentation/widgets/routine_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muscle_up/l10n/app_localizations.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';
import '../screens/create_edit_routine_screen.dart';
import '../../../workout_tracking/presentation/screens/active_workout_screen.dart';
import 'dart:developer' as developer;

import '../../../social/presentation/screens/create_post_screen.dart';

class RoutineListItem extends StatelessWidget {
  final UserRoutine routine;
  final VoidCallback onRoutineUpdated;
  final VoidCallback onRoutineDeleted;
  final bool isSelectionMode;

  const RoutineListItem({
    super.key,
    required this.routine,
    required this.onRoutineUpdated,
    required this.onRoutineDeleted,
    this.isSelectionMode = false,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(loc.routineListItemDeleteConfirmTitle),
          content: Text(loc.routineListItemDeleteConfirmMessage(routine.name)),
          actions: <Widget>[
            TextButton(child: Text(loc.routineListItemDeleteConfirmButtonCancel), onPressed: () => Navigator.of(dialogContext).pop(false)),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(loc.routineListItemDeleteConfirmButtonDelete),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      try {
        final routineRepository = RepositoryProvider.of<RoutineRepository>(context);
        await routineRepository.deleteRoutine(routine.id);
        onRoutineDeleted();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.routineListItemSnackbarDeleted(routine.name)), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        developer.log('Error deleting routine: $e', name: 'RoutineListItem');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(loc.routineListItemSnackbarErrorDelete(e.toString())), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        title: Text(routine.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (routine.description != null && routine.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(routine.description!, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${routine.exercises.length}${loc.createPostRoutineExerciseCountSuffix}${routine.scheduledDays.isNotEmpty ? " | ${routine.scheduledDays.join(", ")}" : ""}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        isThreeLine: (routine.description != null && routine.description!.isNotEmpty) && routine.exercises.isNotEmpty,
        trailing: isSelectionMode
            ? const Icon(Icons.check_circle_outline)
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'start') {
                    Navigator.of(context).push(ActiveWorkoutScreen.route(routine: routine));
                  } else if (value == 'edit') {
                    final result = await Navigator.of(context).push<bool>(MaterialPageRoute(
                      builder: (_) => CreateEditRoutineScreen(routineToEdit: routine),
                    ));
                    if (result == true) {
                      onRoutineUpdated();
                    }
                  } else if (value == 'share') {
                     Navigator.of(context).push(CreatePostScreen.route(routineToShare: routine));
                  }
                  else if (value == 'delete') {
                    _confirmDelete(context);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'start', child: ListTile(leading: const Icon(Icons.play_circle_fill, color: Colors.green), title: Text(loc.routineListItemMenuStartWorkout))),
                  PopupMenuItem<String>(value: 'edit', child: ListTile(leading: const Icon(Icons.edit_note), title: Text(loc.routineListItemMenuEditRoutine))),
                  PopupMenuItem<String>(value: 'share', child: ListTile(leading: const Icon(Icons.share), title: Text(loc.routineListItemMenuShareRoutine))),
                  PopupMenuItem<String>(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent), title: Text(loc.routineListItemMenuDeleteRoutine, style: const TextStyle(color: Colors.redAccent)))),
                ],
              ),
        onTap: () {
          if (isSelectionMode) {
            Navigator.pop(context, routine);
          } else {
            Navigator.of(context).push(ActiveWorkoutScreen.route(routine: routine));
          }
        },
      ),
    );
  }
}