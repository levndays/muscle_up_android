// lib/features/routines/presentation/screens/user_routines_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/repositories/routine_repository.dart';
import '../cubit/user_routines_cubit.dart';
import '../widgets/routine_list_item.dart'; // RoutineListItem тепер буде обробляти свій перехід
import 'create_edit_routine_screen.dart';

class UserRoutinesScreen extends StatelessWidget {
  const UserRoutinesScreen({super.key});

  // Метод для обробки результату з CreateEditRoutineScreen
  Future<void> _handleRoutineUpsertResult(BuildContext context, bool? routineWasSaved) async {
    if (routineWasSaved == true) {
      // Якщо рутина була збережена (нова або оновлена), оновлюємо список
      context.read<UserRoutinesCubit>().fetchUserRoutines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserRoutinesCubit>(
      create: (context) => UserRoutinesCubit(
        RepositoryProvider.of<RoutineRepository>(context),
        FirebaseAuth.instance,
      )..fetchUserRoutines(),
      child: Scaffold(
        body: BlocConsumer<UserRoutinesCubit, UserRoutinesState>(
          listener: (context, state) {
            if (state is UserRoutinesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is UserRoutinesInitial || state is UserRoutinesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserRoutinesLoaded) {
              if (state.routines.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.list_alt_outlined, size: 60, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
                        const SizedBox(height: 16),
                        const Text('You have no routines yet.', style: TextStyle(fontSize: 18, color: Colors.grey), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        const Text('Create a routine to start organizing your workouts!', style: TextStyle(fontSize: 15, color: Colors.grey), textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Create Your First Routine'),
                          onPressed: () async { // <--- ЗРОБИТИ ASYNC
                            final result = await Navigator.of(context).push<bool>(MaterialPageRoute( // <--- ЧЕКАЄМО РЕЗУЛЬТАТ bool
                              builder: (_) => const CreateEditRoutineScreen(),
                            ));
                            // ignore: use_build_context_synchronously
                            if (!context.mounted) return;
                            _handleRoutineUpsertResult(context, result); // <--- ОБРОБКА РЕЗУЛЬТАТУ
                          },
                        )
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 70),
                itemCount: state.routines.length,
                itemBuilder: (context, index) {
                  final routine = state.routines[index];
                  // Передаємо колбек для оновлення списку ПІСЛЯ редагування/видалення
                  return RoutineListItem(
                    routine: routine,
                    onRoutineUpdated: () => context.read<UserRoutinesCubit>().fetchUserRoutines(),
                    onRoutineDeleted: () => context.read<UserRoutinesCubit>().routineDeleted(routine.id), // Або fetchUserRoutines()
                  );
                },
              );
            } else if (state is UserRoutinesError) {
              return Center(
                 child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('Failed to load routines: ${state.message}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<UserRoutinesCubit>().fetchUserRoutines(),
                        child: const Text('Try Again'),
                      )
                    ],
                  ),
                )
              );
            }
            return const Center(child: Text('Press button to load routines or create one.'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async { // <--- ЗРОБИТИ ASYNC
            final result = await Navigator.of(context).push<bool>(MaterialPageRoute( // <--- ЧЕКАЄМО РЕЗУЛЬТАТ bool
              builder: (_) => const CreateEditRoutineScreen(),
            ));
             // ignore: use_build_context_synchronously
            if (!context.mounted) return;
            _handleRoutineUpsertResult(context, result); // <--- ОБРОБКА РЕЗУЛЬТАТУ
          },
          icon: const Icon(Icons.add),
          label: const Text('New Routine'),
          tooltip: 'Create a new routine',
        ),
      ),
    );
  }
}