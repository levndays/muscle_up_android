// lib/features/workout_tracking/presentation/screens/active_workout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;

import '../../../../core/domain/entities/routine.dart';
import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../cubit/active_workout_cubit.dart';
import '../widgets/current_set_display.dart';
import './workout_complete_screen.dart';
import '../../../../utils/duration_formatter.dart';
import '../../../../auth_gate.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  final UserRoutine? routineForNewWorkout;

  const ActiveWorkoutScreen({super.key, this.routineForNewWorkout});

  static Route<void> route({UserRoutine? routine}) {
    return MaterialPageRoute<void>(
      builder: (_) => ActiveWorkoutScreen(routineForNewWorkout: routine),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ActiveWorkoutCubit(
          RepositoryProvider.of<WorkoutLogRepository>(context),
          RepositoryProvider.of<UserProfileRepository>(context),
          RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
        );
        if (routineForNewWorkout != null) {
          cubit.startNewWorkout(fromRoutine: routineForNewWorkout);
        }
        // Якщо routineForNewWorkout == null, кубіт сам перевірить активну сесію в _subscribeToActiveSession
        return cubit;
      },
      child: _ActiveWorkoutView(),
    );
  }
}

class _ActiveWorkoutView extends StatefulWidget {
  @override
  State<_ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends State<_ActiveWorkoutView> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;

  void _requestSetNavigation({required bool next}) {
    final cubit = context.read<ActiveWorkoutCubit>();
    final state = cubit.state;

    if (state is ActiveWorkoutInProgress) {
      final session = state.session;
      if (session.completedExercises.isEmpty) return;

      int validExerciseIndex = _currentExerciseIndex;
      if (validExerciseIndex >= session.completedExercises.length) {
        validExerciseIndex = session.completedExercises.isNotEmpty ? session.completedExercises.length - 1 : 0;
      }
      if (validExerciseIndex < 0) validExerciseIndex = 0;

      int newSetIndex = _currentSetIndex + (next ? 1 : -1);
      int newExerciseIndex = validExerciseIndex;

      // Перевірка, чи є сети у поточній вправі
      if (session.completedExercises[newExerciseIndex].completedSets.isEmpty) {
          developer.log("Warning: Exercise ${session.completedExercises[newExerciseIndex].exerciseNameSnapshot} has no sets. Cannot navigate within it.", name: "_ActiveWorkoutViewState");
          // Якщо йдемо вперед і це остання вправа, або наступні теж порожні, показуємо діалог завершення
          if (next) {
             _requestSetNavigationForNextExercise(newExerciseIndex + 1, session); // Спробувати перейти до наступної вправи
          } else if (!next && newExerciseIndex > 0) {
             _requestSetNavigationForPreviousExercise(newExerciseIndex -1, session); // Спробувати перейти до попередньої вправи
          }
          return;
      }


      if (newSetIndex >= 0 && newSetIndex < session.completedExercises[newExerciseIndex].completedSets.length) {
        setState(() {
          _currentSetIndex = newSetIndex;
          _currentExerciseIndex = newExerciseIndex;
        });
      } else if (next && newSetIndex >= session.completedExercises[newExerciseIndex].completedSets.length) {
        // Перехід до наступної вправи
        _requestSetNavigationForNextExercise(newExerciseIndex + 1, session);
      } else if (!next && newSetIndex < 0) {
        // Перехід до попередньої вправи
        _requestSetNavigationForPreviousExercise(newExerciseIndex - 1, session);
      }
    }
  }

  void _requestSetNavigationForNextExercise(int targetExerciseIndex, WorkoutSession session) {
     final cubit = context.read<ActiveWorkoutCubit>();
     if (targetExerciseIndex < session.completedExercises.length) {
        if (session.completedExercises[targetExerciseIndex].completedSets.isNotEmpty) {
            setState(() {
                _currentExerciseIndex = targetExerciseIndex;
                _currentSetIndex = 0;
            });
        } else {
            // Рекурсивний виклик для пропуску порожніх вправ
            _requestSetNavigationForNextExercise(targetExerciseIndex + 1, session);
        }
    } else {
        // Досягли кінця всіх вправ
        _showCompleteWorkoutDialog(cubit);
    }
  }

