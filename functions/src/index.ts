// FILE: functions/src/index.ts
import * as functionsV1 from "firebase-functions/v1";
import * as functionsV2 from "firebase-functions/v2";
import { logger } from "firebase-functions";
import {
  onDocumentWritten,
  onDocumentUpdated,
  onDocumentCreated,
  onDocumentDeleted,
  Change,
  FirestoreEvent,
  QueryDocumentSnapshot,
} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import { DocumentSnapshot, Timestamp, FieldValue } from "firebase-admin/firestore";

try {
  admin.initializeApp();
} catch (e) {
  logger.info("Admin app already initialized or error during init:", e);
}

enum AchievementId {
  EARLY_BIRD = "earlyBird",
  FIRST_WORKOUT = "firstWorkout",
  PERSONAL_RECORD_SET = "personalRecordSet",
}

enum NotificationType { // Re-define for function context or import if shared
  ACHIEVEMENT_UNLOCKED = "achievementUnlocked",
  WORKOUT_REMINDER = "workoutReminder",
  NEW_FOLLOWER = "newFollower", // NEW
  ROUTINE_SHARED = "routineShared",
  SYSTEM_MESSAGE = "systemMessage",
  ADVICE = "advice",
  CUSTOM = "custom",
}

enum RecordVerificationStatus {
  PENDING = "pending",
  VERIFIED = "verified",
  REJECTED = "rejected",
  EXPIRED = "expired",
}

enum VoteType {
  VERIFY = "verify",
  DISPUTE = "dispute",
}

const defaultRegion = "us-central1";
const XP_FOR_VOTING = 15;
const XP_FOR_RECORD_BASE = 500;
const RECORD_VOTE_DURATION_HOURS = 24;
const MIN_VOTE_PERCENTAGE_FOR_VERIFICATION = 0.55;

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
  logger.info("V1 Auth trigger: New user created.", { uid: user.uid, email: user.email });
  const userDocRef = admin.firestore().collection("users").doc(user.uid);
  try {
    const docSnapshot = await userDocRef.get();
    if (docSnapshot.exists) {
      logger.warn(`V1 User profile for ${user.uid} already exists. Skipping creation.`);
      return null;
    }
    await userDocRef.set({
      uid: user.uid, email: user.email?.toLowerCase() ?? null, displayName: null,
      profilePictureUrl: user.photoURL ?? null, username: null, gender: null,
      dateOfBirth: null, heightCm: null, weightKg: null, fitnessGoal: null,
      activityLevel: null, xp: 0, level: 1, currentStreak: 0, longestStreak: 0,
      lastWorkoutTimestamp: null, lastScheduledWorkoutCompletionTimestamp: null,
      lastScheduledWorkoutDayKey: null,
      followersCount: 0,
      followingCount: 0,
      achievedRewardIds: [],
      following: [],
      profileSetupComplete: false,
      createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp(),
    });
    logger.info("V1 User profile successfully created.", { uid: user.uid });
    return null;
  } catch (error: any) {
    logger.error("V1 Error creating user profile.", { uid: user.uid, error: error.message || error });
    return null;
  }
});

