// lib/core/domain/entities/achievement.dart
import 'package:muscle_up/l10n/app_localizations.dart';
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

typedef ConditionChecker = String? Function(UserProfile userProfile, AppLocalizations loc);

class Achievement {
  final AchievementId id;
  final String emblemAssetPath;
  final ConditionChecker? conditionCheckerMessage;
  final bool isPersonalized;

  const Achievement({
    required this.id,
    required this.emblemAssetPath,
    this.conditionCheckerMessage,
    this.isPersonalized = false,
  });

  String getLocalizedName(AppLocalizations loc, {String? detail}) {
    String name;
    switch (id) {
      case AchievementId.earlyBird: name = loc.achievementEarlyBirdName; break;
      case AchievementId.firstWorkout: name = loc.achievementFirstWorkoutName; break;
      case AchievementId.consistentKing10: name = loc.achievementConsistentKing10Name; break;
      case AchievementId.consistentKing30: name = loc.achievementConsistentKing30Name; break;
      case AchievementId.volumeStarter: name = loc.achievementVolumeStarterName; break;
      case AchievementId.volumePro: name = loc.achievementVolumeProName; break;
      case AchievementId.level5Reached: name = loc.achievementLevel5ReachedName; break;
      case AchievementId.level10Reached: name = loc.achievementLevel10ReachedName; break;
      case AchievementId.personalRecordSet:
        return loc.achievementPersonalRecordSetName(detail ?? loc.recordStatusVerified);
    }
    return name;
  }

  String getLocalizedDescription(AppLocalizations loc, {String? detail}) {
    String description;
    switch (id) {
      case AchievementId.earlyBird: description = loc.achievementEarlyBirdDescription; break;
      case AchievementId.firstWorkout: description = loc.achievementFirstWorkoutDescription; break;
      case AchievementId.consistentKing10: description = loc.achievementConsistentKing10Description; break;
      case AchievementId.consistentKing30: description = loc.achievementConsistentKing30Description; break;
      case AchievementId.volumeStarter: description = loc.achievementVolumeStarterDescription; break;
      case AchievementId.volumePro: description = loc.achievementVolumeProDescription; break;
      case AchievementId.level5Reached: description = loc.achievementLevel5ReachedDescription; break;
      case AchievementId.level10Reached: description = loc.achievementLevel10ReachedDescription; break;
      case AchievementId.personalRecordSet:
        return loc.achievementPersonalRecordSetDescription(detail ?? loc.recordStatusVerified);
    }
    return description;
  }
}

final Map<AchievementId, Achievement> allAchievements = {
  AchievementId.earlyBird: const Achievement(
    id: AchievementId.earlyBird,
    emblemAssetPath: 'assets/images/achievements/early_bird.png',
  ),
  AchievementId.firstWorkout: const Achievement(
    id: AchievementId.firstWorkout,
    emblemAssetPath: 'assets/images/achievements/first_workout.png',
  ),
  AchievementId.consistentKing10: Achievement(
      id: AchievementId.consistentKing10,
      emblemAssetPath: 'assets/images/achievements/streak_star_10.png',
      conditionCheckerMessage: (UserProfile profile, AppLocalizations loc) {
        if (profile.longestStreak >= 10) return null;
        return loc.achievementConditionStreak(profile.longestStreak, 10);
      }),
  AchievementId.consistentKing30: Achievement(
      id: AchievementId.consistentKing30,
      emblemAssetPath: 'assets/images/achievements/consistent_king_30.png',
      conditionCheckerMessage: (UserProfile profile, AppLocalizations loc) {
        if (profile.longestStreak >= 30) return null;
        return loc.achievementConditionStreak(profile.longestStreak, 30);
      }),
  AchievementId.volumeStarter: Achievement(
    id: AchievementId.volumeStarter,
    emblemAssetPath: 'assets/images/achievements/volume_starter.png',
    conditionCheckerMessage: (UserProfile profile, AppLocalizations loc) => loc.achievementConditionVolume,
  ),
  AchievementId.level5Reached: Achievement(
      id: AchievementId.level5Reached,
      emblemAssetPath: 'assets/images/achievements/level_5.png',
      conditionCheckerMessage: (UserProfile profile, AppLocalizations loc) {
        if (profile.level >= 5) return null;
        return loc.achievementConditionLevel(profile.level, 5);
      }),
  AchievementId.personalRecordSet: const Achievement(
    id: AchievementId.personalRecordSet,
    emblemAssetPath: 'assets/images/achievements/personal_record.png',
    isPersonalized: true,
  ),
  AchievementId.level10Reached: Achievement(
      id: AchievementId.level10Reached,
      emblemAssetPath: 'assets/images/achievements/level_10.png',
      conditionCheckerMessage: (UserProfile profile, AppLocalizations loc) {
        if (profile.level >= 10) return null;
        return loc.achievementConditionLevel(profile.level, 10);
      }),
  AchievementId.volumePro: Achievement(
    id: AchievementId.volumePro,
    emblemAssetPath: 'assets/images/achievements/volume_pro.png',
    conditionCheckerMessage: (UserProfile profile, AppLocalizations loc) => loc.achievementConditionVolume,
  ),
};