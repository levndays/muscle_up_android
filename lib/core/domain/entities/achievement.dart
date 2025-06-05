// lib/core/domain/entities/achievement.dart
import 'package:flutter/material.dart'; // Keep for potential future use or if other parts need it
import 'user_profile.dart';

enum AchievementId {
  earlyBird,
  firstWorkout,
  consistentKing10,
  consistentKing30,
  volumeStarter,
  volumePro,
  level5Reached,
  level10Reached,
  personalRecordSet,
}

typedef ConditionChecker = String? Function(UserProfile userProfile);

class Achievement {
  final AchievementId id;
  final String name;
  final String description;
  final String emblemAssetPath; // CHANGED: from IconData icon to String emblemAssetPath
  final ConditionChecker? conditionCheckerMessage;
  final bool isPersonalized;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emblemAssetPath, // CHANGED
    this.conditionCheckerMessage,
    this.isPersonalized = false,
  });

  String getDynamicName({String? detail}) {
    if (isPersonalized && detail != null) {
      return name.replaceFirst('[Detail]', detail);
    }
    return name;
  }

  String getDynamicDescription({String? detail}) {
    if (isPersonalized && detail != null) {
      return description.replaceFirst('[Detail]', detail);
    }
    return description;
  }
}

// Placeholder asset paths - replace with actual paths when available
final Map<AchievementId, Achievement> allAchievements = {
  AchievementId.earlyBird: const Achievement(
    id: AchievementId.earlyBird,
    name: 'EARLY BIRD',
    description: 'Welcome to the club! Thanks for joining MuscleUP.',
    emblemAssetPath: 'assets/images/achievements/early_bird.png', // CHANGED
  ),
  AchievementId.firstWorkout: const Achievement(
    id: AchievementId.firstWorkout,
    name: 'FIRST STEP',
    description: 'You completed your first workout! Keep it up!',
    emblemAssetPath: 'assets/images/achievements/first_workout.png', // CHANGED
  ),
  AchievementId.consistentKing10: Achievement(
      id: AchievementId.consistentKing10,
      name: 'STREAK STAR (10)',
      description: '10-day workout streak! You are on fire!',
      emblemAssetPath: 'assets/images/achievements/streak_star_10.png', // CHANGED
      conditionCheckerMessage: (UserProfile profile) {
        if (profile.longestStreak >= 10) return null;
        return 'Current best streak: ${profile.longestStreak}/10 days.';
      }),
  AchievementId.consistentKing30: Achievement(
      id: AchievementId.consistentKing30,
      name: 'CONSISTENT KING (30)',
      description: '30-day workout streak! Unstoppable!',
      emblemAssetPath: 'assets/images/achievements/consistent_king_30.png', // CHANGED
      conditionCheckerMessage: (UserProfile profile) {
        if (profile.longestStreak >= 30) return null;
        return 'Current best streak: ${profile.longestStreak}/30 days.';
      }),
  AchievementId.volumeStarter: Achievement(
    id: AchievementId.volumeStarter,
    name: 'VOLUME STARTER',
    description: 'Lifted over 10,000 KG in total volume!',
    emblemAssetPath: 'assets/images/achievements/volume_starter.png', // CHANGED
    conditionCheckerMessage: (UserProfile profile) =>
        "Needs total volume tracking in profile.",
  ),
  AchievementId.level5Reached: Achievement(
      id: AchievementId.level5Reached,
      name: 'LEVEL 5 REACHED',
      description: 'Congratulations on reaching level 5!',
      emblemAssetPath: 'assets/images/achievements/level_5.png', // CHANGED
      conditionCheckerMessage: (UserProfile profile) {
        if (profile.level >= 5) return null;
        return 'Current level: ${profile.level}/5.';
      }),
  AchievementId.personalRecordSet: const Achievement(
    id: AchievementId.personalRecordSet,
    name: 'NEW RECORD: [Detail]!',
    description: 'Congratulations on setting a new personal record for [Detail]!',
    emblemAssetPath: 'assets/images/achievements/personal_record.png', // CHANGED
    isPersonalized: true,
  ),
  // Add other achievements with their emblemAssetPath
  AchievementId.level10Reached: Achievement( // Example, add more if they exist
      id: AchievementId.level10Reached,
      name: 'LEVEL 10 REACHED',
      description: 'Wow! Level 10! You\'re a true MuscleUP enthusiast!',
      emblemAssetPath: 'assets/images/achievements/level_10.png', // CHANGED
      conditionCheckerMessage: (UserProfile profile) {
        if (profile.level >= 10) return null;
        return 'Current level: ${profile.level}/10.';
      }),
  AchievementId.volumePro: Achievement( // Example
    id: AchievementId.volumePro,
    name: 'VOLUME PRO',
    description: 'Lifted over 100,000 KG in total volume! Incredible strength!',
    emblemAssetPath: 'assets/images/achievements/volume_pro.png', // CHANGED
    conditionCheckerMessage: (UserProfile profile) =>
        "Needs total volume tracking in profile.",
  ),
};