 void _requestSetNavigationForPreviousExercise(int targetExerciseIndex, WorkoutSession session) {
    if (targetExerciseIndex >= 0) {
        if (session.completedExercises[targetExerciseIndex].completedSets.isNotEmpty) {
            setState(() {
                _currentExerciseIndex = targetExerciseIndex;
                _currentSetIndex = session.completedExercises[targetExerciseIndex].completedSets.length - 1;
            });
        } else {
            // Рекурсивний виклик для пропуску порожніх вправ
            _requestSetNavigationForPreviousExercise(targetExerciseIndex - 1, session);
        }
    }
    // Якщо targetExerciseIndex < 0, ми на початку, нічого не робимо
 }


  void _showCancelWorkoutDialog(ActiveWorkoutCubit cubit) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Workout?'),
        content: const Text('Are you sure you want to cancel this workout? Progress will not be saved.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('No')),
          TextButton(
            onPressed: () { Navigator.of(dialogCtx).pop(); cubit.cancelWorkout(); },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCompleteWorkoutDialog(ActiveWorkoutCubit cubit) {
     showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Complete Workout?'),
        content: const Text('Are you sure you want to finish and save this workout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('No, Continue')),
          ElevatedButton(
            onPressed: () { Navigator.of(dialogCtx).pop(); cubit.completeWorkout(); },
            child: const Text('Yes, Complete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveWorkoutCubit, ActiveWorkoutState>(
      listener: (context, state) {
        if (state is ActiveWorkoutSuccessfullyCompleted) {
          Navigator.of(context).pushReplacement(
            WorkoutCompleteScreen.route(state.completedSession, state.xpGained, state.updatedUserProfile),
          );
        } else if (state is ActiveWorkoutCancelled) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.orange));
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (ctx) => const AuthGate()), (route) => false);
        } else if (state is ActiveWorkoutError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        } else if (state is ActiveWorkoutInProgress) {
          final session = state.session;
          bool indicesChanged = false;
          if (session.completedExercises.isEmpty) {
             _currentExerciseIndex = 0; _currentSetIndex = 0; indicesChanged = true;
          } else {
            if (_currentExerciseIndex >= session.completedExercises.length) {
              _currentExerciseIndex = session.completedExercises.isNotEmpty ? session.completedExercises.length - 1 : 0;
              _currentSetIndex = 0;
              indicesChanged = true;
            }
             // Перевірка, чи є сети у поточній (або новообраній) вправі
            if (session.completedExercises[_currentExerciseIndex].completedSets.isEmpty) {
                developer.log("Warning in Listener: Current exercise ${session.completedExercises[_currentExerciseIndex].exerciseNameSnapshot} has no sets.", name: "_ActiveWorkoutViewStateListener");
                // Спроба знайти першу валідну вправу з сетами
                int firstValidExerciseIdx = session.completedExercises.indexWhere((ex) => ex.completedSets.isNotEmpty);
                if (firstValidExerciseIdx != -1) {
                    _currentExerciseIndex = firstValidExerciseIdx;
                    _currentSetIndex = 0;
                } else { // Якщо взагалі немає вправ з сетами
                    _currentExerciseIndex = 0;
                    _currentSetIndex = 0;
                }
                indicesChanged = true;
            } else if (_currentSetIndex >= session.completedExercises[_currentExerciseIndex].completedSets.length) {
              // Якщо індекс сету виходить за межі, встановлюємо на останній валідний або 0
              _currentSetIndex = session.completedExercises[_currentExerciseIndex].completedSets.isNotEmpty
                  ? session.completedExercises[_currentExerciseIndex].completedSets.length - 1
                  : 0;
              indicesChanged = true;
            }
          }
          if(indicesChanged && mounted) { setState(() {}); }
        }
      },
      builder: (context, state) {
        final cubit = context.read<ActiveWorkoutCubit>();

        if (state is ActiveWorkoutInitial || (state is ActiveWorkoutLoading && state.message?.contains('Starting new') == false)) {
          return Scaffold(
            appBar: AppBar(title: Text(state is ActiveWorkoutLoading ? (state.message ?? 'Loading...') : 'Loading Workout...')),
            body: const Center(child: CircularProgressIndicator())
          );
        }
        if (state is ActiveWorkoutLoading && state.message?.contains('Starting new') == true) {
             return Scaffold(
                appBar: AppBar(title: Text(state.message!)),
                body: const Center(child: CircularProgressIndicator())
            );
        }
        if (state is ActiveWorkoutNone) {
          return Scaffold(
            appBar: AppBar(title: const Text('Start Workout'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop())),
            body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ const Text('No active workout found.'), const SizedBox(height: 20), ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back to Routines'))]))
          );
        }

        if (state is ActiveWorkoutInProgress) {
          final session = state.session;
          
          // Захист від порожніх вправ (хоча це вже обробляється в _requestSetNavigation...)
          if (session.completedExercises.isEmpty) {
            return Scaffold(
                appBar: AppBar(title: Text(session.routineNameSnapshot ?? 'Empty Workout'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _showCancelWorkoutDialog(cubit))),
                body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ const Text('This workout has no exercises.'), const SizedBox(height: 20), ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add exercise: TBD'))); }, child: const Text('Add First Exercise')), const SizedBox(height: 10), ElevatedButton(onPressed: () => _showCompleteWorkoutDialog(cubit), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer), child: const Text('Finish Empty Workout'))]))
            );
          }
          
          // Гарантуємо, що індекси валідні
          final safeExerciseIndex = (_currentExerciseIndex < session.completedExercises.length) ? _currentExerciseIndex : 0;
           if (session.completedExercises[safeExerciseIndex].completedSets.isEmpty) {
            // Цей блок не мав би досягатися, якщо логіка в listener та _requestSetNavigation працює правильно
            // Але для безпеки, якщо ми сюди потрапили, покажемо помилку
            return Scaffold(
                appBar: AppBar(title: Text(session.routineNameSnapshot ?? 'Workout Error'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _showCancelWorkoutDialog(cubit))),
                body: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Error: Exercise '${session.completedExercises[safeExerciseIndex].exerciseNameSnapshot}' has no sets."),
                    const SizedBox(height: 10),
                    Text("Please edit the routine or contact support.", textAlign: TextAlign.center,),
                     const SizedBox(height: 20),
                    ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Go Back'))
                  ],
                ))
            );
          }
          final safeSetIndex = (_currentSetIndex < session.completedExercises[safeExerciseIndex].completedSets.length) ? _currentSetIndex : 0;
          
