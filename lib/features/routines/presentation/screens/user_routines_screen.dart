// lib/features/routines/presentation/screens/user_routines_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Потрібен для FirebaseAuth.instance
import '../../../../core/domain/repositories/routine_repository.dart'; // Абстракція
import '../cubit/user_routines_cubit.dart';
import '../widgets/routine_list_item.dart';
import 'create_edit_routine_screen.dart';

class UserRoutinesScreen extends StatelessWidget {
  const UserRoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Якщо UserRoutinesScreen не надає BlocProvider сам, а очікує його ззовні,
    // то тут BlocProvider не потрібен. Але якщо він його створює, то так:
    return BlocProvider<UserRoutinesCubit>( // Уточнено тип
      create: (context) => UserRoutinesCubit(
        RepositoryProvider.of<RoutineRepository>(context), // Отримуємо з контексту
        FirebaseAuth.instance,
      )..fetchUserRoutines(),
      child: Scaffold(
        // AppBar тут не потрібен, оскільки він є в HomePage
        body: BlocConsumer<UserRoutinesCubit, UserRoutinesState>(
          listener: (context, state) {
            if (state is UserRoutinesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is UserRoutinesInitial) {
              // Можна викликати fetchUserRoutines, якщо він не був викликаний при створенні кубіта
              // context.read<UserRoutinesCubit>().fetchUserRoutines();
              // Або просто показувати завантаження
              return const Center(child: CircularProgressIndicator());
            }
            if (state is UserRoutinesLoading) {
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
                        const Text(
                          'You have no routines yet.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create a routine to start organizing your workouts!',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Create Your First Routine'),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const CreateEditRoutineScreen(),
                            ));
                          },
                        )
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 70), // Відступ знизу для FAB
                itemCount: state.routines.length,
                itemBuilder: (context, index) {
                  final routine = state.routines[index];
                  return RoutineListItem(routine: routine);
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
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const CreateEditRoutineScreen(),
            ));
            // .then((_) { // Цей .then може бути непотрібним, якщо ManageRoutineCubit оновлює UserRoutinesCubit
            //   // final userRoutinesState = context.read<UserRoutinesCubit>().state;
            //   // if (userRoutinesState is UserRoutinesLoaded) { // Оновлюємо, якщо вже завантажено
            //   //   context.read<UserRoutinesCubit>().fetchUserRoutines();
            //   // }
            // });
          },
          icon: const Icon(Icons.add),
          label: const Text('New Routine'),
          tooltip: 'Create a new routine',
        ),
      ),
    );
  }
}