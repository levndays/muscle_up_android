// lib/features/routines/presentation/screens/user_routines_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import '../../../../core/domain/repositories/routine_repository.dart';
import '../../../../core/domain/entities/routine.dart'; // Додаємо, якщо RoutineListItem його потребує
import '../cubit/user_routines_cubit.dart';
import '../widgets/routine_list_item.dart';
import 'create_edit_routine_screen.dart';

class UserRoutinesScreen extends StatelessWidget {
  final bool isSelectionMode; // NEW: Parameter to enable selection mode

  const UserRoutinesScreen({super.key, this.isSelectionMode = false}); // Default to false

  static Route<UserRoutine?> route({bool isSelectionMode = false}) { // Update route method
    return MaterialPageRoute<UserRoutine?>(
      builder: (_) => UserRoutinesScreen(isSelectionMode: isSelectionMode),
    );
  }

  Future<void> _handleRoutineUpsertResult(UserRoutinesCubit cubit, bool? routineWasSavedOrUpdated) async {
    if (routineWasSavedOrUpdated == true) {
      developer.log("UserRoutinesScreen: Routine was saved/updated, fetching routines.", name: "UserRoutinesScreen.Handler");
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
        appBar: isSelectionMode // NEW: Conditional AppBar
            ? AppBar(
                title: const Text('Select a Routine'),
              )
            : null, // No AppBar if not in selection mode (HomePage handles it)
        body: BlocConsumer<UserRoutinesCubit, UserRoutinesState>(
          listener: (context, state) {
            if (state is UserRoutinesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final userRoutinesCubit = context.read<UserRoutinesCubit>();
            List<UserRoutine> routinesToDisplay = [];
            bool isLoading = false;

            if (state is UserRoutinesInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserRoutinesLoading) {
              routinesToDisplay = state.routines; // Використовуємо дані з UserRoutinesLoading
              isLoading = true; // Позначаємо, що йде завантаження
              // Якщо routinesToDisplay порожній і це перший раз (стан не був UserRoutinesLoaded),
              // то покажемо індикатор завантаження
              if (routinesToDisplay.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
            } else if (state is UserRoutinesLoaded) {
              routinesToDisplay = state.routines;
              isLoading = false;
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


            if (routinesToDisplay.isEmpty && !isLoading) {
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
                      if (!isSelectionMode) // Only show create button if not in selection mode
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Create Your First Routine'),
                          onPressed: () async {
                            final currentContext = context;
                            final result = await Navigator.of(currentContext).push<bool>(MaterialPageRoute(
                              builder: (_) => const CreateEditRoutineScreen(),
                            ));
                            if (!currentContext.mounted) return;
                            _handleRoutineUpsertResult(userRoutinesCubit, result);
                          },
                        )
                    ],
                  ),
                ),
              );
            }

            // Якщо є дані для відображення (або йде оновлення і є старі дані)
            return RefreshIndicator(
              onRefresh: () => userRoutinesCubit.fetchUserRoutines(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: routinesToDisplay.length + (isLoading && routinesToDisplay.isNotEmpty ? 1 : 0), // Додаємо місце для індикатора внизу, якщо є дані і йде завантаження
                itemBuilder: (context, index) {
                  if (isLoading && routinesToDisplay.isNotEmpty && index == routinesToDisplay.length) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                  }
                  final routine = routinesToDisplay[index];
                  return RoutineListItem(
                    routine: routine,
                    onRoutineUpdated: () => userRoutinesCubit.fetchUserRoutines(),
                    onRoutineDeleted: () => userRoutinesCubit.routineDeleted(routine.id),
                    isSelectionMode: isSelectionMode, // Pass selection mode
                  );
                },
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isSelectionMode ? null : Builder( // NEW: Hide FAB in selection mode
          builder: (fabContext) {
            return FloatingActionButton.extended(
              onPressed: () async {
                final userRoutinesCubit = fabContext.read<UserRoutinesCubit>();
                final currentFabContext = fabContext; 

                final result = await Navigator.of(currentFabContext).push<bool>(MaterialPageRoute(
                  builder: (_) => const CreateEditRoutineScreen(),
                ));
                if (!currentFabContext.mounted) return;
                _handleRoutineUpsertResult(userRoutinesCubit, result);
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('NEW ROUTINE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: 'Create a new routine',
            );
          }
        ),
      ),
    );
  }
}