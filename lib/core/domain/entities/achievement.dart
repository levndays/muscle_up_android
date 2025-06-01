// lib/core/domain/entities/achievement.dart
import 'package:flutter/material.dart'; // Для IconData
import 'user_profile.dart'; // <--- ПОТРІБНО ІМПОРТУВАТИ UserProfile

// Унікальні ідентифікатори для кожної нагороди
enum AchievementId {
  earlyBird, // За першу реєстрацію/завершення профілю
  firstWorkout, // За перше завершене тренування
  consistentKing10, // За 10 днів стріку
  consistentKing30, // За 30 днів стріку
  volumeStarter, // За досягнення певного об'єму (напр. 1000 кг)
  volumePro, // За досягнення більшого об'єму (напр. 10000 кг)
  level5Reached,
  level10Reached,
  // Додайте інші ID нагород тут
}

// Тип для функції-перевірки умови
typedef ConditionChecker = String? Function(UserProfile userProfile);

class Achievement {
  final AchievementId id;
  final String name;
  final String description;
  final IconData icon;
  final ConditionChecker? conditionCheckerMessage; // Використовуємо typedef

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.conditionCheckerMessage,
  });
}

// Словник усіх можливих нагород в додатку
// Це дозволяє централізовано керувати описом нагород
// Зверніть увагу: поля тут мають бути final, якщо клас Achievement має const конструктор.
// Або конструктор Achievement не має бути const. Оскільки ми використовуємо const Achievement,
// то allAchievements також має бути final, а не просто змінною.
// Або, якщо allAchievements має змінюватися (малоймовірно), тоді Achievement не має бути const.
// Для поточного використання, робимо allAchievements final.
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
    conditionCheckerMessage: (UserProfile profile) { // Явно вказуємо тип параметра
      if (profile.longestStreak >= 10) return null;
      return 'Current best streak: ${profile.longestStreak}/10 days.';
    }
  ),
  AchievementId.consistentKing30: Achievement(
    id: AchievementId.consistentKing30,
    name: 'CONSISTENT KING (30)',
    description: '30-day workout streak! Unstoppable!',
    icon: Icons.whatshot,
     conditionCheckerMessage: (UserProfile profile) { // Явно вказуємо тип параметра
      if (profile.longestStreak >= 30) return null;
      return 'Current best streak: ${profile.longestStreak}/30 days.';
    }
  ),
  AchievementId.volumeStarter: Achievement(
    id: AchievementId.volumeStarter,
    name: 'VOLUME STARTER',
    description: 'Lifted over 10,000 KG in total volume!',
    icon: Icons.line_weight,
    conditionCheckerMessage: (UserProfile profile) => "Needs total volume tracking in profile.",
  ),
  AchievementId.level5Reached: Achievement(
    id: AchievementId.level5Reached,
    name: 'LEVEL 5 REACHED',
    description: 'Congratulations on reaching level 5!',
    icon: Icons.star_border_purple500_outlined,
    conditionCheckerMessage: (UserProfile profile) { // Явно вказуємо тип параметра
      if (profile.level >= 5) return null;
      return 'Current level: ${profile.level}/5.';
    }
  ),
};