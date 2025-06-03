// FILE: functions/src/index.ts
// functions/src/index.ts

import * as functionsV1 from "firebase-functions/v1";
import { logger } from "firebase-functions";
import {
  onDocumentWritten,
  onDocumentUpdated,
  onDocumentCreated, // <-- Новий імпорт
  onDocumentDeleted, // <-- Новий імпорт
  Change,
  FirestoreEvent,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { DocumentSnapshot, Timestamp } from "firebase-admin/firestore";

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

const getUTCDayOfWeek = (date: Date): number => {
    return date.getUTCDay();
};
const getDayKeyFromJsDate = (date: Date): string => {
    const days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    return days[getUTCDayOfWeek(date)];
};

const getUTCDayStart = (jsDate: Date): Date => {
    return new Date(Date.UTC(jsDate.getUTCFullYear(), jsDate.getUTCMonth(), jsDate.getUTCDate()));
};

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
      uid: user.uid,
      email: user.email?.toLowerCase() ?? null,
      displayName: null,
      profilePictureUrl: user.photoURL ?? null,
      username: null,
      gender: null,
      dateOfBirth: null,
      heightCm: null,
      weightKg: null,
      fitnessGoal: null,
      activityLevel: null,
      xp: 0,
      level: 1,
      currentStreak: 0,
      longestStreak: 0,
      lastWorkoutTimestamp: null,
      lastScheduledWorkoutCompletionTimestamp: null,
      lastScheduledWorkoutDayKey: null,
      followersCount: 0,
      followingCount: 0,
      achievedRewardIds: [],
      profileSetupComplete: false,
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
      logger.warn("Doc data missing in onUpdated for workout log.", {userId, sessionId});
      return;
    }
    const oldWorkoutData = event.data.before.data()!;
    const newWorkoutData = event.data.after.data()!;

    const justCompleted = oldWorkoutData.status !== "completed" && newWorkoutData.status === "completed";
    if (!justCompleted) return;

    logger.info("Workout completed. Calculating XP, streak, awards.", {userId, sessionId});

    const durationSeconds = newWorkoutData.durationSeconds || 0;
    const totalVolume = newWorkoutData.totalVolume || 0;
    const completedAt = (newWorkoutData.endedAt instanceof Timestamp) ? newWorkoutData.endedAt : Timestamp.now();
    const startedAtTimestamp = (newWorkoutData.startedAt instanceof Timestamp) ? newWorkoutData.startedAt : Timestamp.now();

    let xpGained = 50;
    if (totalVolume > 0) xpGained += Math.round(totalVolume / 100);
    if (durationSeconds > 0) xpGained += Math.round(durationSeconds / (5 * 60));
    xpGained = Math.min(xpGained, 200);

    const userProfileRef = admin.firestore().collection("users").doc(userId);
    const userRoutinesRef = admin.firestore().collection("userRoutines").where("userId", "==", userId);

    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const profileDoc = await transaction.get(userProfileRef);
        const routinesSnapshot = await transaction.get(userRoutinesRef);

        if (!profileDoc.exists) {
            logger.error("User profile not found in transaction.", {userId});
            throw new Error(`User profile ${userId} not found.`);
        }
        const currentProfile = profileDoc.data()!;

        const newXp = (currentProfile.xp || 0) + xpGained;
        let calculatedNewLevel = currentProfile.level || 1;

        let currentStreak = currentProfile.currentStreak || 0;
        let longestStreak = currentProfile.longestStreak || 0;
        let newLastScheduledWorkoutCompletionTimestamp = currentProfile.lastScheduledWorkoutCompletionTimestamp as Timestamp | undefined;
        let newLastScheduledWorkoutDayKey = currentProfile.lastScheduledWorkoutDayKey as string | undefined;

        const routineIdOfCompletedWorkout = newWorkoutData.routineId as string | undefined;
        let workoutRoutineDoc: DocumentSnapshot | undefined;
        if (routineIdOfCompletedWorkout) {
            workoutRoutineDoc = routinesSnapshot.docs.find((doc) => doc.id === routineIdOfCompletedWorkout);
        }

        const currentWorkoutDayKey = getDayKeyFromJsDate(startedAtTimestamp.toDate());
        const currentWorkoutDayStartUTC = getUTCDayStart(startedAtTimestamp.toDate());

        if (workoutRoutineDoc && workoutRoutineDoc.exists) {
            const routineData = workoutRoutineDoc.data();
            const scheduledDays = (routineData?.scheduledDays as string[] | undefined)?.map((d) => d.toUpperCase()) ?? [];

            if (scheduledDays.length > 0 && scheduledDays.includes(currentWorkoutDayKey)) {
                logger.info("Streak V3: Workout is on a scheduled day.", {userId, currentWorkoutDayKey, routineId: routineIdOfCompletedWorkout});

                if (currentProfile.lastScheduledWorkoutCompletionTimestamp && currentProfile.lastScheduledWorkoutDayKey) {
                    const lastScheduledCompletionJsDate = (currentProfile.lastScheduledWorkoutCompletionTimestamp as Timestamp).toDate();
                    const lastScheduledCompletionDayStartUTC = getUTCDayStart(lastScheduledCompletionJsDate);

                    if (currentWorkoutDayStartUTC.getTime() === lastScheduledCompletionDayStartUTC.getTime() && currentProfile.lastScheduledWorkoutDayKey === currentWorkoutDayKey) {
                       logger.info("Streak V3: Workout on the same scheduled day as last. Streak not incremented.", {userId});
                    } else {
                        let wasPreviousScheduledDayMissed = false;
                        let tempDate = new Date(lastScheduledCompletionDayStartUTC);
                        tempDate.setUTCDate(tempDate.getUTCDate() + 1);

                        while(tempDate.getTime() < currentWorkoutDayStartUTC.getTime()) {
                            const dayKeyToTest = getDayKeyFromJsDate(tempDate);
                            if (scheduledDays.includes(dayKeyToTest)) {
                                wasPreviousScheduledDayMissed = true;
                                logger.info("Streak V3: Missed scheduled day detected.", { userId, missedDay: tempDate.toISOString(), dayKey: dayKeyToTest });
                                break;
                            }
                            tempDate.setUTCDate(tempDate.getUTCDate() + 1);
                        }

                        if (wasPreviousScheduledDayMissed) {
                            currentStreak = 1;
                            logger.info("Streak V3: Previous scheduled day was missed. Streak reset to 1.", {userId});
                        } else {
                            currentStreak++;
                            logger.info("Streak V3: No missed scheduled days. Streak incremented.", {userId, newStreak: currentStreak});
                        }
                        newLastScheduledWorkoutCompletionTimestamp = completedAt;
                        newLastScheduledWorkoutDayKey = currentWorkoutDayKey;
                    }
                } else {
                    currentStreak = 1;
                    newLastScheduledWorkoutCompletionTimestamp = completedAt;
                    newLastScheduledWorkoutDayKey = currentWorkoutDayKey;
                    logger.info("Streak V3: First ever scheduled workout. Streak set to 1.", {userId});
                }
            } else {
              logger.info("Streak V3: Workout was from a routine, but not on a scheduled day of that routine (or routine has no schedule). Streak not affected by this logic.", {userId, currentWorkoutDayKey, routineScheduledDays: scheduledDays });
            }
        } else {
          logger.info("Streak V3: Workout was not from a routine with schedule. Streak not affected by this logic.", {userId});
        }

        longestStreak = Math.max(longestStreak, currentStreak);

        const xpPerLevelBase = 200;
        const calculateXpForNextLevelUp = (currentLevel: number): number => {
            return xpPerLevelBase + (currentLevel - 1) * 50;
        };

        let xpNeededForCurrentLevelToComplete = calculateXpForNextLevelUp(calculatedNewLevel);
        let totalXpAtStartOfCurrentLevel = 0;
        for (let i = 1; i < calculatedNewLevel; i++) {
            totalXpAtStartOfCurrentLevel += calculateXpForNextLevelUp(i);
        }

        while (newXp >= totalXpAtStartOfCurrentLevel + xpNeededForCurrentLevelToComplete) {
            totalXpAtStartOfCurrentLevel += xpNeededForCurrentLevelToComplete;
            calculatedNewLevel++;
            xpNeededForCurrentLevelToComplete = calculateXpForNextLevelUp(calculatedNewLevel);
        }

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

        const profileUpdateData: {[key: string]: any} = {
          xp: newXp,
          level: calculatedNewLevel,
          currentStreak,
          longestStreak,
          lastWorkoutTimestamp: completedAt,
          achievedRewardIds,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        };

        if (newLastScheduledWorkoutCompletionTimestamp) {
            profileUpdateData.lastScheduledWorkoutCompletionTimestamp = newLastScheduledWorkoutCompletionTimestamp;
        }
        if (newLastScheduledWorkoutDayKey) {
            profileUpdateData.lastScheduledWorkoutDayKey = newLastScheduledWorkoutDayKey;
        }

        logger.info("Preparing to update profile in transaction", { userId, updatesToApply: profileUpdateData });
        transaction.update(userProfileRef, profileUpdateData);
        logger.info("User profile updated.", { userId, updatedXp: newXp, updatedLevel: calculatedNewLevel, updatedCurrentStreak: currentStreak });
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