export const calculateAndAwardXpAndStreak = onDocumentUpdated(
  { document: "users/{userId}/workoutLogs/{sessionId}", region: defaultRegion },
  async (event: FirestoreEvent<Change<DocumentSnapshot> | undefined, { userId: string; sessionId: string }>) => {
    const { userId, sessionId } = event.params;
    if (!event.data?.before?.exists || !event.data?.after?.exists) {
      logger.warn("Doc data missing in onUpdated for workout log.", { userId, sessionId }); return;
    }
    const oldWorkoutData = event.data.before.data()!;
    const newWorkoutData = event.data.after.data()!;
    const justCompleted = oldWorkoutData.status !== "completed" && newWorkoutData.status === "completed";
    if (!justCompleted) return;

    logger.info("Workout completed. Calculating XP, streak, awards.", { userId, sessionId });
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
          logger.error("User profile not found in transaction.", { userId }); throw new Error(`User profile ${userId} not found.`);
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
            if (currentProfile.lastScheduledWorkoutCompletionTimestamp && currentProfile.lastScheduledWorkoutDayKey) {
              const lastScheduledCompletionJsDate = (currentProfile.lastScheduledWorkoutCompletionTimestamp as Timestamp).toDate();
              const lastScheduledCompletionDayStartUTC = getUTCDayStart(lastScheduledCompletionJsDate);
              if (currentWorkoutDayStartUTC.getTime() === lastScheduledCompletionDayStartUTC.getTime() && currentProfile.lastScheduledWorkoutDayKey === currentWorkoutDayKey) {
                // Same day, no increment
              } else {
                let wasPreviousScheduledDayMissed = false;
                let tempDate = new Date(lastScheduledCompletionDayStartUTC);
                tempDate.setUTCDate(tempDate.getUTCDate() + 1);
                while (tempDate.getTime() < currentWorkoutDayStartUTC.getTime()) {
                  const dayKeyToTest = getDayKeyFromJsDate(tempDate);
                  if (scheduledDays.includes(dayKeyToTest)) {
                    wasPreviousScheduledDayMissed = true; break;
                  }
                  tempDate.setUTCDate(tempDate.getUTCDate() + 1);
                }
                if (wasPreviousScheduledDayMissed) {
                  currentStreak = 1;
                } else {
                  currentStreak++;
                }
                newLastScheduledWorkoutCompletionTimestamp = completedAt;
                newLastScheduledWorkoutDayKey = currentWorkoutDayKey;
              }
            } else {
              currentStreak = 1; newLastScheduledWorkoutCompletionTimestamp = completedAt; newLastScheduledWorkoutDayKey = currentWorkoutDayKey;
            }
          }
        }
        longestStreak = Math.max(longestStreak, currentStreak);
        const xpPerLevelBase = 200;
        const calculateXpForNextLevelUp = (cl: number): number => xpPerLevelBase + (cl - 1) * 50;
        let xpNeededForCurrentLevelToComplete = calculateXpForNextLevelUp(calculatedNewLevel);
        let totalXpAtStartOfCurrentLevel = 0;
        for (let i = 1; i < calculatedNewLevel; i++) {
          totalXpAtStartOfCurrentLevel += calculateXpForNextLevelUp(i);
        }
        while (newXp >= totalXpAtStartOfCurrentLevel + xpNeededForCurrentLevelToComplete) {
          totalXpAtStartOfCurrentLevel += xpNeededForCurrentLevelToComplete; calculatedNewLevel++;
          xpNeededForCurrentLevelToComplete = calculateXpForNextLevelUp(calculatedNewLevel);
        }
        const achievedRewardIds: string[] = currentProfile.achievedRewardIds ? [...(currentProfile.achievedRewardIds as string[])] : [];
        if (!achievedRewardIds.includes(AchievementId.FIRST_WORKOUT)) {
          achievedRewardIds.push(AchievementId.FIRST_WORKOUT);
          const notificationsRef = userProfileRef.collection("notifications");
          transaction.set(notificationsRef.doc(), {
            type: "achievementUnlocked", title: "First Workout Completed!",
            message: "You've successfully completed your first workout. Great start!",
            timestamp: FieldValue.serverTimestamp(), isRead: false, iconName: "fitness_center",
            relatedEntityId: AchievementId.FIRST_WORKOUT, relatedEntityType: "achievement",
          });
        }
        const profileUpdateData: { [key: string]: any } = {
          xp: newXp, level: calculatedNewLevel, currentStreak, longestStreak,
          lastWorkoutTimestamp: completedAt, achievedRewardIds, updatedAt: FieldValue.serverTimestamp(),
        };
        if (newLastScheduledWorkoutCompletionTimestamp) profileUpdateData.lastScheduledWorkoutCompletionTimestamp = newLastScheduledWorkoutCompletionTimestamp;
        if (newLastScheduledWorkoutDayKey) profileUpdateData.lastScheduledWorkoutDayKey = newLastScheduledWorkoutDayKey;
        transaction.update(userProfileRef, profileUpdateData);
        logger.info("User profile updated.", { userId, updatedXp: newXp, updatedLevel: calculatedNewLevel, updatedCurrentStreak: currentStreak });
      });
    } catch (error: any) {
      logger.error("Error updating user profile after workout.", { userId, sessionId, error: error.message || error });
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
        logger.info("Profile setup completed. Checking EarlyBird.", { userId });
        const userProfileRef = admin.firestore().collection("users").doc(userId);
        const achievedRewardIds: string[] = dataAfter.achievedRewardIds ? [...(dataAfter.achievedRewardIds as string[])] : [];
        if (!achievedRewardIds.includes(AchievementId.EARLY_BIRD)) {
          achievedRewardIds.push(AchievementId.EARLY_BIRD);
          await userProfileRef.update({ achievedRewardIds, updatedAt: FieldValue.serverTimestamp() });
          const notificationsRef = userProfileRef.collection("notifications");
          await notificationsRef.add({
            type: "achievementUnlocked", title: "Profile Setup Complete!",
            message: "You've successfully set up your profile. Welcome aboard!",
            timestamp: FieldValue.serverTimestamp(), isRead: false, iconName: "auto_awesome",
            relatedEntityId: AchievementId.EARLY_BIRD, relatedEntityType: "achievement",
          });
        }
      }
    }
  }
);

