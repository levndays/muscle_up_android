// lib/features/routines/presentation/screens/user_routines_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/domain/repositories/routine_repository.dart';
import '../cubit/user_routines_cubit.dart';
import '../widgets/routine_list_item.dart';
import 'create_edit_routine_screen.dart';

class UserRoutinesScreen extends StatelessWidget {
  const UserRoutinesScreen({super.key});

  // Змінюємо метод: він тепер приймає сам Cubit, а не BuildContext
  Future<void> _handleRoutineUpsertResult(UserRoutinesCubit cubit, bool? routineWasSaved) async {
    if (routineWasSaved == true) {
      // Якщо рутина була збережена (нова або оновлена), оновлюємо список
      cubit.fetchUserRoutines();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserRoutinesCubit>(
      create: (cubitContext) => UserRoutinesCubit(
        RepositoryProvider.of<RoutineRepository>(cubitContext),
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
            // Отримуємо екземпляр Cubit тут, з правильного контексту
            final userRoutinesCubit = context.read<UserRoutinesCubit>();

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
                          onPressed: () async {
                            final currentContext = context; // Захоплюємо context для Navigator
                            final result = await Navigator.of(currentContext).push<bool>(MaterialPageRoute(
                              builder: (_) => const CreateEditRoutineScreen(),
                            ));
                            if (!currentContext.mounted) return;
                            // Використовуємо захоплений екземпляр Cubit
                            _handleRoutineUpsertResult(userRoutinesCubit, result);
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
                  return RoutineListItem(
                    routine: routine,
                    // Колбеки тепер використовують userRoutinesCubit, отриманий з builder
                    onRoutineUpdated: () => userRoutinesCubit.fetchUserRoutines(),
                    onRoutineDeleted: () => userRoutinesCubit.routineDeleted(routine.id),
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
                        onPressed: () => userRoutinesCubit.fetchUserRoutines(),
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
          onPressed: () async {
            // Так само отримуємо Cubit з контексту builder'а
            final userRoutinesCubit = context.read<UserRoutinesCubit>();
            final currentContext = context; // Захоплюємо context для Navigator

            final result = await Navigator.of(currentContext).push<bool>(MaterialPageRoute(
              builder: (_) => const CreateEditRoutineScreen(),
            ));
            if (!currentContext.mounted) return;
            _handleRoutineUpsertResult(userRoutinesCubit, result);
          },
          icon: const Icon(Icons.add),
          label: const Text('New Routine'),
          tooltip: 'Create a new routine',
        ),
      ),
    );
  }
}