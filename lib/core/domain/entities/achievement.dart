// lib/core/domain/entities/achievement.dart
import 'package:flutter/material.dart';
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
  personalRecordSet, // <-- NEW ACHIEVEMENT ID
}

typedef ConditionChecker = String? Function(UserProfile userProfile);

class Achievement {
  final AchievementId id;
  final String name;
  final String description;
  final IconData icon;
  final ConditionChecker? conditionCheckerMessage;
  final bool isPersonalized; // <-- NEW FIELD to indicate if name/desc can be dynamic

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.conditionCheckerMessage,
    this.isPersonalized = false, // <-- Default to false
  });

  // Helper to get dynamic name for personalized achievements
  String getDynamicName({String? detail}) {
    if (isPersonalized && detail != null) {
      return name.replaceFirst('[Detail]', detail);
    }
    return name;
  }

  // Helper to get dynamic description
  String getDynamicDescription({String? detail}) {
    if (isPersonalized && detail != null) {
      return description.replaceFirst('[Detail]', detail);
    }
    return description;
  }
}

final Map<AchievementId, Achievement> allAchievements = {
  AchievementId.earlyBird: const Achievement(
    id: AchievementId.earlyBird,
    name: 'EARLY BIRD',
    description: 'Welcome to the club! Thanks for joining MuscleUP.',
    icon: Icons.auto_awesome,
  ),
  AchievementId.firstWorkout: const Achievement(
    id: AchievementId.firstWorkout,
    name: 'FIRST STEP',
    description: 'You completed your first workout! Keep it up!',
    icon: Icons.fitness_center,
  ),
  AchievementId.consistentKing10: Achievement(
      id: AchievementId.consistentKing10,
      name: 'STREAK STAR (10)',
      description: '10-day workout streak! You are on fire!',
      icon: Icons.local_fire_department,
      conditionCheckerMessage: (UserProfile profile) {
        if (profile.longestStreak >= 10) return null;
        return 'Current best streak: ${profile.longestStreak}/10 days.';
      }),
  AchievementId.consistentKing30: Achievement(
      id: AchievementId.consistentKing30,
      name: 'CONSISTENT KING (30)',
      description: '30-day workout streak! Unstoppable!',
      icon: Icons.whatshot,
      conditionCheckerMessage: (UserProfile profile) {
        if (profile.longestStreak >= 30) return null;
        return 'Current best streak: ${profile.longestStreak}/30 days.';
      }),
  AchievementId.volumeStarter: Achievement(
    id: AchievementId.volumeStarter,
    name: 'VOLUME STARTER',
    description: 'Lifted over 10,000 KG in total volume!',
    icon: Icons.line_weight,
    conditionCheckerMessage: (UserProfile profile) =>
        "Needs total volume tracking in profile.",
  ),
  AchievementId.level5Reached: Achievement(
      id: AchievementId.level5Reached,
      name: 'LEVEL 5 REACHED',
      description: 'Congratulations on reaching level 5!',
      icon: Icons.star_border_purple500_outlined,
      conditionCheckerMessage: (UserProfile profile) {
        if (profile.level >= 5) return null;
        return 'Current level: ${profile.level}/5.';
      }),
  AchievementId.personalRecordSet: const Achievement( // <-- NEW ACHIEVEMENT
    id: AchievementId.personalRecordSet,
    name: 'NEW RECORD: [Detail]!', // Placeholder for exercise name
    description: 'Congratulations on setting a new personal record for [Detail]!', // Placeholder
    icon: Icons.military_tech, // Or Icons.workspace_premium or Icons.verified
    isPersonalized: true,
  ),
};