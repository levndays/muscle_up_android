// functions/src/index.ts

import * as functionsV1 from "firebase-functions/v1";
import { logger } from "firebase-functions";
import {
  onDocumentWritten,
  onDocumentUpdated,
  Change,
  FirestoreEvent,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { DocumentSnapshot } from "firebase-admin/firestore";

try {
  admin.initializeApp();
} catch (e) {
  logger.info("Admin app already initialized or error during init:", e);
}

enum AchievementId {
  EARLY_BIRD = "earlyBird",
  FIRST_WORKOUT = "firstWorkout",
}

const defaultRegion = "us-central1";

export const createUserProfile = functionsV1.region(defaultRegion).auth.user().onCreate(async (user) => {
  logger.info("V1 Auth trigger: New user created.", {uid: user.uid, email: user.email});
  const userDocRef = admin.firestore().collection("users").doc(user.uid);
  try {
    const docSnapshot = await userDocRef.get();
    if (docSnapshot.exists) {
      logger.warn(`V1 User profile for ${user.uid} already exists. Skipping creation.`);
      return null;
    }
    await userDocRef.set({
      uid: user.uid, email: user.email?.toLowerCase() ?? null, displayName: user.displayName ?? null,
      profilePictureUrl: user.photoURL ?? null, username: null, gender: null, dateOfBirth: null,
      heightCm: null, weightKg: null, fitnessGoal: null, activityLevel: null, xp: 0, level: 1,
      currentStreak: 0, longestStreak: 0, lastWorkoutTimestamp: null, followersCount: 0,
      followingCount: 0, achievedRewardIds: [], profileSetupComplete: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    logger.info("V1 User profile successfully created.", {uid: user.uid});
    return null;
  } catch (error: any) {
    logger.error("V1 Error creating user profile.", {uid: user.uid, error: error.message || error});
    return null;
  }
});

export const calculateAndAwardXpAndStreak = onDocumentUpdated(
  { document: "users/{userId}/workoutLogs/{sessionId}", region: defaultRegion },
  async (event: FirestoreEvent<Change<DocumentSnapshot> | undefined, { userId: string; sessionId: string }>) => {
    const { userId, sessionId } = event.params;

    if (!event.data?.before?.exists || !event.data?.after?.exists) {
      logger.warn("Document data missing in onUpdated event for workout log.", {userId, sessionId});
      return;
    }
    const oldWorkoutData = event.data.before.data()!;
    const newWorkoutData = event.data.after.data()!;

    const justCompleted = oldWorkoutData.status !== "completed" && newWorkoutData.status === "completed";
    if (!justCompleted) {
        return;
    }

    logger.info("Workout completed. Calculating XP, streak, awards.", {userId, sessionId});

    const durationSeconds = newWorkoutData.durationSeconds || 0;
    const totalVolume = newWorkoutData.totalVolume || 0;
    const completedAt = (newWorkoutData.endedAt instanceof admin.firestore.Timestamp) ? newWorkoutData.endedAt : admin.firestore.FieldValue.serverTimestamp();
    let xpGained = 50;
    if (totalVolume > 0) xpGained += Math.round(totalVolume / 100);
    if (durationSeconds > 0) xpGained += Math.round(durationSeconds / (5 * 60)); // Кожні 5 хвилин
    xpGained = Math.min(xpGained, 200); // Максимум 200 XP за тренування

    const userProfileRef = admin.firestore().collection("users").doc(userId);
    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const profileDoc = await transaction.get(userProfileRef);
        if (!profileDoc.exists) {
            logger.error("User profile not found in transaction.", {userId});
            throw new Error(`User profile ${userId} not found.`);
        }
        const currentProfile = profileDoc.data()!;
        logger.info("Current profile data fetched in transaction", { // <--- ДОДАНО ЛОГ
            userId,
            currentXP: currentProfile.xp,
            currentLevel: currentProfile.level,
        });


        const newXp = (currentProfile.xp || 0) + xpGained;
        let calculatedNewLevel = currentProfile.level || 1; // Починаємо з поточного рівня
        let currentStreak = currentProfile.currentStreak || 0;
        let longestStreak = currentProfile.longestStreak || 0;
        const lastWorkoutTimestamp = currentProfile.lastWorkoutTimestamp as admin.firestore.Timestamp | undefined;
        const currentWorkoutDate = (newWorkoutData.startedAt as admin.firestore.Timestamp).toDate();
        const lastWorkoutDate = lastWorkoutTimestamp ? lastWorkoutTimestamp.toDate() : new Date(0);

        const isSameDay = lastWorkoutDate.getFullYear() === currentWorkoutDate.getFullYear() &&
                          lastWorkoutDate.getMonth() === currentWorkoutDate.getMonth() &&
                          lastWorkoutDate.getDate() === currentWorkoutDate.getDate();

        if (!isSameDay) {
          const nextDayAfterLast = new Date(lastWorkoutDate);
          nextDayAfterLast.setDate(lastWorkoutDate.getDate() + 1);
          const isConsecutive = nextDayAfterLast.getFullYear() === currentWorkoutDate.getFullYear() &&
                                nextDayAfterLast.getMonth() === currentWorkoutDate.getMonth() &&
                                nextDayAfterLast.getDate() === currentWorkoutDate.getDate();
          currentStreak = isConsecutive ? currentStreak + 1 : 1;
        }
        longestStreak = Math.max(longestStreak, currentStreak);

        // --- ВИПРАВЛЕНА ЛОГІКА РОЗРАХУНКУ РІВНЯ ---
        const xpPerLevelBase = 200;
        const calculateXpForNextLevelUp = (currentLevel: number): number => {
            return xpPerLevelBase + (currentLevel - 1) * 50;
        };
        
        let xpNeededForCurrentLevelToComplete = calculateXpForNextLevelUp(calculatedNewLevel);
        let totalXpAtStartOfCurrentLevel = 0;
        for (let i = 1; i < calculatedNewLevel; i++) {
            totalXpAtStartOfCurrentLevel += calculateXpForNextLevelUp(i);
        }
        
        logger.info("Level Calc Start:", {
          userId,
          currentXpInDb: currentProfile.xp, // XP до нарахування за це тренування
          currentLevelInDb: currentProfile.level,
          xpGainedThisWorkout: xpGained,
          newTotalXpAfterThisWorkout: newXp, // Загальне XP ПІСЛЯ нарахування
          initialCalculatedLevelForLoop: calculatedNewLevel, // Рівень, з якого починаємо перевірку
          xpNeededForCurrentLevelToCompleteInitial: xpNeededForCurrentLevelToComplete,
          totalXpAtStartOfCurrentLevelInitial: totalXpAtStartOfCurrentLevel,
        });

        // Цикл для підвищення рівня, поки XP вистачає
        while (newXp >= totalXpAtStartOfCurrentLevel + xpNeededForCurrentLevelToComplete) {
            totalXpAtStartOfCurrentLevel += xpNeededForCurrentLevelToComplete; // Додаємо XP поточного рівня до бази для наступного
            calculatedNewLevel++; // Підвищуємо рівень
            xpNeededForCurrentLevelToComplete = calculateXpForNextLevelUp(calculatedNewLevel); // Розраховуємо XP для нового поточного рівня
            logger.info("Level Up! Iteration details:", { // <--- Оновлений лог
                userId,
                nowCalculatedLevel: calculatedNewLevel,
                xpNeededForThisNewLevel: xpNeededForCurrentLevelToComplete,
                newTotalXpAtStartOfThisNewLevel: totalXpAtStartOfCurrentLevel,
                currentTotalXpOfUser: newXp,
            });
        }
        // --- КІНЕЦЬ ВИПРАВЛЕНОЇ ЛОГІКИ ---

        const achievedRewardIds: string[] = currentProfile.achievedRewardIds ? [...(currentProfile.achievedRewardIds as string[])] : [];
        if (!achievedRewardIds.includes(AchievementId.FIRST_WORKOUT)) {
          achievedRewardIds.push(AchievementId.FIRST_WORKOUT);
          logger.info("Achievement earned: FIRST_WORKOUT", {userId});
          const notificationsRef = userProfileRef.collection("notifications");
          await notificationsRef.add({
            type: "achievementUnlocked", title: "First Workout Completed!",
            message: "You've successfully completed your first workout. Great start!",
            timestamp: admin.firestore.FieldValue.serverTimestamp(), isRead: false, iconName: "fitness_center",
            relatedEntityId: AchievementId.FIRST_WORKOUT, relatedEntityType: "achievement",
          });
        }
        
        // <--- ДОДАНО ЛОГ ПЕРЕД ОНОВЛЕННЯМ ---
        logger.info("Preparing to update profile in transaction", {
          userId,
          updatesToApply: {
            xp: newXp,
            level: calculatedNewLevel,
            currentStreak,
            longestStreak,
            lastWorkoutTimestamp: completedAt,
            achievedRewardIds,
            // updatedAt: "FieldValue.serverTimestamp()" // це буде встановлено автоматично
          }
        });
        // <--- КІНЕЦЬ ДОДАНОГО ЛОГУ ---

        transaction.update(userProfileRef, {
          xp: newXp,
          level: calculatedNewLevel, // <--- Використовуємо розрахований рівень
          currentStreak,
          longestStreak,
          lastWorkoutTimestamp: completedAt,
          achievedRewardIds,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        logger.info("User profile updated with XP, level, streak, rewards.", {
            userId,
            updatedXp: newXp,
            updatedLevel: calculatedNewLevel, // <--- Логуємо оновлений рівень
        });
      });
    } catch (error: any) {
      logger.error("Error updating user profile after workout.", {userId, sessionId, error: error.message || error});
    }
  }
);

export const checkProfileSetupCompletionAchievements = onDocumentWritten(
  { document: "users/{userId}", region: defaultRegion },
  async (event: FirestoreEvent<Change<DocumentSnapshot> | undefined, { userId: string }>) => {
    const { userId } = event.params;
    const change = event.data;
    if (!change) return;

    const dataAfter = change.after.exists ? change.after.data() : undefined;
    const dataBefore = change.before.exists ? change.before.data() : undefined;

    if (dataAfter) {
      const profileSetupCompleteAfter = dataAfter.profileSetupComplete === true;
      const profileSetupCompleteBefore = dataBefore?.profileSetupComplete === true;

      if (profileSetupCompleteAfter && !profileSetupCompleteBefore) {
        logger.info("Profile setup completed. Checking EarlyBird.", {userId});
        const userProfileRef = admin.firestore().collection("users").doc(userId);
        const achievedRewardIds: string[] = dataAfter.achievedRewardIds ? [...(dataAfter.achievedRewardIds as string[])] : [];

        if (!achievedRewardIds.includes(AchievementId.EARLY_BIRD)) {
          achievedRewardIds.push(AchievementId.EARLY_BIRD);
          await userProfileRef.update({
            achievedRewardIds,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          logger.info("Achievement earned: EARLY_BIRD", {userId});
          const notificationsRef = userProfileRef.collection("notifications");
          await notificationsRef.add({
              type: "achievementUnlocked", title: "Profile Setup Complete!",
              message: "You've successfully set up your profile. Welcome aboard!",
              timestamp: admin.firestore.FieldValue.serverTimestamp(), isRead: false, iconName: "auto_awesome",
              relatedEntityId: AchievementId.EARLY_BIRD, relatedEntityType: "achievement",
          });
        }
      }
    }
  }
);