export const onCommentCreated = onDocumentCreated(
  { document: "posts/{postId}/comments/{commentId}", region: defaultRegion },
  async (event: FirestoreEvent<DocumentSnapshot | undefined, { postId: string; commentId: string }>) => {
    const { postId, commentId } = event.params;
    if (!event.data?.data()) { logger.warn("Comment data missing in onCommentCreated.", { postId, commentId }); return; }
    const postRef = admin.firestore().collection("posts").doc(postId);
    try {
      await postRef.update({ commentsCount: FieldValue.increment(1), updatedAt: FieldValue.serverTimestamp() });
    } catch (error: any) {
      logger.error(`Error incrementing commentsCount for post ${postId}: ${error.message || error}`, { postId, commentId });
    }
  }
);

export const onCommentDeleted = onDocumentDeleted(
  { document: "posts/{postId}/comments/{commentId}", region: defaultRegion },
  async (event: FirestoreEvent<DocumentSnapshot | undefined, { postId: string; commentId: string }>) => {
    const { postId, commentId } = event.params;
    const postRef = admin.firestore().collection("posts").doc(postId);
    try {
      await postRef.update({ commentsCount: FieldValue.increment(-1), updatedAt: FieldValue.serverTimestamp() });
    } catch (error: any) {
      logger.error(`Error decrementing commentsCount for post ${postId}: ${error.message || error}`, { postId, commentId });
    }
  }
);

export const onRecordClaimPostCreated = onDocumentCreated(
  { document: "posts/{postId}", region: defaultRegion },
  async (event: FirestoreEvent<QueryDocumentSnapshot | undefined, { postId: string }>) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.log("No data associated with the event for onRecordClaimPostCreated"); return;
    }
    const post = snapshot.data();
    const postIdFromEvent = event.params.postId;

    if (post.type === "recordClaim") {
      const deadline = Timestamp.fromMillis(Timestamp.now().toMillis() + RECORD_VOTE_DURATION_HOURS * 60 * 60 * 1000);
      try {
        await admin.firestore().collection("posts").doc(postIdFromEvent).update({
          recordVerificationDeadline: deadline,
          recordVerificationStatus: RecordVerificationStatus.PENDING,
          updatedAt: FieldValue.serverTimestamp(),
        });
        logger.info(`Record claim post ${postIdFromEvent} created. Deadline set.`);
      } catch (error) {
        logger.error(`Failed to set deadline for record claim post ${postIdFromEvent}`, error);
      }
    }
  }
);

