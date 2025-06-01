// lib/features/progress/presentation/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Для FirebaseAuth
import 'dart:developer' as developer;

import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../../../../core/domain/repositories/league_repository.dart';
import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/predefined_exercise_repository.dart';
import '../cubit/progress_cubit.dart';
import '../widgets/league_title_widget.dart';
import '../widgets/xp_progress_bar_widget.dart';
import '../widgets/muscle_map_widget.dart'; // Створимо цей віджет
// import '../widgets/exertion_list_widget.dart'; // Пізніше
// import '../widgets/working_weights_list_widget.dart'; // Пізніше

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressCubit(
        RepositoryProvider.of<UserProfileRepository>(context),
        RepositoryProvider.of<LeagueRepository>(context),
        RepositoryProvider.of<WorkoutLogRepository>(context),
        RepositoryProvider.of<PredefinedExerciseRepository>(context),
        RepositoryProvider.of<fb_auth.FirebaseAuth>(context),
      ), // .initialize() викликається всередині конструктора кубіта
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const Color primaryOrange = Color(0xFFED5D1A); // Винесемо для доступу

    return Scaffold(
      // AppBar тут не потрібен, оскільки він є в HomePage
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          if (state is ProgressInitial || (state is ProgressLoading && state.message?.contains('Loading progress data...') == true)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProgressLoading && state.message?.contains('Refreshing data...') == true) {
            // Можна показати поточний вміст з індикатором завантаження зверху
            // або просто залишити як є, щоб уникнути мерехтіння
            // Поки що, для простоти, залишимо як є, і він перейде в ProgressLoaded
          }
          if (state is ProgressError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Error: ${state.message}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
            ));
          }
          if (state is ProgressLoaded) {
            final userProfile = state.userProfile;
            final currentLeague = state.currentLeague;
            final currentXpInLevel = (userProfile.xp - state.xpForCurrentLevelStart).clamp(0, state.xpForNextLevelTotal);
            final xpToNext = state.xpForNextLevelTotal - currentXpInLevel;

            return RefreshIndicator(
              onRefresh: () async {
                developer.log("Pull-to-refresh initiated on ProgressScreen", name: "ProgressScreen");
                context.read<ProgressCubit>().refreshData(); // Метод, який ми додамо в кубіт
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Для роботи RefreshIndicator
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ліга та Рівень
                    LeagueTitleWidget(
                      leagueName: currentLeague.name,
                      level: userProfile.level,
                      gradientColors: currentLeague.gradientColors,
                      onLeagueTap: () {
                        // TODO: Навігація на екран ліги (плейсхолдер)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tapped on ${currentLeague.name} - League screen TBD')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    XPProgressBarWidget(
                      currentXp: currentXpInLevel,
                      xpForNextLevel: state.xpForNextLevelTotal,
                      startLevelXpText: '${state.xpForCurrentLevelStart}',
                      endLevelXpText: '${state.xpForCurrentLevelStart + state.xpForNextLevelTotal}',
                    ),
                    Center(
                      child: Text(
                        '$xpToNext XP TO NEXT LEVEL!',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter'),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // VOLUME (7 DAYS)
                    Text('VOLUME (7 DAYS)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: MuscleMapWidget(
                            svgPath: 'assets/images/male_front.svg', // TODO: Динамічно змінювати на female
                            muscleData: state.volumePerMuscleGroup7Days,
                            maxThreshold: 20, // Максимальна кількість сетів для 100% червоного
                            baseColor: Colors.grey.shade200,
                            maxColor: Colors.red.shade700,
                            midColor: primaryOrange, // 10 сетів = помаранчевий
                            midThreshold: 10,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MuscleMapWidget(
                            svgPath: 'assets/images/male_back.svg', // TODO: Динамічно змінювати на female
                            muscleData: state.volumePerMuscleGroup7Days,
                            maxThreshold: 20,
                            baseColor: Colors.grey.shade200,
                            maxColor: Colors.red.shade700,
                            midColor: primaryOrange,
                            midThreshold: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // EXERTION (30 DAYS)
                    Text('EXERTION (30 DAYS)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (state.avgRpePerExercise30Days.isEmpty)
                      const Text('No RPE data logged in the last 30 days.', style: TextStyle(color: Colors.grey))
                    else
                      // TODO: Замінити на ExertionListWidget
                      Column(
                        children: state.avgRpePerExercise30Days.entries.map((entry) {
                           final exerciseName = context.read<ProgressCubit>().getExerciseNameById(entry.key) ?? 'Exercise ${entry.key.substring(0,5)}...';
                           return ListTile(
                             title: Text(exerciseName),
                             trailing: Text('Avg RPE: ${entry.value.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                             // Тут буде міні-графік (плейсхолдер)
                           );
                        }).toList(),
                      ),
                    const SizedBox(height: 30),

                    // WORKING WEIGHTS (90 DAYS)
                    Text('WORKING WEIGHTS (90 DAYS)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                     if (state.workingWeights90Days.isEmpty)
                      const Text('No weight data logged in the last 90 days.', style: TextStyle(color: Colors.grey))
                    else
                      // TODO: Замінити на WorkingWeightsListWidget
                       Column(
                        children: state.workingWeights90Days.entries.map((entry) {
                           final exerciseName = context.read<ProgressCubit>().getExerciseNameById(entry.key) ?? 'Exercise ${entry.key.substring(0,5)}...';
                           return ListTile(
                             title: Text(exerciseName),
                             subtitle: Text('${entry.value.length} data points'),
                             // Тут буде міні-графік (плейсхолдер)
                           );
                        }).toList(),
                      ),
                    const SizedBox(height: 30),
                    
                    // ADVICE SECTION (Placeholder)
                    Text('ADVICE', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Personalized advice based on your progress will appear here soon!', style: TextStyle(color: Colors.blueGrey)),
                    ),
                    const SizedBox(height: 20), // Додатковий відступ знизу
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }
}