// --- Нові Cloud Functions для лічильника коментарів ---

export const onCommentCreated = onDocumentCreated(
  { document: "posts/{postId}/comments/{commentId}", region: defaultRegion },
  async (event: FirestoreEvent<DocumentSnapshot | undefined, { postId: string; commentId: string }>) => {
    const { postId, commentId } = event.params;
    const commentData = event.data?.data();

    if (!commentData) {
      logger.warn("Comment data missing in onCommentCreated.", {postId, commentId});
      return;
    }
    logger.info(`New comment ${commentId} created for post ${postId}. Incrementing count.`);

    const postRef = admin.firestore().collection("posts").doc(postId);
    try {
      await postRef.update({
        commentsCount: admin.firestore.FieldValue.increment(1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(), // Також оновлюємо updatedAt поста
      });
      logger.info(`Successfully incremented commentsCount for post ${postId}.`);
    } catch (error: any) {
      logger.error(`Error incrementing commentsCount for post ${postId}: ${error.message || error}`, {postId, commentId});
    }
  }
);

export const onCommentDeleted = onDocumentDeleted(
  { document: "posts/{postId}/comments/{commentId}", region: defaultRegion },
  async (event: FirestoreEvent<DocumentSnapshot | undefined, { postId: string; commentId: string }>) => {
    const { postId, commentId } = event.params;

    logger.info(`Comment ${commentId} deleted for post ${postId}. Decrementing count.`);

    const postRef = admin.firestore().collection("posts").doc(postId);
    try {
      await postRef.update({
        commentsCount: admin.firestore.FieldValue.increment(-1),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(), // Також оновлюємо updatedAt поста
      });
      logger.info(`Successfully decremented commentsCount for post ${postId}.`);
    } catch (error: any) {
      logger.error(`Error decrementing commentsCount for post ${postId}: ${error.message || error}`, {postId, commentId});
    }
  }
);