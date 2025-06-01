// functions/src/index.ts

import * as functionsV1 from "firebase-functions/v1"; // Перейменовано для чіткості, використовується для v1 тригерів
import { logger } from "firebase-functions"; // Уніфікований логер для v1 та v2
import {
  HttpsOptions,
  onRequest,
  Request as ExpressRequest,
} from "firebase-functions/v2/https"; // V2 для HTTPS
import {
  onDocumentWritten,
  onDocumentUpdated,
  Change,
  FirestoreEvent,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { DocumentSnapshot } from "firebase-admin/firestore";
import { Response as ExpressResponse } from "express";

try {
  admin.initializeApp();
} catch (e) {
  logger.info("Admin app already initialized or error during init:", e);
}

enum AchievementId {
  EARLY_BIRD = "earlyBird",
  FIRST_WORKOUT = "firstWorkout",
}

const predefinedExercisesData = [
  {
    name: "Bench Press", normalizedName: "bench press", primaryMuscleGroup: "Chest", secondaryMuscleGroups: ["Shoulders", "Triceps"], equipmentNeeded: ["Barbell", "Bench"],
    description: "A compound exercise that targets the chest, shoulders, and triceps...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=rT7DgCr-3pg", difficultyLevel: "Intermediate", tags: ["compound", "strength", "barbell", "upper body"],
  },
  {
    name: "Squat", normalizedName: "squat", primaryMuscleGroup: "Quadriceps", secondaryMuscleGroups: ["Glutes", "Hamstrings", "Calves", "Core"], equipmentNeeded: ["Barbell", "Squat Rack"],
    description: "A fundamental compound exercise targeting the quads, glutes, and hamstrings...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=ultWZbUMPL8", difficultyLevel: "Intermediate", tags: ["compound", "strength", "barbell", "legs", "full body"],
  },
  {
    name: "Deadlift", normalizedName: "deadlift", primaryMuscleGroup: "Back", secondaryMuscleGroups: ["Glutes", "Hamstrings", "Forearms", "Core"], equipmentNeeded: ["Barbell"],
    description: "A powerful compound exercise working multiple muscle groups...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=ytGaGIn3SjE", difficultyLevel: "Advanced", tags: ["compound", "strength", "barbell", "full body", "posterior chain"],
  },
  {
    name: "Overhead Press", normalizedName: "overhead press", primaryMuscleGroup: "Shoulders", secondaryMuscleGroups: ["Triceps", "Traps", "Core"], equipmentNeeded: ["Barbell", "Dumbbells"],
    description: "Also known as military press. Press a weight overhead...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=2yjwXTZQDDI", difficultyLevel: "Intermediate", tags: ["compound", "strength", "shoulders"],
  },
  {
    name: "Pull Up", normalizedName: "pull up", primaryMuscleGroup: "Back", secondaryMuscleGroups: ["Biceps", "Forearms"], equipmentNeeded: ["Pull-up Bar"],
    description: "A bodyweight exercise that targets the latissimus dorsi (lats)...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=eGo4IYlbE5g", difficultyLevel: "Intermediate", tags: ["compound", "bodyweight", "back"],
  },
  {
    name: "Dumbbell Row", normalizedName: "dumbbell row", primaryMuscleGroup: "Back", secondaryMuscleGroups: ["Biceps", "Shoulders"], equipmentNeeded: ["Dumbbell", "Bench"],
    description: "A unilateral exercise for back thickness...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=pYcpY20QaE8", difficultyLevel: "Beginner", tags: ["compound", "dumbbell", "back"],
  },
  {
    name: "Bicep Curl", normalizedName: "bicep curl", primaryMuscleGroup: "Biceps", secondaryMuscleGroups: ["Forearms"], equipmentNeeded: ["Dumbbells", "Barbell"],
    description: "An isolation exercise for the biceps...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=ykJmrZ5v0Oo", difficultyLevel: "Beginner", tags: ["isolation", "arms", "biceps"],
  },
  {
    name: "Tricep Pushdown", normalizedName: "tricep pushdown", primaryMuscleGroup: "Triceps", secondaryMuscleGroups: [], equipmentNeeded: ["Cable Machine"],
    description: "An isolation exercise for the triceps...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=2-LAMcpzODU", difficultyLevel: "Beginner", tags: ["isolation", "arms", "triceps"],
  },
  {
    name: "Leg Press", normalizedName: "leg press", primaryMuscleGroup: "Quadriceps", secondaryMuscleGroups: ["Glutes", "Hamstrings"], equipmentNeeded: ["Leg Press Machine"],
    description: "A machine-based compound exercise for the legs...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=IZxyjW7MPJQ", difficultyLevel: "Beginner", tags: ["compound", "machine", "legs"],
  },
  {
    name: "Calf Raise", normalizedName: "calf raise", primaryMuscleGroup: "Calves", secondaryMuscleGroups: [], equipmentNeeded: ["Bodyweight", "Dumbbells"],
    description: "An isolation exercise for the calf muscles...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=JbyjNymZOt0", difficultyLevel: "Beginner", tags: ["isolation", "legs", "calves"],
  },
  {
    name: "Plank", normalizedName: "plank", primaryMuscleGroup: "Core", secondaryMuscleGroups: ["Shoulders"], equipmentNeeded: ["Bodyweight"],
    description: "An isometric core strength exercise...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=ASdvN_XEl_c", difficultyLevel: "Beginner", tags: ["core", "isometric", "bodyweight"],
  },
  {
    name: "Russian Twist", normalizedName: "russian twist", primaryMuscleGroup: "Core", secondaryMuscleGroups: ["Abs"], equipmentNeeded: ["Bodyweight", "Weight Plate"],
    description: "A core exercise that targets the obliques...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=wkD8rjkodUI", difficultyLevel: "Beginner", tags: ["core", "obliques"],
  },
  {
    name: "Lateral Raise", normalizedName: "lateral raise", primaryMuscleGroup: "Shoulders", secondaryMuscleGroups: ["Traps"], equipmentNeeded: ["Dumbbells"],
    description: "An isolation exercise for the side deltoids...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=3VcKaXpzqRo", difficultyLevel: "Beginner", tags: ["isolation", "shoulders", "dumbbells"],
  },
  {
    name: "Front Squat", normalizedName: "front squat", primaryMuscleGroup: "Quadriceps", secondaryMuscleGroups: ["Glutes", "Core", "Upper Back"], equipmentNeeded: ["Barbell"],
    description: "A squat variation where the barbell is held across the front...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=m4ytaCJZpl0", difficultyLevel: "Advanced", tags: ["compound", "legs", "core", "barbell"],
  },
  {
    name: "Face Pull", normalizedName: "face pull", primaryMuscleGroup: "Shoulders", secondaryMuscleGroups: ["Traps", "Rhomboids"], equipmentNeeded: ["Cable Machine", "Resistance Band"],
    description: "An exercise for shoulder health and upper back development...", videoDemonstrationUrl: "https://www.youtube.com/watch?v=eIq5CB9wYoA", difficultyLevel: "Beginner", tags: ["accessory", "shoulder health", "cable"],
  },
];

const defaultRegion = "us-central1";

const httpsGlobalOptions: HttpsOptions = {
  timeoutSeconds: 540,
  memory: "1GiB",
  region: defaultRegion,
};

export const seedPredefinedExercises = onRequest(
  httpsGlobalOptions,
  async (request: ExpressRequest, response: ExpressResponse) => {
    // Використовуємо уніфікований логер
    logger.info("Attempting to seed predefined exercises...", {structuredData: true});

    if (request.method !== "GET" && request.method !== "POST") {
      response.status(405).send("Method Not Allowed");
      return;
    }

    const adminKey = process.env.APP_ADMIN_KEY || process.env.ADMIN_KEY;
    if (adminKey && request.query.key !== adminKey) {
       // Використовуємо уніфікований логер
       logger.warn("Unauthorized attempt to seed (key mismatch).", {providedKeyQuery: typeof request.query.key});
       response.status(401).send("Unauthorized: Invalid or missing key.");
       return;
    }
    if (!adminKey) {
      // Використовуємо уніфікований логер
      logger.warn("APP_ADMIN_KEY or ADMIN_KEY is not set in environment variables. Seeding is unprotected.");
    }

    const exercisesCollection = admin.firestore().collection("predefinedExercises");
    let addedCount = 0;
    let skippedCount = 0;
    const errors: string[] = [];
    let currentBatch = admin.firestore().batch();
    let batchSize = 0;
    const MAX_BATCH_SIZE = 450;

    for (const exerciseData of predefinedExercisesData) {
      try {
        const querySnapshot = await exercisesCollection.where("normalizedName", "==", exerciseData.normalizedName).limit(1).get();
        if (querySnapshot.empty) {
          const docRef = exercisesCollection.doc();
          const dataToSave = {
            ...exerciseData,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          };
          currentBatch.set(docRef, dataToSave);
          addedCount++;
          batchSize++;
          if (batchSize >= MAX_BATCH_SIZE) {
            await currentBatch.commit();
            // Використовуємо уніфікований логер
            logger.info(`Committed batch of ${batchSize} exercises.`);
            currentBatch = admin.firestore().batch();
            batchSize = 0;
          }
        } else {
          skippedCount++;
        }
      } catch (error: any) {
        const errorMessage = `Error processing exercise "${exerciseData.name}": ${error.message || error}`;
        // Використовуємо уніфікований логер
        logger.error(errorMessage, {errorData: error});
        errors.push(errorMessage);
      }
    }

    if (batchSize > 0) {
      try {
        await currentBatch.commit();
        // Використовуємо уніфікований логер
        logger.info(`Committed final batch of ${batchSize} exercises.`);
      } catch (error: any) {
         const errorMessage = `Error committing final batch: ${error.message || error}`;
         // Використовуємо уніфікований логер
         logger.error(errorMessage, {errorData: error});
         errors.push(errorMessage);
      }
    }

    if (errors.length > 0) {
        response.status(500).json({ message: "Completed with errors.", added: addedCount, skipped: skippedCount, errors: errors });
    } else {
        response.status(200).json({ message: "Seeding predefined exercises complete.", added: addedCount, skipped: skippedCount });
    }
  }
);

// Використовуємо functionsV1 для визначення тригера v1
export const createUserProfile = functionsV1.region(defaultRegion).auth.user().onCreate(async (user) => {
  // Використовуємо уніфікований логер
  logger.info("V1 Auth trigger: New user created.", {uid: user.uid, email: user.email});
  const userDocRef = admin.firestore().collection("users").doc(user.uid);
  try {
    const docSnapshot = await userDocRef.get();
    if (docSnapshot.exists) {
      // Використовуємо уніфікований логер
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
    // Використовуємо уніфікований логер
    logger.info("V1 User profile successfully created.", {uid: user.uid});
    return null;
  } catch (error: any) {
    // Використовуємо уніфікований логер
    logger.error("V1 Error creating user profile.", {uid: user.uid, error: error.message || error});
    return null;
  }
});

export const calculateAndAwardXpAndStreak = onDocumentUpdated(
  { document: "users/{userId}/workoutLogs/{sessionId}", region: defaultRegion },
  async (event: FirestoreEvent<Change<DocumentSnapshot> | undefined, { userId: string; sessionId: string }>) => {
    const { userId, sessionId } = event.params;

    if (!event.data?.before?.exists || !event.data?.after?.exists) {
      // Використовуємо уніфікований логер
      logger.warn("Document data missing in onUpdated event for workout log.", {userId, sessionId});
      return;
    }
    const oldWorkoutData = event.data.before.data()!;
    const newWorkoutData = event.data.after.data()!;

    const justCompleted = oldWorkoutData.status !== "completed" && newWorkoutData.status === "completed";
    if (!justCompleted) {
        // logger.info("Workout log updated, but not a completion event.", {userId, sessionId, newStatus: newWorkoutData.status });
        return;
    }

    // Використовуємо уніфікований логер
    logger.info("Workout completed. Calculating XP, streak, awards.", {userId, sessionId});

    const durationSeconds = newWorkoutData.durationSeconds || 0;
    const totalVolume = newWorkoutData.totalVolume || 0;
    const completedAt = (newWorkoutData.endedAt instanceof admin.firestore.Timestamp) ? newWorkoutData.endedAt : admin.firestore.FieldValue.serverTimestamp();
    let xpGained = 50;
    if (totalVolume > 0) xpGained += Math.round(totalVolume / 100);
    if (durationSeconds > 0) xpGained += Math.round(durationSeconds / (5 * 60));
    xpGained = Math.min(xpGained, 200);

    const userProfileRef = admin.firestore().collection("users").doc(userId);
    try {
      await admin.firestore().runTransaction(async (transaction) => {
        const profileDoc = await transaction.get(userProfileRef);
        if (!profileDoc.exists) {
            // Використовуємо уніфікований логер
            logger.error("User profile not found in transaction.", {userId});
            throw new Error(`User profile ${userId} not found.`);
        }
        const currentProfile = profileDoc.data()!;

        const newXp = (currentProfile.xp || 0) + xpGained;
        let newLevel = currentProfile.level || 1;
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

        const xpPerLevelBase = 200;
        const calculateTotalXpForLevelStart = (level: number): number => {
          if (level <= 1) return 0;
          let totalXpForPrevLevels = 0;
          for (let i = 1; i < level; i++) {
            totalXpForPrevLevels += (xpPerLevelBase + (i - 1) * 50);
          }
          return totalXpForPrevLevels;
        };
        let xpRequiredForNextLevel = xpPerLevelBase + (newLevel - 1) * 50;
        let totalXpAtLevelStart = calculateTotalXpForLevelStart(newLevel);
        while (newXp >= totalXpAtLevelStart + xpRequiredForNextLevel) {
          newLevel++;
          totalXpAtLevelStart = calculateTotalXpForLevelStart(newLevel);
          xpRequiredForNextLevel = xpPerLevelBase + (newLevel - 1) * 50;
        }

        const achievedRewardIds: string[] = currentProfile.achievedRewardIds ? [...(currentProfile.achievedRewardIds as string[])] : [];
        if (!achievedRewardIds.includes(AchievementId.FIRST_WORKOUT)) {
          achievedRewardIds.push(AchievementId.FIRST_WORKOUT);
          // Використовуємо уніфікований логер
          logger.info("Achievement earned: FIRST_WORKOUT", {userId});
          const notificationsRef = userProfileRef.collection("notifications");
          await notificationsRef.add({
            type: "achievementUnlocked", title: "First Workout Completed!",
            message: "You've successfully completed your first workout. Great start!",
            timestamp: admin.firestore.FieldValue.serverTimestamp(), isRead: false, iconName: "fitness_center",
            relatedEntityId: AchievementId.FIRST_WORKOUT, relatedEntityType: "achievement",
          });
        }

        transaction.update(userProfileRef, {
          xp: newXp, level: newLevel, currentStreak, longestStreak,
          lastWorkoutTimestamp: completedAt, achievedRewardIds,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // Використовуємо уніфікований логер
        logger.info("User profile updated with XP, level, streak, rewards.", {userId});
      });
    } catch (error: any) {
      // Використовуємо уніфікований логер
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
        // Використовуємо уніфікований логер
        logger.info("Profile setup completed. Checking EarlyBird.", {userId});
        const userProfileRef = admin.firestore().collection("users").doc(userId);
        const achievedRewardIds: string[] = dataAfter.achievedRewardIds ? [...(dataAfter.achievedRewardIds as string[])] : [];

        if (!achievedRewardIds.includes(AchievementId.EARLY_BIRD)) {
          achievedRewardIds.push(AchievementId.EARLY_BIRD);
          await userProfileRef.update({
            achievedRewardIds,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          // Використовуємо уніфікований логер
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