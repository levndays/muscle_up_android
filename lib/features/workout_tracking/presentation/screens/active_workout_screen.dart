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
import '../../../../auth_gate.dart'; // Для навігації після завершення

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
        validExerciseIndex = session.completedExercises.length - 1;
      }
      if (validExerciseIndex < 0) validExerciseIndex = 0;
      
      int newSetIndex = _currentSetIndex + (next ? 1 : -1);
      int newExerciseIndex = validExerciseIndex;

      if (newSetIndex >= 0 && newSetIndex < session.completedExercises[newExerciseIndex].completedSets.length) {
        setState(() {
          _currentSetIndex = newSetIndex;
          _currentExerciseIndex = newExerciseIndex;
        });
      } else if (next && newSetIndex >= session.completedExercises[newExerciseIndex].completedSets.length) {
        newExerciseIndex++;
        if (newExerciseIndex < session.completedExercises.length) {
          setState(() {
            _currentExerciseIndex = newExerciseIndex;
            _currentSetIndex = 0;
          });
        } else {
          // Досягли кінця всіх вправ, тепер показуємо діалог з CurrentSetDisplay (через колбек)
           _showCompleteWorkoutDialog(cubit); // Передаємо cubit
        }
      } else if (!next && newSetIndex < 0) {
        newExerciseIndex--;
        if (newExerciseIndex >= 0) {
          setState(() {
            _currentExerciseIndex = newExerciseIndex;
            _currentSetIndex = session.completedExercises[newExerciseIndex].completedSets.length - 1;
          });
        }
      }
    }
  }

  void _showCancelWorkoutDialog(ActiveWorkoutCubit cubit) { // Приймає cubit
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

  void _showCompleteWorkoutDialog(ActiveWorkoutCubit cubit) { // Приймає cubit
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
            WorkoutCompleteScreen.route(state.completedSession, state.xpGained),
          );
        } else if (state is ActiveWorkoutCancelled) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.orange),
          );
          // Повертаємося на AuthGate, щоб коректно відновити стан HomePage з UserProfileCubit
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const AuthGate()), 
            (route) => false
          );
        } else if (state is ActiveWorkoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is ActiveWorkoutInProgress) {
          final session = state.session;
          bool indicesChanged = false;
          if (_currentExerciseIndex >= session.completedExercises.length) {
            _currentExerciseIndex = session.completedExercises.isNotEmpty ? 0 : 0;
            _currentSetIndex = 0;
            indicesChanged = true;
          }
          if (session.completedExercises.isNotEmpty && _currentExerciseIndex < session.completedExercises.length) {
            if (session.completedExercises[_currentExerciseIndex].completedSets.isEmpty && _currentExerciseIndex > 0) {
                // Якщо поточна вправа не має сетів (дивна ситуація), спробуємо перейти до попередньої
                _currentExerciseIndex--;
                _currentSetIndex = session.completedExercises[_currentExerciseIndex].completedSets.isNotEmpty 
                                   ? session.completedExercises[_currentExerciseIndex].completedSets.length -1 
                                   : 0;
                indicesChanged = true;
            } else if (_currentSetIndex >= session.completedExercises[_currentExerciseIndex].completedSets.length) {
              _currentSetIndex = session.completedExercises[_currentExerciseIndex].completedSets.isNotEmpty ? 0 : 0;
              indicesChanged = true;
            }
          } else if (session.completedExercises.isEmpty) {
            _currentExerciseIndex = 0; _currentSetIndex = 0; indicesChanged = true;
          }
          if(indicesChanged && mounted) { setState(() {}); }
        }
      },
      builder: (context, state) {
        final cubit = context.read<ActiveWorkoutCubit>();

        if (state is ActiveWorkoutInitial || (state is ActiveWorkoutLoading && state.message != null)) {
          return Scaffold(appBar: AppBar(title: Text(state is ActiveWorkoutLoading ? state.message! : 'Loading Workout...')), body: const Center(child: CircularProgressIndicator()));
        }
        if (state is ActiveWorkoutNone) {
          return Scaffold(appBar: AppBar(title: const Text('Start Workout')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ const Text('No active workout found or could not start one.'), const SizedBox(height: 20), ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Choose a Routine'))])));
        }

        if (state is ActiveWorkoutInProgress) {
          final session = state.session;
          if (session.completedExercises.isEmpty) {
            return Scaffold(appBar: AppBar(title: Text(session.routineNameSnapshot ?? 'Empty Workout')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ const Text('This workout has no exercises yet.'), const SizedBox(height: 20), ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add exercise: TBD'))); }, child: const Text('Add First Exercise')), const SizedBox(height: 10), ElevatedButton(onPressed: () => _showCompleteWorkoutDialog(cubit), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.errorContainer), child: const Text('Finish Empty Workout'))])));
          }
          
          final safeExerciseIndex = (_currentExerciseIndex < session.completedExercises.length) ? _currentExerciseIndex : 0;
          if (session.completedExercises[safeExerciseIndex].completedSets.isEmpty) {
            developer.log("Error: Exercise ${session.completedExercises[safeExerciseIndex].exerciseNameSnapshot} has no sets after index correction.", name: "_ActiveWorkoutViewState");
            return Scaffold(appBar: AppBar(title: Text(session.routineNameSnapshot ?? 'Workout Error')), body: Center(child: Text("Error: Exercise '${session.completedExercises[safeExerciseIndex].exerciseNameSnapshot}' has no sets.")));
          }
          final safeSetIndex = (_currentSetIndex < session.completedExercises[safeExerciseIndex].completedSets.length) ? _currentSetIndex : 0;
          final currentLoggedExercise = session.completedExercises[safeExerciseIndex];
          final currentLoggedSet = currentLoggedExercise.completedSets[safeSetIndex];

          return Scaffold(
            appBar: AppBar(
              title: Text(session.routineNameSnapshot ?? 'Active Workout', style: const TextStyle(fontSize: 18)),
              centerTitle: true, elevation: 1,
              actions: [Padding(padding: const EdgeInsets.only(right: 16.0), child: Center(child: Text(formatDuration(state.currentDuration), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))))],
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => _showCancelWorkoutDialog(cubit)), // Передаємо cubit
            ),
            body: Column(
              children: [
                CurrentSetDisplay(
                  currentExercise: currentLoggedExercise,
                  currentSet: currentLoggedSet,
                  exerciseIndex: safeExerciseIndex,
                  setIndex: safeSetIndex,
                  totalSetsInExercise: currentLoggedExercise.targetSets > 0 ? currentLoggedExercise.targetSets : currentLoggedExercise.completedSets.length,
                  onRequestSetNavigation: _requestSetNavigation,
                  onCompleteWorkoutRequested: () => _showCompleteWorkoutDialog(cubit), // <--- ПЕРЕДАЄМО КОЛБЕК
                ),
              ],
            ),
          );
        }
        return Scaffold(appBar: AppBar(title: const Text('Workout')), body: const Center(child: Text('An unexpected state occurred. Please restart.')));
      },
    );
  }
}