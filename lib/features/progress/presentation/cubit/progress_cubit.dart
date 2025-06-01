// lib/features/progress/presentation/cubit/progress_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart'; // Для Color
import 'dart:developer' as developer;
import 'dart:math' as math;

import '../../../../core/domain/entities/user_profile.dart';
import '../../../../core/domain/entities/league_info.dart';
import '../../../../core/domain/entities/workout_session.dart';
import '../../../../core/domain/entities/logged_exercise.dart';
import '../../../../core/domain/entities/logged_set.dart';
import '../../../../core/domain/entities/predefined_exercise.dart';

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
         developer.log("ProgressCubit: No leagues loaded from repository, using defaults again for safety.", name: "ProgressCubit");
        _allLeagues = _getDefaultLeaguesInternal(); 
      }
      _allPredefinedExercises = await _predefinedExerciseRepository.getAllExercises();

      _userProfileSubscription?.cancel();
      _userProfileSubscription = _userProfileRepository.getUserProfileStream(userId).listen(
        (userProfile) {
          if (userProfile != null) {
            _processUserProfileUpdate(userProfile);
          } else {
            // Це може статися, якщо профіль видалено або ще не створено Firebase Function
            // Краще повідомити користувача, що профіль не завантажено
            developer.log("ProgressCubit: User profile is null from stream for userId: $userId", name: "ProgressCubit");
            emit(const ProgressError('User profile not found or not yet available.'));
          }
        },
        onError: (error, stackTrace) {
          developer.log("ProgressCubit: Error in user profile stream for userId: $userId", error: error, stackTrace: stackTrace, name: "ProgressCubit");
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
     // Емітуємо стан завантаження, якщо поточний стан не є помилкою (щоб не скидати повідомлення про помилку)
     if (state is! ProgressError) {
        emit(const ProgressLoading(message: 'Refreshing progress data...'));
     }
     try {
        final userProfile = await _userProfileRepository.getUserProfile(userId);
        if (userProfile != null) {
          // Оновлюємо ліги та вправи, якщо вони могли змінитися (опціонально, залежить від логіки)
          // _allLeagues = await _leagueRepository.getAllLeagues(); 
          // _allPredefinedExercises = await _predefinedExerciseRepository.getAllExercises();
          await _processUserProfileUpdate(userProfile);
        } else {
          emit(const ProgressError('User profile not found during refresh.'));
        }
     } catch (e) {
        emit(ProgressError('Failed to refresh data: ${e.toString()}'));
     }
  }
  
  String? getExerciseNameById(String exerciseId) {
    try {
      return _allPredefinedExercises.firstWhere((ex) => ex.id == exerciseId).name;
    } catch (e) {
      return null; // Або 'Unknown Exercise'
    }
  }


  Future<void> _processUserProfileUpdate(UserProfile userProfile) async {
    final currentLeague = _determineCurrentLeague(userProfile);
    final xpData = _calculateXpForLevel(userProfile.level);

    // Перевіряємо, чи потрібно оновлювати дані логів.
    // Можна додати логіку, щоб не перезавантажувати логи, якщо профіль оновився,
    // але логи тренувань, ймовірно, не змінилися (наприклад, зміна displayName).
    // Для простоти, поки що перезавантажуємо завжди.
    
    // Емітуємо стан завантаження для логів, якщо основний профіль вже завантажений
    // Це допоможе уникнути перезапису ProgressLoaded станом ProgressLoading без повідомлення
    if (state is ProgressLoaded || state is ProgressInitial) {
      emit(ProgressLoading(message: state is ProgressLoaded ? 'Refreshing workout stats...' : 'Loading workout stats...'));
    }


    try {
      final volumeData = await _calculateVolumePerMuscleGroup7Days(userProfile.uid);
      final exertionData = await _calculateAvgRpePerExercise30Days(userProfile.uid);
      final workingWeightsData = await _calculateWorkingWeights90Days(userProfile.uid);

      emit(ProgressLoaded(
        userProfile: userProfile,
        currentLeague: currentLeague,
        xpForCurrentLevelStart: xpData['start']!,
        xpForNextLevelTotal: xpData['totalForLevel']!,
        volumePerMuscleGroup7Days: volumeData,
        avgRpePerExercise30Days: exertionData,
        workingWeights90Days: workingWeightsData,
      ));
    } catch (e,s) {
      developer.log('Error processing workout logs for progress: $e', error: e, stackTrace: s, name: 'ProgressCubit');
      emit(ProgressError('Failed to process workout data: ${e.toString()}'));
    }
  }

  LeagueInfo _determineCurrentLeague(UserProfile userProfile) {
    if (_allLeagues.isEmpty) {
      developer.log("No leagues available, returning default beginner league.", name: "ProgressCubit._determineCurrentLeague");
      return const LeagueInfo(leagueId: 'default_beginner', name: 'BEGINNER LEAGUE', minLevel: 1, minXp: 0, gradientColors: [Color(0xFFED5D1A), Colors.black]);
    }
    _allLeagues.sort((a, b) => a.minLevel.compareTo(b.minLevel));

    for (int i = _allLeagues.length - 1; i >= 0; i--) {
      final league = _allLeagues[i];
      if (userProfile.level >= league.minLevel && (league.maxLevel == null || userProfile.level <= league.maxLevel!)) {
        return league;
      }
    }
    return _allLeagues.first;
  }

  Map<String, int> _calculateXpForLevel(int level) {
    const int xpPerLevelBase = 200;
    int totalXpForPrevLevels = 0;
    if (level > 1) {
      for (int i = 1; i < level; i++) {
        totalXpForPrevLevels += (xpPerLevelBase + (i - 1) * 50);
      }
    }
    final int xpToCompleteCurrentLevel = xpPerLevelBase + (level - 1) * 50;
    return {'start': totalXpForPrevLevels, 'totalForLevel': xpToCompleteCurrentLevel};
  }

  Future<Map<String, double>> _calculateVolumePerMuscleGroup7Days(String userId) async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final workoutLogs = await _workoutLogRepository.getUserWorkoutHistory(
      userId, 
      startDate: sevenDaysAgo, 
      limit: null 
    );

    Map<String, double> volumeMap = {}; // Тут буде кількість сетів
    final muscleGroupMapping = _getMuscleGroupToSvgIdMapping();

    for (var session in workoutLogs) {
      for (var loggedEx in session.completedExercises) {
        final predefinedEx = _allPredefinedExercises.firstWhere(
          (ex) => ex.id == loggedEx.predefinedExerciseId,
          orElse: () {
            developer.log("Predefined exercise with id ${loggedEx.predefinedExerciseId} not found in local list.", name: "ProgressCubit");
            return PredefinedExercise(id: loggedEx.predefinedExerciseId, name: 'Unknown Exercise', normalizedName: 'unknown exercise', primaryMuscleGroup: 'Unknown', secondaryMuscleGroups: [], equipmentNeeded: [], description: '', difficultyLevel: '', tags: []);
          }
        );
        
        List<String> targetSvgIds = [];
        // Головна група
        String primaryGroupKey = predefinedEx.primaryMuscleGroup.toLowerCase().replaceAll(' ', '-');
        if (muscleGroupMapping.containsKey(primaryGroupKey)) {
          targetSvgIds.addAll(muscleGroupMapping[primaryGroupKey]!);
        } else {
          developer.log("No SVG mapping for primary group: ${predefinedEx.primaryMuscleGroup}", name: "ProgressCubit.VolumeCalc");
        }
        
        // Додаткові групи
        for (var secGroup in predefinedEx.secondaryMuscleGroups) {
          String secGroupKey = secGroup.toLowerCase().replaceAll(' ', '-');
          if (muscleGroupMapping.containsKey(secGroupKey)) {
            targetSvgIds.addAll(muscleGroupMapping[secGroupKey]!);
          } else {
             developer.log("No SVG mapping for secondary group: $secGroup", name: "ProgressCubit.VolumeCalc");
          }
        }
        targetSvgIds = targetSvgIds.toSet().toList(); 

        int setCountForExercise = loggedEx.completedSets.where((s) => s.isCompleted && s.reps != null && s.reps! > 0).length;

        for (var svgId in targetSvgIds) {
          volumeMap[svgId] = (volumeMap[svgId] ?? 0) + setCountForExercise.toDouble();
        }
      }
    }
    developer.log("Volume (sets) per muscle group (7 days): $volumeMap", name: "ProgressCubit");
    return volumeMap;
  }

  Future<Map<String, double>> _calculateAvgRpePerExercise30Days(String userId) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final workoutLogs = await _workoutLogRepository.getUserWorkoutHistory(
      userId, 
      startDate: thirtyDaysAgo,
      limit: null
    );

    Map<String, List<int>> rpeValuesPerExercise = {}; 

    for (var session in workoutLogs) {
      for (var loggedEx in session.completedExercises) {
        if (!rpeValuesPerExercise.containsKey(loggedEx.predefinedExerciseId)) {
          rpeValuesPerExercise[loggedEx.predefinedExerciseId] = [];
        }
        for (var set in loggedEx.completedSets) {
          if (set.isCompleted && set.notes != null && set.notes!.startsWith("RPE_DATA:")) {
            try {
              final rpeStrings = set.notes!.substring("RPE_DATA:".length).split(',');
              rpeValuesPerExercise[loggedEx.predefinedExerciseId]!.addAll(
                rpeStrings.where((s) => s.isNotEmpty).map(int.parse)
              );
            } catch (e) {
              developer.log("Error parsing RPE data for set: ${set.notes}", error: e, name: "ProgressCubit");
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
    developer.log("Avg RPE per exercise (30 days): $avgRpeMap", name: "ProgressCubit");
    return avgRpeMap;
  }

  Future<Map<String, List<WorkoutDataPoint>>> _calculateWorkingWeights90Days(String userId) async {
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final workoutLogs = await _workoutLogRepository.getUserWorkoutHistory(
        userId, 
        startDate: ninetyDaysAgo,
        limit: null 
    );

    Map<String, List<WorkoutDataPoint>> weightsMap = {};
    Map<String, Map<DateTime, double>> maxWeightPerDayPerExercise = {};

    for (var session in workoutLogs) {
      DateTime sessionDate = DateTime(session.startedAt.toDate().year, session.startedAt.toDate().month, session.startedAt.toDate().day);
      for (var loggedEx in session.completedExercises) {
        double maxWeightInSession = 0;
        for (var set in loggedEx.completedSets) {
          if (set.isCompleted && set.weightKg != null && set.weightKg! > maxWeightInSession) {
            maxWeightInSession = set.weightKg!;
          }
        }

        if (maxWeightInSession > 0) {
          maxWeightPerDayPerExercise.putIfAbsent(loggedEx.predefinedExerciseId, () => {});
          if ((maxWeightPerDayPerExercise[loggedEx.predefinedExerciseId]![sessionDate] ?? 0) < maxWeightInSession) {
            maxWeightPerDayPerExercise[loggedEx.predefinedExerciseId]![sessionDate] = maxWeightInSession;
          }
        }
      }
    }
    
    maxWeightPerDayPerExercise.forEach((exerciseId, dailyMaxWeights) {
      weightsMap[exerciseId] = dailyMaxWeights.entries
          .map((entry) => WorkoutDataPoint(entry.key, entry.value))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date)); 
    });

    developer.log("Working weights (90 days): ${weightsMap.keys.length} exercises processed", name: "ProgressCubit");
    return weightsMap;
  }


  Map<String, List<String>> _getMuscleGroupToSvgIdMapping() {
    // Важливо, щоб ключі тут відповідали значенням primaryMuscleGroup та secondaryMuscleGroups 
    // з PredefinedExercise (у нижньому регістрі, замість пробілів - дефіс)
    // Значення - це списки ID груп з SVG
    return {
      'chest': ['chest'],
      'quadriceps': ['quads'],
      'back': ['lats', 'traps', 'traps-middle', 'lowerback', 'rear-shoulders'], 
      'shoulders': ['front-shoulders', 'rear-shoulders'],
      'biceps': ['biceps'],
      'triceps': ['triceps'],
      'glutes': ['glutes'],
      'hamstrings': ['hamstrings'],
      'calves': ['calves'],
      'core': ['abdominals', 'obliques'],
      'abdominals': ['abdominals'],
      'obliques': ['obliques'],
      'forearms': ['forearms', 'hands'], 
      'traps': ['traps', 'traps-middle'],
      'lats': ['lats'],
      'lower-back': ['lowerback'], // Для "Lower Back"
      // "front-deltoids" не є стандартною групою, але "shoulders" покривають її
      // "upper-back" - це частина "traps", "rear-shoulders", "lats"
    };
  }

  @override
  Future<void> close() {
    _userProfileSubscription?.cancel();
    return super.close();
  }
}