export const onRecordClaimVoteCasted = onDocumentUpdated(
  { document: "posts/{postId}", region: defaultRegion },
  async (event: FirestoreEvent<Change<DocumentSnapshot> | undefined, { postId: string }>) => {
    const postIdFromEvent = event.params.postId;
    if (!event.data || !event.data.before.exists || !event.data.after.exists) {
      logger.warn("Post data missing in onRecordClaimVoteCasted.", { postId: postIdFromEvent }); return;
    }
    const postBefore = event.data.before.data()!;
    const postAfter = event.data.after.data()!;

    if (postAfter.type !== "recordClaim" || postAfter.recordVerificationStatus !== RecordVerificationStatus.PENDING) return;

    const votesBefore = postBefore.verificationVotes as { [key: string]: string } || {};
    const votesAfter = postAfter.verificationVotes as { [key: string]: string } || {};
    const votedAndRewardedUserIds: string[] = Array.isArray(postAfter.votedAndRewardedUserIds) ? postAfter.votedAndRewardedUserIds : [];
    const db = admin.firestore();
    const batch = db.batch();
    let batchHasWrites = false;

    for (const voterId in votesAfter) {
      if (votesAfter[voterId] && (!votesBefore[voterId] || votesBefore[voterId] !== votesAfter[voterId])) {
        if (!votedAndRewardedUserIds.includes(voterId)) {
          const userProfileRef = db.collection("users").doc(voterId);
          batch.update(userProfileRef, { xp: FieldValue.increment(XP_FOR_VOTING) });
          votedAndRewardedUserIds.push(voterId);
          batchHasWrites = true;
          const notificationRef = userProfileRef.collection("notifications").doc();
          batch.set(notificationRef, {
            type: "systemMessage", title: "XP for Voting!",
            message: `You received ${XP_FOR_VOTING} XP for voting on a record claim.`,
            timestamp: FieldValue.serverTimestamp(), isRead: false, iconName: "military_tech",
            relatedEntityId: postIdFromEvent, relatedEntityType: "postVote",
          });
          logger.info(`Awarded ${XP_FOR_VOTING} XP to user ${voterId} for voting on post ${postIdFromEvent}`);
        }
      }
    }
    if (batchHasWrites) {
      const postRef = db.collection("posts").doc(postIdFromEvent);
      batch.update(postRef, { votedAndRewardedUserIds: votedAndRewardedUserIds, updatedAt: FieldValue.serverTimestamp() });
      try {
        await batch.commit();
        logger.info(`Batch committed for vote rewards on post ${postIdFromEvent}.`);
      } catch (error) {
        logger.error(`Error committing batch for vote rewards on post ${postIdFromEvent}:`, error);
      }
    }
  }
);

