// lib/features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/exercise_explorer_cubit.dart';
// Тимчасово для простоти, краще через DI
// import '../../data/repositories/predefined_exercise_repository_impl.dart'; 
import '../../../../core/domain/repositories/predefined_exercise_repository.dart'; // Імпорт абстракції
import '../widgets/exercise_list_item.dart';

class ExerciseExplorerScreen extends StatelessWidget {
  final bool isSelectionMode;

  const ExerciseExplorerScreen({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    // Якщо ExerciseExplorerScreen не надає BlocProvider сам, а очікує його ззовні,
    // то тут BlocProvider не потрібен. Але якщо він його створює, то так:
    return BlocProvider<ExerciseExplorerCubit>( // Уточнено тип
      create: (context) => ExerciseExplorerCubit(
        RepositoryProvider.of<PredefinedExerciseRepository>(context), // Отримуємо з контексту
      )..fetchExercises(),
      child: Scaffold(
        appBar: isSelectionMode // Показуємо AppBar тільки якщо це не режим вибору, бо HomePage вже має AppBar
            ? AppBar(
                title: Text(isSelectionMode ? 'Select Exercise' : 'Exercise Library'),
                 // Кнопка назад буде автоматично, якщо це не корінь навігатора
              )
            : null, // Немає AppBar, якщо це вкладка в HomePage
        body: BlocBuilder<ExerciseExplorerCubit, ExerciseExplorerState>(
          builder: (context, state) {
            if (state is ExerciseExplorerInitial && !isSelectionMode) {
              // Можна викликати fetchExercises, якщо він не був викликаний при створенні кубіта
              // context.read<ExerciseExplorerCubit>().fetchExercises();
              // Або просто показувати завантаження
               return const Center(child: CircularProgressIndicator());
            }
            if (state is ExerciseExplorerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExerciseExplorerLoaded) {
              if (state.exercises.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No exercises found in the library yet. Content is being added!', textAlign: TextAlign.center),
                  )
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8), // Додамо відступи, якщо AppBar немає
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
                      Text('Error loading exercises: ${state.message}', textAlign: TextAlign.center),
                       const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ExerciseExplorerCubit>().fetchExercises(),
                        child: const Text('Try Again'),
                      )
                    ],
                  ),
                )
              );
            }
            return const Center(child: Text('Loading exercises...'));
          },
        ),
      ),
    );
  }
}