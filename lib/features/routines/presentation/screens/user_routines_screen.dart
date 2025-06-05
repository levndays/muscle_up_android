// lib/features/routines/presentation/screens/user_routines_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:muscle_up/l10n/app_localizations.dart';

import '../../../../core/domain/repositories/routine_repository.dart';
import '../../../../core/domain/entities/routine.dart';
import '../cubit/user_routines_cubit.dart';
import '../widgets/routine_list_item.dart';
import 'create_edit_routine_screen.dart';

class UserRoutinesScreen extends StatelessWidget {
  final bool isSelectionMode;

  const UserRoutinesScreen({super.key, this.isSelectionMode = false});

  static Route<UserRoutine?> route({bool isSelectionMode = false}) {
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
    final loc = AppLocalizations.of(context)!;
    return BlocProvider<UserRoutinesCubit>(
      create: (cubitContext) => UserRoutinesCubit(
        RepositoryProvider.of<RoutineRepository>(cubitContext),
        FirebaseAuth.instance,
      )..fetchUserRoutines(),
      child: Scaffold(
        appBar: isSelectionMode
            ? AppBar(
                title: Text(loc.userRoutinesScreenTitle),
              )
            : null, 
        body: BlocConsumer<UserRoutinesCubit, UserRoutinesState>(
          listener: (context, state) {
            if (state is UserRoutinesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.userRoutinesErrorLoad(state.message)), backgroundColor: Colors.red),
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
              routinesToDisplay = state.routines; 
              isLoading = true; 
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
                      Text(loc.userRoutinesErrorLoad(state.message), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => userRoutinesCubit.fetchUserRoutines(),
                        child: Text(loc.exerciseExplorerButtonTryAgain), 
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
                      Text(loc.userRoutinesEmptyTitle, style: const TextStyle(fontSize: 18, color: Colors.grey), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(loc.userRoutinesEmptySubtitle, style: const TextStyle(fontSize: 15, color: Colors.grey), textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      if (!isSelectionMode) 
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: Text(loc.userRoutinesButtonCreateFirst),
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

            return RefreshIndicator(
              onRefresh: () => userRoutinesCubit.fetchUserRoutines(),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: routinesToDisplay.length + (isLoading && routinesToDisplay.isNotEmpty ? 1 : 0), 
                itemBuilder: (context, index) {
                  if (isLoading && routinesToDisplay.isNotEmpty && index == routinesToDisplay.length) {
                    return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
                  }
                  final routine = routinesToDisplay[index];
                  return RoutineListItem(
                    routine: routine,
                    onRoutineUpdated: () => userRoutinesCubit.fetchUserRoutines(),
                    onRoutineDeleted: () => userRoutinesCubit.routineDeleted(routine.id),
                    isSelectionMode: isSelectionMode, 
                  );
                },
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isSelectionMode ? null : Builder( 
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
              label: Text(loc.userRoutinesFabNewRoutine, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: loc.createEditRoutineScreenTitleCreate,
            );
          }
        ),
      ),
    );
  }
}