export const processRecordClaimDeadlines = functionsV2.scheduler.onSchedule(
  {
    schedule: "every 1 hours",
    region: defaultRegion,
    timeoutSeconds: 540,
    memory: "256MiB",
    timeZone: "UTC",
  },
  async (event: functionsV2.scheduler.ScheduledEvent): Promise<void> => {
    logger.info("Running scheduled function: processRecordClaimDeadlines", { scheduleTime: event.scheduleTime });
    const now = Timestamp.now();
    const db = admin.firestore();
    const pendingClaimsQuery = db.collection("posts")
      .where("type", "==", "recordClaim")
      .where("recordVerificationStatus", "==", RecordVerificationStatus.PENDING)
      .where("recordVerificationDeadline", "<=", now);

    const snapshot = await pendingClaimsQuery.get();
    if (snapshot.empty) {
      logger.info("No pending record claims past deadline.");
      return;
    }
    logger.info(`Found ${snapshot.docs.length} record claims past deadline to process.`);
    const writeBatch = db.batch();
    const notificationsToAdd: Array<{ ref: FirebaseFirestore.DocumentReference, data: any }> = [];

    for (const doc of snapshot.docs) {
      const post = doc.data();
      const currentPostId = doc.id;
      const authorId = post.userId;
      const recordDetails = post.recordDetails as { exerciseName?: string, weightKg?: number, reps?: number } | undefined;
      const votes = post.verificationVotes as { [key: string]: string } || {};
      let verifyCount = 0;
      let disputeCount = 0;
      Object.values(votes).forEach((vote) => {
        if (vote === VoteType.VERIFY) verifyCount++;
        else if (vote === VoteType.DISPUTE) disputeCount++;
      });
      const totalVotes = verifyCount + disputeCount;
      let newStatus = RecordVerificationStatus.EXPIRED;
      let authorNotificationTitle = "Record Claim Expired";
      let authorNotificationMessage = `Voting for your record claim on "${recordDetails?.exerciseName ?? "exercise"}" has ended without a clear result.`;
      let shouldAwardXpAndAchievement = false;

      if (totalVotes > 0) {
        const verifyRatio = verifyCount / totalVotes;
        if (verifyRatio >= MIN_VOTE_PERCENTAGE_FOR_VERIFICATION) {
          newStatus = RecordVerificationStatus.VERIFIED;
          authorNotificationTitle = "Record Verified!";
          authorNotificationMessage = `Congratulations! Your record for "${recordDetails?.exerciseName ?? "exercise"}" (${recordDetails?.weightKg}kg x ${recordDetails?.reps} reps) has been verified by the community!`;
          shouldAwardXpAndAchievement = true;
        } else {
          newStatus = RecordVerificationStatus.REJECTED;
          authorNotificationTitle = "Record Claim Denied";
          authorNotificationMessage = `Your record claim for "${recordDetails?.exerciseName ?? "exercise"}" was not verified by the community this time.`;
        }
      }
      writeBatch.update(doc.ref, {
        recordVerificationStatus: newStatus,
        isRecordVerified: newStatus === RecordVerificationStatus.VERIFIED,
        updatedAt: FieldValue.serverTimestamp(),
      });
      logger.info(`Post ${currentPostId} status updated to ${newStatus}. Verified: ${newStatus === RecordVerificationStatus.VERIFIED}`);

      const authorProfileRef = db.collection("users").doc(authorId);
      notificationsToAdd.push({
        ref: authorProfileRef.collection("notifications").doc(),
        data: {
          type: newStatus === RecordVerificationStatus.VERIFIED ? NotificationType.ACHIEVEMENT_UNLOCKED.toString() : NotificationType.SYSTEM_MESSAGE.toString(),
          title: authorNotificationTitle, message: authorNotificationMessage,
          timestamp: FieldValue.serverTimestamp(), isRead: false,
          iconName: newStatus === RecordVerificationStatus.VERIFIED ? "military_tech" : "gavel",
          relatedEntityId: currentPostId, relatedEntityType: "postVerification",
        },
      });

      if (shouldAwardXpAndAchievement) {
        let recordXp = XP_FOR_RECORD_BASE;
        if (recordDetails && recordDetails.weightKg && recordDetails.reps) {
          const volume = recordDetails.weightKg * recordDetails.reps;
          recordXp += Math.floor(volume / 10);
        }
        recordXp = Math.min(recordXp, 1500);
        writeBatch.update(authorProfileRef, {
          xp: FieldValue.increment(recordXp),
          achievedRewardIds: FieldValue.arrayUnion(AchievementId.PERSONAL_RECORD_SET),
          updatedAt: FieldValue.serverTimestamp(),
        });
        notificationsToAdd.push({
          ref: authorProfileRef.collection("notifications").doc(),
          data: {
            type: NotificationType.ACHIEVEMENT_UNLOCKED.toString(),
            title: `New Record: ${recordDetails?.exerciseName ?? "Exercise"} Verified!`,
            message: `You earned ${recordXp} XP for your verified record of ${recordDetails?.weightKg}kg x ${recordDetails?.reps} reps!`,
            timestamp: FieldValue.serverTimestamp(), isRead: false, iconName: "military_tech",
            relatedEntityId: AchievementId.PERSONAL_RECORD_SET, relatedEntityType: "achievement",
          },
        });
        logger.info(`Awarded ${recordXp} XP and PersonalRecord achievement to user ${authorId} for post ${currentPostId}`);
      }
    }
    try {
      await writeBatch.commit();
      logger.info(`Batch committed for ${snapshot.docs.length} record claim updates.`);
      
      const notificationCreationPromises = notificationsToAdd.map((notif) => notif.ref.set(notif.data));
      await Promise.all(notificationCreationPromises);
      logger.info(`Created ${notificationsToAdd.length} notifications for processed claims.`);
    } catch (error) {
      logger.error("Error committing batch or creating notifications for record claim processing:", error);
    }
    return;
  }
);

