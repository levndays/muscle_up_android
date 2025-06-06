// lib/features/progress/presentation/cubit/progress_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart'; // For Color in _getDefaultLeaguesInternal and BuildContext
import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/entities/league_info.dart';
import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';
import '../../../../l10n/app_localizations.dart'; // <<< ADDED THIS IMPORT

import '../../../../core/domain/repositories/user_profile_repository.dart';
import '../../../../core/domain/repositories/league_repository.dart';
import '../../../../core/domain/repositories/workout_log_repository.dart';
import '../../../../core/domain/repositories/predefined_exercise_repository.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final UserProfileRepository _userProfileRepository;
  final LeagueRepository _leagueRepository;
  final WorkoutLogRepository _workoutLogRepository;
  final PredefinedExerciseRepository _predefinedExerciseRepository;
  final fb_auth.FirebaseAuth _firebaseAuth;

  StreamSubscription<UserProfile?>? _userProfileSubscription;
  List<LeagueInfo> _allLeagues = [];
  List<PredefinedExercise> _allPredefinedExercises = [];

  static const int maxWorkoutsForTrend = 15;

  ProgressCubit(
    this._userProfileRepository,
    this._leagueRepository,
    this._workoutLogRepository,
    this._predefinedExerciseRepository,
    this._firebaseAuth,
  ) : super(ProgressInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    emit(const ProgressLoading(message: 'Loading progress data...'));
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const ProgressError('User not authenticated.'));
      return;
    }

    try {
      _allLeagues = await _leagueRepository.getAllLeagues();
      if (_allLeagues.isEmpty) {
        developer.log("ProgressCubit: No leagues loaded from repository, using defaults.", name: "ProgressCubit");
        _allLeagues = _getDefaultLeaguesInternal();
      }
      _allPredefinedExercises = await _predefinedExerciseRepository.getAllExercises();

      await _userProfileSubscription?.cancel();
      _userProfileSubscription = _userProfileRepository.getUserProfileStream(userId).listen(
        (userProfile) {
          if (userProfile != null) {
            _processUserProfileUpdate(userProfile);
          } else {
            developer.log("ProgressCubit: User profile is null from stream for userId: $userId", name: "ProgressCubit");
             if (state is ProgressLoaded) {
              emit(const ProgressError('User profile became unavailable.'));
            } else {
              emit(const ProgressError('User profile not found or not yet available.'));
            }
          }
        },
        onError: (error, stackTrace) {
          developer.log("ProgressCubit: Error in user profile stream for $userId: $error", name: "ProgressCubit", error: error, stackTrace: stackTrace);
          emit(ProgressError('Error loading user profile: ${error.toString()}'));
        },
      );
    } catch (e, s) {
      developer.log('Error during ProgressCubit initialization: $e', error: e, stackTrace: s, name: 'ProgressCubit');
      emit(ProgressError('Failed to initialize progress screen: ${e.toString()}'));
    }
  }

  List<LeagueInfo> _getDefaultLeaguesInternal() {
    const Color primaryOrange = Color(0xFFED5D1A);
    return [
      LeagueInfo(leagueId: 'beginner', name: 'BEGINNER LEAGUE', minLevel: 1, maxLevel: 14, minXp: 0, gradientColors: [primaryOrange, Colors.black], description: 'Start your journey!'),
      LeagueInfo(leagueId: 'intermediate', name: 'INTERMEDIATE LEAGUE', minLevel: 15, maxLevel: 49, minXp: 0, gradientColors: [Colors.blue, Colors.lightBlueAccent], description: 'Keep pushing!'),
      LeagueInfo(leagueId: 'advanced', name: 'ADVANCED LEAGUE', minLevel: 50, maxLevel: 79, minXp: 0, gradientColors: [Colors.purple, Colors.deepPurpleAccent], description: 'You are strong!'),
      const LeagueInfo(leagueId: 'bronze', name: 'BRONZE LEAGUE', minLevel: 80, maxLevel: 99, minXp: 0, gradientColors: [Color(0xFFCD7F32), Color(0xFF8C531B)], description: 'Elite warrior!'),
      const LeagueInfo(leagueId: 'silver', name: 'SILVER LEAGUE', minLevel: 100, maxLevel: 149, minXp: 0, gradientColors: [Color(0xFFC0C0C0), Color(0xFFAEAFAF)], description: 'Shining bright!'),
      const LeagueInfo(leagueId: 'golden', name: 'GOLDEN LEAGUE', minLevel: 150, maxLevel: null, minXp: 0, gradientColors: [Color(0xFFFFD700), Color(0xFFE5C100)], description: 'Legendary status!'),
    ];
  }

  Future<void> refreshData() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) {
      emit(const ProgressError('User not authenticated. Cannot refresh.'));
      return;
    }

    if (state is! ProgressError) {
        final message = state is ProgressLoaded ? 'Refreshing progress data...' : 'Loading progress data...';
        emit(ProgressLoading(message: message));
    }

    try {
      _allLeagues = await _leagueRepository.getAllLeagues();
      if (_allLeagues.isEmpty) {
        developer.log("ProgressCubit (refresh): No leagues loaded from repository, using defaults.", name: "ProgressCubit");
        _allLeagues = _getDefaultLeaguesInternal();
      }
      _allPredefinedExercises = await _predefinedExerciseRepository.getAllExercises();

      final userProfile = await _userProfileRepository.getUserProfile(userId);
      if (userProfile != null) {
        await _processUserProfileUpdate(userProfile);
      } else {
        emit(const ProgressError('User profile not found during refresh.'));
      }
    } catch (e, s) {
      developer.log('Error during ProgressCubit refreshData: $e', error: e, stackTrace: s, name: 'ProgressCubit');
      emit(ProgressError('Failed to refresh data: ${e.toString()}'));
    }
  }

  String getExerciseNameById(BuildContext context, String exerciseId) { // Added BuildContext
    if (_allPredefinedExercises.isEmpty) {
        developer.log("Attempted to get exercise name but _allPredefinedExercises is empty.", name: "ProgressCubit.getExerciseNameById");
        return AppLocalizations.of(context)!.exerciseExplorerLoading;
    }
    try {
      final exercise = _allPredefinedExercises.firstWhere((ex) => ex.id == exerciseId);
      return exercise.getLocalizedName(context);
    } catch (e) {
      developer.log("Exercise with ID $exerciseId not found in cached list.", name: "ProgressCubit.getExerciseNameById");
      return AppLocalizations.of(context)!.progressScreenExercisePlaceholder(exerciseId.length > 5 ? exerciseId.substring(0,5) : exerciseId);
    }
  }

  Future<void> _processUserProfileUpdate(UserProfile userProfile) async {
    final currentLeague = _determineCurrentLeague(userProfile);
    final xpData = _calculateXpForLevel(userProfile.level);

    bool shouldEmitLogLoading = true;
    String loadingMessageForLogs = 'Loading workout stats...';

    if (state is ProgressLoading) {
      final currentLoadingState = state as ProgressLoading;
      if (currentLoadingState.message != null &&
          (currentLoadingState.message!.contains('workout stats') || currentLoadingState.message!.contains('Refreshing'))) {
        shouldEmitLogLoading = false;
      }
    } else if (state is ProgressLoaded) {
      loadingMessageForLogs = 'Refreshing workout stats...';
    }

    if (shouldEmitLogLoading) {
      emit(ProgressLoading(message: loadingMessageForLogs));
    }

    try {
      final volumeData = await _calculateVolumePerMuscleGroup7Days(userProfile.uid);
      final avgRpe30DaysData = await _calculateAvgRpePerExercise30Days(userProfile.uid);
      final rpeTrendData = await _calculateRpePerWorkoutTrend(userProfile.uid);
      final workingWeightTrendData = await _calculateWorkingWeightPerWorkoutTrend(userProfile.uid);

      emit(ProgressLoaded(
        userProfile: userProfile,
        currentLeague: currentLeague,
        xpForCurrentLevelStart: xpData['start']!,
        xpForNextLevelTotal: xpData['totalForLevel']!,
        volumePerMuscleGroup7Days: volumeData,
        avgRpePerExercise30Days: avgRpe30DaysData,
        rpePerWorkoutTrend: rpeTrendData,
        workingWeightPerWorkoutTrend: workingWeightTrendData,
        // avgWorkingWeights90Days is not explicitly passed if not used for primary display
      ));
    } catch (e, s) {
      developer.log('Error processing workout logs for progress update: $e', error: e, stackTrace: s, name: 'ProgressCubit._processUserProfileUpdate');
      emit(ProgressError('Failed to process workout data: ${e.toString()}'));
    }
  }

  LeagueInfo _determineCurrentLeague(UserProfile userProfile) {
    if (_allLeagues.isEmpty) {
      developer.log("No leagues available for determining current league, returning default beginner league.", name: "ProgressCubit._determineCurrentLeague");
      return _getDefaultLeaguesInternal().first;
    }
    for (int i = _allLeagues.length - 1; i >= 0; i--) {
      final league = _allLeagues[i];
      if (userProfile.level >= league.minLevel) {
        if (league.maxLevel == null || userProfile.level <= league.maxLevel!) {
          return league;
        }
      }
    }
    developer.log("Could not determine league for level ${userProfile.level}, returning first available league.", name: "ProgressCubit._determineCurrentLeague");
    return _allLeagues.isNotEmpty ? _allLeagues.first : _getDefaultLeaguesInternal().first;
  }

  Map<String, int> _calculateXpForLevel(int level) {
    const int xpPerLevelBase = 200;
    int totalXpForPrevLevels = 0;
    if (level > 1) {
      for (int i = 1; i < level; i++) {
        totalXpForPrevLevels += (xpPerLevelBase + (i - 1) * 50);
      }
    }
    final int xpToCompleteCurrentLevelForThisLevel = xpPerLevelBase + (level - 1) * 50;
    return {'start': totalXpForPrevLevels, 'totalForLevel': xpToCompleteCurrentLevelForThisLevel};
  }

  Future<Map<String, double>> _calculateVolumePerMuscleGroup7Days(String userId) async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final workoutLogs = await _workoutLogRepository.getUserWorkoutHistory(
      userId,
      startDate: sevenDaysAgo,
      limit: null,
    );

    Map<String, double> volumeMap = {};
    final muscleGroupMapping = _getMuscleGroupToSvgIdMapping();

    if (_allPredefinedExercises.isEmpty) {
      developer.log("Predefined exercises list is empty, cannot calculate volume per muscle group.", name: "ProgressCubit.VolumeCalc");
      return volumeMap;
    }

    for (var session in workoutLogs) {
      if (session.status != WorkoutStatus.completed) continue;

      for (var loggedEx in session.completedExercises) {
        PredefinedExercise? predefinedEx;
        try {
          predefinedEx = _allPredefinedExercises.firstWhere(
            (ex) => ex.id == loggedEx.predefinedExerciseId,
          );
        } catch (e) {
          developer.log("Predefined exercise with id ${loggedEx.predefinedExerciseId} not found in cached list for volume calc.", name: "ProgressCubit.VolumeCalc");
          continue;
        }

        List<String> targetSvgIds = [];
        String primaryGroupKeyEn = predefinedEx.primaryMuscleGroup['en']?.toLowerCase().replaceAll(' ', '-') ?? '';

        if (primaryGroupKeyEn.isNotEmpty && muscleGroupMapping.containsKey(primaryGroupKeyEn)) {
          targetSvgIds.addAll(muscleGroupMapping[primaryGroupKeyEn]!);
        } else {
          developer.log("No SVG mapping for primary group (key: $primaryGroupKeyEn) from exercise: ${predefinedEx.name['en']}", name: "ProgressCubit.VolumeCalc");
        }
        
        final secondaryGroupsEn = predefinedEx.secondaryMuscleGroups['en'] ?? [];
        for (var secGroupEn in secondaryGroupsEn) {
          String secGroupKeyEn = secGroupEn.toLowerCase().replaceAll(' ', '-');
          if (muscleGroupMapping.containsKey(secGroupKeyEn)) {
            targetSvgIds.addAll(muscleGroupMapping[secGroupKeyEn]!);
          } else {
            developer.log("No SVG mapping for secondary group (key: $secGroupKeyEn) from exercise: ${predefinedEx.name['en']}", name: "ProgressCubit.VolumeCalc");
          }
        }

        targetSvgIds = targetSvgIds.toSet().toList();

        int setCountForExercise = loggedEx.completedSets.where((s) => s.isCompleted && (s.reps ?? 0) > 0).length;

        for (var svgId in targetSvgIds) {
          volumeMap[svgId] = (volumeMap[svgId] ?? 0) + setCountForExercise.toDouble();
        }
      }
    }
    developer.log("ProgressCubit: Volume (sets) per muscle group (7 days): $volumeMap", name: "ProgressCubit.VolumeCalc");
    return volumeMap;
  }

  Future<Map<String, double>> _calculateAvgRpePerExercise30Days(String userId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final workoutLogs = await _workoutLogRepository.getUserWorkoutHistory(
      userId,
      startDate: thirtyDaysAgo,
      limit: null,
    );

    Map<String, List<int>> rpeValuesPerExercise = {};

    for (var session in workoutLogs) {
      if (session.status != WorkoutStatus.completed) continue;
      for (var loggedEx in session.completedExercises) {
        rpeValuesPerExercise.putIfAbsent(loggedEx.predefinedExerciseId, () => []);
        for (var set in loggedEx.completedSets) {
          if (set.isCompleted && set.notes != null && set.notes!.startsWith("RPE_DATA:")) {
            try {
              final rpeStrings = set.notes!.substring("RPE_DATA:".length).split(',');
              rpeValuesPerExercise[loggedEx.predefinedExerciseId]!.addAll(
                rpeStrings.where((s) => s.isNotEmpty).map(int.parse)
              );
            } catch (e) {
              developer.log("Error parsing RPE data for set: ${set.notes}", error: e, name: "ProgressCubit.RPECalc");
            }
          }
        }
      }
    }

    Map<String, double> avgRpeMap = {};
    rpeValuesPerExercise.forEach((exerciseId, rpeList) {
      if (rpeList.isNotEmpty) {
        avgRpeMap[exerciseId] = rpeList.reduce((a, b) => a + b) / rpeList.length;
      }
    });
    developer.log("Avg RPE per exercise (30 days): ${avgRpeMap.length} exercises processed.", name: "ProgressCubit.RPECalc");
    return avgRpeMap;
  }

  Future<Map<String, List<double>>> _calculateRpePerWorkoutTrend(String userId) async {
    final workoutLogs = await _workoutLogRepository.getUserWorkoutHistory(
      userId,
      limit: maxWorkoutsForTrend + 10,
    );

    Map<String, List<double>> rpeTrendMap = {};
    workoutLogs.sort((a, b) => a.startedAt.compareTo(b.startedAt));

    for (var session in workoutLogs) {
      if (session.status != WorkoutStatus.completed) continue;
      for (var loggedEx in session.completedExercises) {
        List<int> allRpeValuesForExerciseInSession = [];
        for (var set in loggedEx.completedSets) {
          if (set.isCompleted && set.notes != null && set.notes!.startsWith("RPE_DATA:")) {
            try {
              final rpeStrings = set.notes!.substring("RPE_DATA:".length).split(',');
              allRpeValuesForExerciseInSession.addAll(
                rpeStrings.where((s) => s.isNotEmpty).map(int.parse)
              );
            } catch (e) {
              developer.log("Error parsing RPE data for trend: ${set.notes}", error: e, name: "ProgressCubit.RPETrendCalc");
            }
          }
        }
        if (allRpeValuesForExerciseInSession.isNotEmpty) {
          final avgRpeForExerciseInSession = allRpeValuesForExerciseInSession.reduce((a, b) => a + b) / allRpeValuesForExerciseInSession.length;
          rpeTrendMap.putIfAbsent(loggedEx.predefinedExerciseId, () => []).add(avgRpeForExerciseInSession);
        }
      }
    }
    rpeTrendMap.forEach((exerciseId, trendList) {
      if (trendList.length > maxWorkoutsForTrend) {
        rpeTrendMap[exerciseId] = trendList.sublist(trendList.length - maxWorkoutsForTrend);
      }
    });
    developer.log("RPE per workout trend: ${rpeTrendMap.entries.where((e) => e.value.isNotEmpty).length} exercises processed with trend data.", name: "ProgressCubit.RPETrendCalc");
    return rpeTrendMap;
  }
  
  // This declaration '_calculateAvgWorkingWeights90Days' isn't referenced.
  // You can remove it if it's no longer needed.
  // ignore: unused_element
  Future<Map<String, double>> _calculateAvgWorkingWeights90Days(String userId) async {
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final workoutLogs = await _workoutLogRepository.getUserWorkoutHistory(
        userId,
        startDate: ninetyDaysAgo,
        limit: null
    );
    Map<String, List<double>> weightsPerExercise = {};
    for (var session in workoutLogs) {
      if (session.status != WorkoutStatus.completed) continue;
      for (var loggedEx in session.completedExercises) {
        for (var set in loggedEx.completedSets) {
          if (set.isCompleted && set.weightKg != null && set.weightKg! > 0 && set.reps != null && set.reps! > 0) {
            weightsPerExercise.putIfAbsent(loggedEx.predefinedExerciseId, () => []).add(set.weightKg!);
          }
        }
      }
    }
    Map<String, double> avgWeightsMap = {};
    weightsPerExercise.forEach((exerciseId, weightsList) {
      if (weightsList.isNotEmpty) {
        avgWeightsMap[exerciseId] = weightsList.reduce((a, b) => a + b) / weightsList.length;
      }
    });
    developer.log("Avg working weights (90 days): ${avgWeightsMap.length} exercises processed.", name: "ProgressCubit.AvgWorkingWeights");
    return avgWeightsMap;
  }

  Future<Map<String, List<double>>> _calculateWorkingWeightPerWorkoutTrend(String userId) async {
    final workoutLogs = await _workoutLogRepository.getUserWorkoutHistory(
      userId,
      limit: maxWorkoutsForTrend + 10, 
    );

    Map<String, List<double>> weightTrendMap = {};
    workoutLogs.sort((a, b) => a.startedAt.compareTo(b.startedAt)); 

    for (var session in workoutLogs) {
      if (session.status != WorkoutStatus.completed) continue;

      for (var loggedEx in session.completedExercises) {
        List<double> weightsForExerciseInSession = [];
        for (var set in loggedEx.completedSets) {
          if (set.isCompleted && set.weightKg != null && set.weightKg! > 0 && (set.reps ?? 0) > 0) {
            weightsForExerciseInSession.add(set.weightKg!);
          }
        }

        if (weightsForExerciseInSession.isNotEmpty) {
          final avgWeightForExerciseInSession = weightsForExerciseInSession.reduce((a, b) => a + b) / weightsForExerciseInSession.length;
          
          weightTrendMap.putIfAbsent(loggedEx.predefinedExerciseId, () => []).add(avgWeightForExerciseInSession);
        }
      }
    }

    weightTrendMap.forEach((exerciseId, trendList) {
      if (trendList.length > maxWorkoutsForTrend) {
        weightTrendMap[exerciseId] = trendList.sublist(trendList.length - maxWorkoutsForTrend);
      }
    });

    developer.log("Working weight per workout trend: ${weightTrendMap.entries.where((e)=> e.value.isNotEmpty).length} exercises processed.", name: "ProgressCubit.WeightTrendCalc");
    return weightTrendMap;
  }


  Map<String, List<String>> _getMuscleGroupToSvgIdMapping() {
    return {
      'chest': ['chest'],
      'front-shoulders': ['front-shoulders'],
      'biceps': ['biceps'],
      'forearms': ['forearms'],
      'hands': ['hands'],
      'abdominals': ['abdominals'],
      'obliques': ['obliques'],
      'quadriceps': ['quads'],
      'calves': ['calves'],
      'traps': ['traps'],
      'rear-shoulders': ['rear-shoulders'],
      'traps-middle': ['traps-middle'],
      'lats': ['lats'],
      'lower-back': ['lowerback'],
      'triceps': ['triceps'],
      'glutes': ['glutes'],
      'hamstrings': ['hamstrings'],
      'shoulders': ['front-shoulders', 'rear-shoulders', 'traps'],
      'back': ['lats', 'traps', 'traps-middle', 'lowerback', 'rear-shoulders'],
      'core': ['abdominals', 'obliques', 'lowerback'],
      'legs': ['quads', 'hamstrings', 'glutes', 'calves'],
      'arms': ['biceps', 'triceps', 'forearms', 'hands'],
      'upper-back': ['lats', 'traps', 'traps-middle', 'rear-shoulders'],
      'rhomboids': ['traps-middle', 'rear-shoulders'],
    };
  }

  @override
  Future<void> close() {
    _userProfileSubscription?.cancel();
    developer.log("ProgressCubit closed and subscriptions cancelled.", name: "ProgressCubit");
    return super.close();
  }
}