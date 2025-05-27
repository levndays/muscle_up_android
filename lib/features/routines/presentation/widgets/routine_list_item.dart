// lib/features/routines/presentation/widgets/routine_list_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/repositories/routine_repository.dart'; // <--- ІМПОРТ ІНТЕРФЕЙСУ
import '../cubit/user_routines_cubit.dart';
// ManageRoutineCubit може не знадобитись тут, якщо UserRoutinesCubit обробляє видалення
// import '../cubit/manage_routine_cubit.dart'; 
import '../screens/create_edit_routine_screen.dart';
import 'dart:developer' as developer; // Для логування

class RoutineListItem extends StatelessWidget {
  final UserRoutine routine;

  const RoutineListItem({super.key, required this.routine});

  Future<void> _confirmDelete(BuildContext context) async {
    // Не використовуємо ManageRoutineCubit напряму тут, якщо UserRoutinesCubit має метод видалення.
    // final manageRoutineCubit = BlocProvider.of<ManageRoutineCubit>(context, listen: false);
    final userRoutinesCubit = BlocProvider.of<UserRoutinesCubit>(context, listen: false);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${routine.name}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
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
      // Ідеально: UserRoutinesCubit має метод для видалення
      // await userRoutinesCubit.deleteRoutine(routine.id);

      // Поточний варіант: видаляємо через репозиторій та оновлюємо список локально
      // Важливо: переконайся, що context ще валідний після await
      if (!context.mounted) return; 
      try {
        // Отримуємо репозиторій через RepositoryProvider
        final routineRepository = RepositoryProvider.of<RoutineRepository>(context);
        await routineRepository.deleteRoutine(routine.id);
        userRoutinesCubit.routineDeleted(routine.id); // Оновлюємо список локально

        if (context.mounted) { // Знову перевірка
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Routine "${routine.name}" deleted.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        developer.log('Error deleting routine: $e', name: 'RoutineListItem');
        if (context.mounted) { // Перевірка
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
        title: Text(routine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (routine.description != null && routine.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(routine.description!, style: Theme.of(context).textTheme.bodySmall),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${routine.exercises.length} exercise(s)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
            if (routine.scheduledDays.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Scheduled: ${routine.scheduledDays.join(", ")}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ),
          ],
        ),
        isThreeLine: (routine.description != null && routine.description!.isNotEmpty) || routine.scheduledDays.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CreateEditRoutineScreen(routineToEdit: routine),
              ));
            } else if (value == 'delete') {
              _confirmDelete(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'edit',
              child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(leading: Icon(Icons.delete, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red))),
            ),
          ],
        ),
        onTap: () {
          // TODO: Можливо, перехід на екран деталей рутини або початок тренування
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => CreateEditRoutineScreen(routineToEdit: routine),
          ));
        },
      ),
    );
  }
}