          final currentLoggedExercise = session.completedExercises[safeExerciseIndex];
          final currentLoggedSet = currentLoggedExercise.completedSets[safeSetIndex];

          return Scaffold(
            resizeToAvoidBottomInset: true, // За замовчуванням true, але для певності
            appBar: AppBar(
              title: Text(session.routineNameSnapshot ?? 'Active Workout', style: const TextStyle(fontSize: 18)),
              centerTitle: true, elevation: 1,
              actions: [Padding(padding: const EdgeInsets.only(right: 16.0), child: Center(child: Text(formatDuration(state.currentDuration), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))))],
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _showCancelWorkoutDialog(cubit)),
            ),
            // Обгортаємо Column в SingleChildScrollView
            body: SingleChildScrollView(
              child: ConstrainedBox( // Дозволяє Column зайняти всю доступну висоту, якщо вміст менший
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - (AppBar().preferredSize.height) - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Притискає кнопки до низу
                  children: [
                    // CurrentSetDisplay тепер не Expanded, а просто частина Column
                    CurrentSetDisplay(
                      currentExercise: currentLoggedExercise,
                      currentSet: currentLoggedSet,
                      exerciseIndex: safeExerciseIndex,
                      setIndex: safeSetIndex,
                      totalSetsInExercise: currentLoggedExercise.targetSets > 0 ? currentLoggedExercise.targetSets : currentLoggedExercise.completedSets.length,
                      onRequestSetNavigation: _requestSetNavigation,
                      onCompleteWorkoutRequested: () => _showCompleteWorkoutDialog(cubit),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // Запасний варіант
        return Scaffold(appBar: AppBar(title: const Text('Workout')), body: const Center(child: Text('An unexpected state occurred. Please restart.')));
      },
    );
  }
}