export const handleUserFollowListUpdate = onDocumentWritten(
  { document: "users/{userId}", region: defaultRegion, memory: "256MiB" },
  async (event: FirestoreEvent<Change<DocumentSnapshot> | undefined, { userId: string }>) => {
    const currentUserId = event.params.userId;
    const change = event.data;
    if (!change) {
      logger.info(`No data change for user ${currentUserId}, exiting handleUserFollowListUpdate.`);
      return;
    }

    const beforeData = change.before.exists ? change.before.data() : null;
    const afterData = change.after.exists ? change.after.data() : null;

    if (!afterData && beforeData) {
      logger.info(`User document ${currentUserId} deleted. No follow/unfollow action to process based on 'following' list.`);
      return;
    }
    if (!afterData) {
      logger.info(`User document ${currentUserId} does not exist after event. Cannot process follow list update.`);
      return;
    }

    const followingBefore: string[] = Array.isArray(beforeData?.following) ? beforeData?.following : [];
    const followingAfter: string[] = Array.isArray(afterData.following) ? afterData.following : [];

    const db = admin.firestore();
    const batch = db.batch();
    let operationsInBatch = 0;
    const MAX_BATCH_OPERATIONS = 480; // Leave more room for notifications

    const followedUserIds = followingAfter.filter((id) => !followingBefore.includes(id));
    for (const targetUserId of followedUserIds) {
      if (operationsInBatch >= MAX_BATCH_OPERATIONS - 3) { await batch.commit(); operationsInBatch = 0; }
      const targetUserRef = db.collection("users").doc(targetUserId);
      batch.update(targetUserRef, { followersCount: FieldValue.increment(1), updatedAt: FieldValue.serverTimestamp() });
      operationsInBatch++;
      logger.info(`User ${currentUserId} followed ${targetUserId}. Incremented ${targetUserId}'s followersCount.`);

      // Create notification for the target user
      const notificationRef = targetUserRef.collection("notifications").doc();
      batch.set(notificationRef, {
        type: NotificationType.NEW_FOLLOWER.toString(), // Use enum string value
        title: "New Follower!",
        message: `${afterData.username ?? afterData.displayName ?? "Someone"} started following you.`,
        senderUserId: currentUserId, // Include sender ID for potential navigation
        senderUsername: afterData.username ?? afterData.displayName ?? "A user",
        senderProfilePicUrl: afterData.profilePictureUrl ?? null,
        timestamp: FieldValue.serverTimestamp(),
        isRead: false,
        iconName: "person_add_alt_1",
        relatedEntityId: currentUserId,
        relatedEntityType: "userProfile",
      });
      operationsInBatch++;
      logger.info(`Created newFollower notification for ${targetUserId} from ${currentUserId}.`);
    }

    const unfollowedUserIds = followingBefore.filter((id) => !followingAfter.includes(id));
    for (const targetUserId of unfollowedUserIds) {
      if (operationsInBatch >= MAX_BATCH_OPERATIONS - 1) { await batch.commit(); operationsInBatch = 0; }
      const targetUserRef = db.collection("users").doc(targetUserId);
      batch.update(targetUserRef, { followersCount: FieldValue.increment(-1), updatedAt: FieldValue.serverTimestamp() });
      operationsInBatch++;
      logger.info(`User ${currentUserId} unfollowed ${targetUserId}. Decremented ${targetUserId}'s followersCount.`);
    }

    if (followingAfter.length !== followingBefore.length) {
      if (operationsInBatch >= MAX_BATCH_OPERATIONS - 1) { await batch.commit(); operationsInBatch = 0; }
      const currentUserRef = db.collection("users").doc(currentUserId);
      batch.update(currentUserRef, { followingCount: followingAfter.length, updatedAt: FieldValue.serverTimestamp() });
      operationsInBatch++;
      logger.info(`Updated ${currentUserId}'s followingCount to ${followingAfter.length}.`);
    }

    if (operationsInBatch > 0) {
      try {
        await batch.commit();
        logger.info(`Batch committed for follow/unfollow and notification operations related to ${currentUserId}.`);
      } catch (error) {
        logger.error(`Error committing follow/unfollow/notification batch for ${currentUserId}:`, error);
      }
    } else {
      logger.info(`No direct follow/unfollow operations detected for ${currentUserId} in handleUserFollowListUpdate that require db writes.`);
    }
  }
);