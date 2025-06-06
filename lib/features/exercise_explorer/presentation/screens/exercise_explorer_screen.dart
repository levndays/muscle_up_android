// lib/features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muscle_up/l10n/app_localizations.dart';
import '../cubit/exercise_explorer_cubit.dart';
import '../../../../core/domain/repositories/predefined_exercise_repository.dart';
import '../widgets/exercise_list_item.dart';

class ExerciseExplorerScreen extends StatelessWidget {
  final bool isSelectionMode;

  const ExerciseExplorerScreen({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return BlocProvider<ExerciseExplorerCubit>(
      create: (context) => ExerciseExplorerCubit(
        RepositoryProvider.of<PredefinedExerciseRepository>(context),
      )..fetchExercises(),
      child: Scaffold(
        appBar: isSelectionMode
            ? AppBar(
                title: Text(isSelectionMode ? loc.exerciseExplorerScreenTitleSelect : loc.exerciseExplorerScreenTitleLibrary),
              )
            : null,
        body: BlocBuilder<ExerciseExplorerCubit, ExerciseExplorerState>(
          builder: (context, state) {
            if (state is ExerciseExplorerInitial && !isSelectionMode) {
               return const Center(child: CircularProgressIndicator());
            }
            if (state is ExerciseExplorerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExerciseExplorerLoaded) {
              if (state.exercises.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(loc.exerciseExplorerEmpty, textAlign: TextAlign.center),
                  )
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: state.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = state.exercises[index];
                  return ExerciseListItem(
                    exercise: exercise,
                    isSelectionMode: isSelectionMode,
                  );
                },
              );
            } else if (state is ExerciseExplorerError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(loc.exerciseExplorerErrorLoad(state.message), textAlign: TextAlign.center),
                       const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ExerciseExplorerCubit>().fetchExercises(),
                        child: Text(loc.exerciseExplorerButtonTryAgain),
                      )
                    ],
                  ),
                )
              );
            }
            return Center(child: Text(loc.exerciseExplorerLoading));
          },
        ),
      ),
    );
  }
}