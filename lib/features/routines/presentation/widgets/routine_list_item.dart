// lib/features/routines/presentation/widgets/routine_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Потрібен для RepositoryProvider
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart';
// import '../cubit/user_routines_cubit.dart'; // Не потрібен для прямого виклику, якщо використовуємо колбеки
import '../screens/create_edit_routine_screen.dart';
import '../../../workout_tracking/presentation/screens/active_workout_screen.dart';
import 'dart:developer' as developer;

// NEW IMPORT FOR SOCIAL
import '../../../social/presentation/screens/create_post_screen.dart';

class RoutineListItem extends StatelessWidget {
  final UserRoutine routine;
  final VoidCallback onRoutineUpdated; // Колбек для оновлення списку після редагування
  final VoidCallback onRoutineDeleted; // Колбек для оновлення списку після видалення
  final bool isSelectionMode; // NEW: Parameter to enable selection mode

  const RoutineListItem({
    super.key,
    required this.routine,
    required this.onRoutineUpdated,
    required this.onRoutineDeleted,
    this.isSelectionMode = false, // Default to false
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${routine.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(dialogContext).pop(false)),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
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
        onRoutineDeleted(); // Викликаємо колбек

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Routine "${routine.name}" deleted.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        developer.log('Error deleting routine: $e', name: 'RoutineListItem');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting routine: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                '${routine.exercises.length} exercise(s)${routine.scheduledDays.isNotEmpty ? " | ${routine.scheduledDays.join(", ")}" : ""}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        isThreeLine: (routine.description != null && routine.description!.isNotEmpty) && routine.exercises.isNotEmpty,
        trailing: isSelectionMode // NEW: Conditional trailing widget
            ? const Icon(Icons.check_circle_outline) // Or another selection icon
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
                  const PopupMenuItem<String>(value: 'start', child: ListTile(leading: Icon(Icons.play_circle_fill, color: Colors.green), title: Text('Start Workout'))),
                  const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit_note), title: Text('Edit Routine'))),
                  const PopupMenuItem<String>(value: 'share', child: ListTile(leading: Icon(Icons.share), title: Text('Share Routine'))),
                  const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete_sweep_outlined, color: Colors.redAccent), title: Text('Delete Routine', style: TextStyle(color: Colors.redAccent)))),
                ],
              ),
        onTap: () {
          if (isSelectionMode) { // NEW: Handle tap for selection mode
            Navigator.pop(context, routine); // Return the selected routine
          } else {
            Navigator.of(context).push(ActiveWorkoutScreen.route(routine: routine));
          }
        },
      ),
    );
  }
}