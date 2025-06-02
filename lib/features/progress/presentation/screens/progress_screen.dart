// lib/features/progress/presentation/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:developer' as developer;
import 'dart:ui' show lerpDouble;

import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../../../../core/domain/repositories/league_repository.dart';
import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/predefined_exercise_repository.dart';
import '../cubit/progress_cubit.dart';
import '../widgets/league_title_widget.dart';
import '../widgets/xp_progress_bar_widget.dart';
import '../widgets/muscle_map_widget.dart';

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
      ),
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  static const Color primaryOrange = Color(0xFFED5D1A);

  Color _getRpeColor(double rpeValue) {
    final double t = (rpeValue / 10.0).clamp(0.0, 1.0);
    if (t <= 0.35) {
      return Color.lerp(Colors.green.shade500, Colors.yellow.shade600, t / 0.35)!;
    } else if (t <= 0.7) {
      return Color.lerp(Colors.yellow.shade600, Colors.orange.shade700, (t - 0.35) / 0.35)!;
    } else {
      return Color.lerp(Colors.orange.shade700, Colors.red.shade700, (t - 0.7) / 0.3)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<ProgressCubit, ProgressState>(
        builder: (context, state) {
          Widget contentToShow;

          if (state is ProgressInitial) {
            contentToShow = const Center(child: CircularProgressIndicator());
          } else if (state is ProgressLoading) {
            // Показуємо індикатор завантаження з повідомленням, якщо воно є
            contentToShow = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (state.message != null) ...[
                    const SizedBox(height: 16),
                    Text(state.message!, textAlign: TextAlign.center),
                  ]
                ],
              ),
            );
          } else if (state is ProgressError) {
            contentToShow = Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: ${state.message}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProgressCubit>().refreshData(),
                      child: const Text('Try Again'),
                    )
                  ],
                ),
              )
            );
          } else if (state is ProgressLoaded) {
            final userProfile = state.userProfile;
            final currentLeague = state.currentLeague;
            final currentXpInLevel = (userProfile.xp - state.xpForCurrentLevelStart).clamp(0, state.xpForNextLevelTotal);
            final xpToNext = state.xpForNextLevelTotal - currentXpInLevel;

            final String gender = userProfile.gender?.toLowerCase() ?? 'male';
            final String frontSvgPath = gender == 'female'
                ? 'assets/images/female_front.svg'
                : 'assets/images/male_front.svg';
            final String backSvgPath = gender == 'female'
                ? 'assets/images/female_back.svg'
                : 'assets/images/male_back.svg';
            
            const Color baseMuscleColor = Color(0xFFF0F0F0); 
            const Color midMuscleColor = primaryOrange; 
            const Color maxMuscleColor = Color(0xFFD50000); 
            const double midThresholdMuscle = 10.0;
            const double maxThresholdMuscle = 20.0;

            developer.log("ProgressScreen building with MuscleMap. Gender: $gender, Front SVG: $frontSvgPath, Back SVG: $backSvgPath", name: "ProgressScreen.BuildLoaded");
            developer.log("MuscleData for map: ${state.volumePerMuscleGroup7Days}", name: "ProgressScreen.BuildLoaded");

            contentToShow = SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LeagueTitleWidget(
                      leagueName: currentLeague.name,
                      level: userProfile.level,
                      gradientColors: currentLeague.gradientColors,
                      onLeagueTap: () {
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

                    Text('VOLUME (LAST 7 DAYS - SETS)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (state.volumePerMuscleGroup7Days.isEmpty) // Показуємо, якщо дані порожні (після завантаження)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: Text("No workout data for the last 7 days to display on muscle map.", style: TextStyle(color: Colors.grey.shade600))),
                      )
                    else 
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MuscleMapWidget(
                              key: ValueKey('front_map_${userProfile.gender}_${state.volumePerMuscleGroup7Days.hashCode}'),
                              svgPath: frontSvgPath,
                              muscleData: state.volumePerMuscleGroup7Days,
                              baseColor: baseMuscleColor,
                              midColor: midMuscleColor,
                              maxColor: maxMuscleColor,
                              midThreshold: midThresholdMuscle,
                              maxThreshold: maxThresholdMuscle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MuscleMapWidget(
                              key: ValueKey('back_map_${userProfile.gender}_${state.volumePerMuscleGroup7Days.hashCode}'),
                              svgPath: backSvgPath,
                              muscleData: state.volumePerMuscleGroup7Days,
                              baseColor: baseMuscleColor,
                              midColor: midMuscleColor,
                              maxColor: maxMuscleColor,
                              midThreshold: midThresholdMuscle,
                              maxThreshold: maxThresholdMuscle,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),

                    Text('EXERTION (AVG RPE - LAST 30 DAYS)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (state.avgRpePerExercise30Days.isEmpty)
                      const Text('No RPE data logged in the last 30 days.', style: TextStyle(color: Colors.grey))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.avgRpePerExercise30Days.length,
                        itemBuilder: (context, index) {
                          final entry = state.avgRpePerExercise30Days.entries.elementAt(index);
                          final exerciseName = context.read<ProgressCubit>().getExerciseNameById(entry.key) ?? 'Exercise ${entry.key.substring(0,5)}...';
                          final rpeColor = _getRpeColor(entry.value);
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(exerciseName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
                              trailing: Text(
                                entry.value.toStringAsFixed(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: rpeColor,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 1.0,
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0.5, 0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 30),

                    Text('WORKING WEIGHTS (AVG - LAST 90 DAYS)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                     if (state.avgWorkingWeights90Days.isEmpty)
                      const Text('No weight data logged in the last 90 days.', style: TextStyle(color: Colors.grey))
                    else
                       ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.avgWorkingWeights90Days.length,
                        itemBuilder: (context, index) {
                          final entry = state.avgWorkingWeights90Days.entries.elementAt(index);
                          final exerciseName = context.read<ProgressCubit>().getExerciseNameById(entry.key) ?? 'Exercise ${entry.key.substring(0,5)}...';
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(exerciseName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
                              trailing: Text(
                                'Avg: ${entry.value.toStringAsFixed(1)} KG',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryOrange),
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 30),

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
                    const SizedBox(height: 20),
                  ],
                ),
              );
          } else {
             // Якщо стан не ProgressInitial, ProgressLoading, ProgressError або ProgressLoaded,
             // то це дійсно непередбачений стан.
            contentToShow = const Center(child: Text('An unexpected state occurred. Please try again.'));
            developer.log("ProgressScreen: Reached unexpected state: $state", name: "ProgressScreen.Build");
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              developer.log("Pull-to-refresh initiated on ProgressScreen", name: "ProgressScreen.Refresh");
              context.read<ProgressCubit>().refreshData();
            },
            child: contentToShow,
          );
        },
      ),
    );
  }
}