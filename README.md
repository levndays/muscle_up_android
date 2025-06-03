# MuscleUP: Next-Gen Fitness Application

Motto: Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

1.  [Introduction](#1-introduction)
2.  [Current Project Status (Version 0.4.x - Social Features Phase 1 & 2 Started)](#2-current-project-status-version-04x---social-features-phase-1--2-started)
3.  [Core Architectural Principles](#3-core-architectural-principles)
4.  [Technology Stack](#4-technology-stack)
5.  [Project Structure](#5-project-structure)
6.  [Deep Dive into Key Components & UX](#6-deep-dive-into-key-components--ux)
    *   [6.1. Authentication & Profile Setup](#61-authentication--profile-setup)
    *   [6.2. Main Navigation: `HomePage` & `DashboardScreen`](#62-main-navigation-homepage--dashboardscreen)
    *   [6.3. Notification System](#63-notification-system)
    *   [6.4. Exercise Library](#64-exercise-library)
    *   [6.5. Workout Routine Management](#65-workout-routine-management)
    *   [6.6. Workout Tracking](#66-workout-tracking)
    *   [6.7. Progress Tracking (`ProgressScreen` & `ProgressCubit`)](#67-progress-tracking-progressscreen--progresscubit)
    *   [6.8. Achievements System](#68-achievements-system)
    *   [6.9. NEW: Social Features (Explore Tab)](#69-new-social-features-explore-tab)
    *   [6.10. Quality of Life & UX Details](#610-quality-of-life--ux-details)
7.  [Backend: Firebase Cloud Firestore Structure](#7-backend-firebase-cloud-firestore-structure)
8.  [Firebase Cloud Functions Logic (`functions/src/index.ts`)](#8-firebase-cloud-functions-logic-functionssrcindexts)
9.  [Setup and Running the Project](#9-setup-and-running-the-project)
10. [Roadmap & Future Development](#10-roadmap--future-development)

---

## 1. Introduction

MuscleUP is an innovative mobile fitness application designed to revolutionize your approach to training. Our mission is to create a highly motivating, socially interactive, and gamified environment that not only helps users achieve their fitness goals but also makes the process enjoyable, fostering long-term engagement. MuscleUP enables detailed workout tracking, personalized goal setting, progress analysis through unique metrics (like RPE for each repetition), community support by sharing achievements, and now, social interaction through posts.

This document provides a comprehensive overview of the MuscleUP project, including its current features, core business logic, software architecture, backend design with Firebase, and detailed functionality of its components. It emphasizes modularity, scalability, and maintainability.

## 2. Current Project Status (Version 0.4.x - Social Features Phase 1 & 2 Started)

MuscleUP has incorporated a robust set of core features and has recently begun implementing social functionalities.

**Key Implemented Features:**

*   **Authentication & User Profile:**
    *   Secure Email/Password and Google Sign-In.
    *   Automated initial profile creation in Cloud Firestore (`profileSetupComplete: false`) via `createUserProfile` Firebase Function.
    *   Dedicated `ProfileSetupScreen` for detailed user information (username, gender, DOB, height, weight, goals, activity level) with edit capabilities.
    *   Real-time user profile updates via `UserProfileCubit`.
    *   Automatic "Early Bird" achievement award upon profile setup completion, managed by `checkProfileSetupCompletionAchievements` Firebase Function.

*   **Main Navigation & Dashboard (`HomePage` & `DashboardScreen`):**
    *   Central AppBar with dynamic titles ("MuscleUP | Screen Name").
    *   BottomNavigationBar for navigation: Routines, **Explore (Posts)**, Progress, Profile.
    *   "START WORKOUT" FloatingActionButton on the `DashboardScreen` with intelligent navigation based on active sessions or existing routines.
    *   Dashboard: Personalized greeting, workout streak icon, basic stats cards, interactive Notifications Section, and Upcoming Schedule.

*   **NEW: Social Features (`features/social` & `ExploreScreen`):**
    *   **Post System:**
        *   `Post` entity (author, timestamp, type, content, media (future), likes, comments). `PostType` enum (`standard`, `recordClaim`, `routineShare`).
        *   Firestore collection `posts` for storing all user-generated posts.
        *   `PostRepository` for CRUD operations on posts.
    *   **Create Standard Posts:**
        *   `CreatePostScreen` allows users to write and publish text-based posts.
        *   `CreatePostCubit` manages state for post creation.
        *   Authors can enable/disable comments for their posts during creation.
    *   **Explore Feed (`ExploreScreen`):**
        *   Replaces the previous `ExerciseExplorerScreen` on the "Explore" tab.
        *   Displays a feed of posts from all users, sorted by timestamp (newest first).
        *   `ExploreFeedCubit` manages loading and displaying posts.
        *   `PostListItem` widget for rendering individual posts, showing author info, content, and interaction buttons.
    *   **Post Interaction (Likes & Comments):**
        *   **Likes:** Users can like/unlike posts. The like count is updated on the `PostListItem`. Implemented via `PostInteractionCubit` and `PostRepository` (updating `likedBy` array in Firestore).
        *   **Comments:**
            *   `Comment` entity (author, text, timestamp). Stored in a subcollection `comments` under each post document.
            *   `PostDetailScreen` displays the full post and its comments. Users can add new comments if enabled.
            *   `PostInteractionCubit` manages loading comments and submitting new ones for a specific post.
            *   Authors of comments can edit and delete their own comments.
            *   Authors of posts can enable/disable comments for their posts (via `CreatePostScreen` and `PostDetailScreen`).
            *   Cloud Functions (`onCommentCreated`, `onCommentDeleted`) automatically update `commentsCount` on the parent post document.

*   **Exercise Library (`ExerciseExplorerScreen` - Now accessible contextually, e.g., for adding to routines):**
    *   Browse standardized exercises from Firestore.
    *   Selection mode for adding exercises to routines.
    *   Powered by `ExerciseExplorerCubit`.

*   **Workout Routine Management (`features/routines`):**
    *   `UserRoutinesScreen`: View, create, edit, and delete custom routines.
    *   `CreateEditRoutineScreen`: Define routine name, description, schedule, and add exercises.
    *   Exercises added via `AddExerciseToRoutineDialog`.

*   **Workout Tracking (`ActiveWorkoutScreen`):**
    *   Start workouts from routines or as empty sessions. Auto-resume incomplete sessions.
    *   `CurrentSetDisplay`: Log weight, reps, and unique RPE-per-rep sliders.

*   **Workout Completion (`WorkoutCompleteScreen`):**
    *   Celebratory screen with Lottie animation and Confetti. Displays summary, XP gained, and level-up info.
    *   Automatic "First Workout" achievement award via `calculateAndAwardXpAndStreak` Firebase Function.

*   **Progress Tracking Screen (`ProgressScreen`):**
    *   `ProgressCubit` orchestrates data for leagues, XP/level, muscle map, and training stats.
    *   `LeagueTitleWidget` & `XPProgressBarWidget`.
    *   `MuscleMapWidget` for gender-specific SVG muscle volume visualization.
    *   Statistics: Avg RPE, Working Weight Trend, RPE Trend per exercise.

*   **Notification System (`features/notifications`):**
    *   `AppNotification` model and `NotificationType` enum.
    *   `NotificationsCubit` manages real-time updates, unread count, and alerts (achievements, advice).

*   **Firebase Cloud Functions (TypeScript, Node.js v20):**
    *   `createUserProfile` (Auth trigger).
    *   `calculateAndAwardXpAndStreak` (Firestore trigger for completed workouts).
    *   `checkProfileSetupCompletionAchievements` (Firestore trigger for profile setup).
    *   `seedPredefinedExercises` (HTTPS trigger).
    *   **NEW:** `onCommentCreated` (Firestore trigger to increment `commentsCount` on post).
    *   **NEW:** `onCommentDeleted` (Firestore trigger to decrement `commentsCount` on post).

*   **Achievements System:**
    *   "Early Bird" and "First Workout" implemented.

## 3. Core Architectural Principles

(Content mostly unchanged, still relevant)
The project adheres to modern software development best practices: Modularity (Feature-First), Clean Architecture (Layered Approach), State Management (BLoC/Cubit), Dependency Injection, Data Abstraction (Repositories), Scalability, Testability.

## 4. Technology Stack

(Content mostly unchanged, list of packages is up-to-date in `pubspec.yaml`)
Frontend: Flutter, Dart, `flutter_bloc`, `equatable`, `intl`, `flutter_svg`, `animated_background`, `confetti`, `lottie`.
Backend (Firebase): Core, Auth, Google Sign-In, Firestore, Cloud Functions (TypeScript, Node.js v20).
Development Tools: `flutter_lints`, `flutter_launcher_icons`.

## 5. Project Structure

(Updated to reflect new `social` feature module)


muscle_up/
├── android/
├── assets/
│ ├── animations/
│ ├── fonts/
│ └── images/
├── functions/
│ ├── src/
│ │ └── index.ts # Cloud Functions (createUserProfile, streaks, achievements, comment counts)
│ ├── package.json
│ └── tsconfig.json
├── ios/
├── lib/
│ ├── auth_gate.dart
│ ├── firebase_options.dart
│ ├── home_page.dart
│ ├── login_page.dart
│ ├── main.dart
│ │
│ ├── core/
│ │ └── domain/
│ │ ├── entities/ # (achievement, app_notification, comment, league_info, logged_exercise, logged_set, post, predefined_exercise, routine, user_profile, workout_session)
│ │ └── repositories/ # (league, notification, post, predefined_exercise, routine, user_profile, workout_log)
│ │
│ ├── features/
│ │ ├── dashboard/
│ │ ├── exercise_explorer/ # Now used contextually
│ │ ├── notifications/
│ │ ├── profile/
│ │ ├── profile_setup/
│ │ ├── progress/
│ │ ├── routines/
│ │ ├── social/ # NEW: Social features module
│ │ │ ├── data/repositories/post_repository_impl.dart
│ │ │ └── presentation/
│ │ │ ├── cubit/ # (create_post_cubit, explore_feed_cubit, post_interaction_cubit)
│ │ │ ├── screens/ # (create_post_screen, explore_screen, post_detail_screen)
│ │ │ └── widgets/ # (comment_list_item, post_list_item)
│ │ └── workout_tracking/
│ │
│ ├── utils/
│ └── widgets/
│
├── pubspec.yaml
├── README.md
└── ...

## 6. Deep Dive into Key Components & UX

### 6.1. Authentication & Profile Setup
(Content mostly unchanged)
`LoginPage` with `LavaLampBackground`, `AuthGate` for auth state and profile setup redirection, `createUserProfile` Firebase Function, `ProfileSetupScreen`, `checkProfileSetupCompletionAchievements` Firebase Function, `UserProfileCubit`.

### 6.2. Main Navigation: `HomePage` & `DashboardScreen`
(Content mostly unchanged regarding Dashboard, FAB, and other tabs)
`HomePage` with AppBar, BottomNavigationBar (Routines, **Explore (Posts)**, Progress, Profile), and "START WORKOUT" FAB. `DashboardScreen` with greeting, streak, stats, notifications, and upcoming schedule.

### 6.3. Notification System
(Content mostly unchanged)
`AppNotification` model, `NotificationRepositoryImpl`, `NotificationsCubit`, `NotificationListItem` & `NotificationDetailScreen`.

### 6.4. Exercise Library
(Content mostly unchanged, `ExerciseExplorerScreen` now used contextually)
`PredefinedExercise` model, `PredefinedExerciseRepositoryImpl`, `seedPredefinedExercises` Firebase Function, `ExerciseExplorerCubit`.

### 6.5. Workout Routine Management
(Content mostly unchanged)
`UserRoutine` & `RoutineExercise` models, `RoutineRepositoryImpl`, `UserRoutinesCubit`, `ManageRoutineCubit`, UI screens.

### 6.6. Workout Tracking
(Content mostly unchanged)
`WorkoutSession`, `LoggedExercise`, `LoggedSet` entities. `WorkoutLogRepositoryImpl`, `ActiveWorkoutCubit` (start, update, complete, cancel workouts), `calculateAndAwardXpAndStreak` Firebase Function, `ActiveWorkoutScreen` with RPE sliders, `WorkoutCompleteScreen`.

### 6.7. Progress Tracking (`ProgressScreen` & `ProgressCubit`)
(Content mostly unchanged)
League System (`LeagueInfo`, `LeagueTitleWidget`), XP & Leveling (`XPProgressBarWidget`), Muscle Map (`MuscleMapWidget`), Training Statistics (Avg RPE, Weight Trend, RPE Trend).

### 6.8. Achievements System
(Content mostly unchanged)
`AchievementId` Enum, `Achievement` Entity, awarding logic via Firebase Functions, display on `ProfileScreen`.

### 6.9. NEW: Social Features (Explore Tab)

*   **`ExploreScreen`:**
    *   This screen now serves as the main feed for viewing posts from other users.
    *   It uses `ExploreFeedCubit` to load a stream of `Post` objects from Firestore.
    *   Posts are displayed using `PostListItem` widgets.
    *   A FloatingActionButton allows users to navigate to `CreatePostScreen`.
*   **`CreatePostScreen`:**
    *   Allows users to compose and publish standard text-based posts.
    *   Includes a switch to enable/disable comments for the new post.
    *   Uses `CreatePostCubit` to handle post submission logic, fetching author's current `UserProfile` (username, profile picture) to embed in the `Post` document.
*   **`PostListItem` Widget:**
    *   Displays individual post content: author's avatar and username, post timestamp, text content.
    *   **Likes:** Shows like count and an interactive like button (thumb icon). State of the like button (liked/not liked by current user) and like count are managed by an instance of `PostInteractionCubit` specific to this post. Tapping the like button calls `toggleLike()` on the cubit.
    *   **Comments:** Shows comment count and an icon. Tapping this area navigates to `PostDetailScreen`.
*   **`PostDetailScreen`:**
    *   Displays the full content of a selected post.
    *   Fetches and displays a list of comments for the post using `PostInteractionCubit` and `CommentListItem` widgets.
    *   If comments are enabled for the post (and the user is authenticated), a text field and send button are available for adding new comments.
    *   **Comment Moderation:** Authors of comments can edit or delete their own comments.
    *   **Post Settings (Author only):** The author of the post can toggle the `isCommentsEnabled` setting for their post via an icon button in the AppBar.
*   **`PostInteractionCubit`:**
    *   Manages the state for a single post, including its like status, comments, and settings like `isCommentsEnabled`.
    *   Handles `toggleLike()`, `addComment()`, `fetchComments()`, `updateComment()`, `deleteComment()`, and `toggleCommentsEnabled()` actions by interacting with `PostRepository`.
    *   Subscribes to real-time updates for the specific post and its comments.
*   **Firestore Structure for Social:**
    *   `posts/{postId}`: Collection for posts. Each document contains post data including `userId`, `authorUsername`, `authorProfilePicUrl`, `textContent`, `likedBy` (array of user IDs), `commentsCount`, `isCommentsEnabled`.
    *   `posts/{postId}/comments/{commentId}`: Subcollection for comments related to a post. Each comment document includes `userId`, `authorUsername`, `authorProfilePicUrl`, `text`, `timestamp`.
*   **Cloud Functions for Social:**
    *   `onCommentCreated`: Increments `commentsCount` on the parent post.
    *   `onCommentDeleted`: Decrements `commentsCount` on the parent post.

### 6.10. Quality of Life & UX Details
(Content mostly unchanged)
Animated Background, Custom Theming, Intuitive Navigation, Confirmation Dialogs, Visual Feedback, RPE Sliders, Celebratory Animations, Automatic UI Updates.

## 7. Backend: Firebase Cloud Firestore Structure

The Firestore database is organized as follows:

*   `users/{userId}`: User-specific data.
    *   Fields: `uid`, `email`, `displayName`, `profilePictureUrl`, `username`, `gender`, `dateOfBirth`, `heightCm`, `weightKg`, `fitnessGoal`, `activityLevel`, `xp`, `level`, `currentStreak`, `longestStreak`, `lastWorkoutTimestamp`, `lastScheduledWorkoutCompletionTimestamp`, `lastScheduledWorkoutDayKey`, `followersCount`, `followingCount`, `achievedRewardIds` (List<String>), `profileSetupComplete`, `createdAt`, `updatedAt`.
    *   Subcollection `notifications/{notificationId}`: User notifications (`AppNotification` model).
    *   Subcollection `workoutLogs/{sessionId}`: Workout session data (`WorkoutSession` model).

*   `predefinedExercises/{exerciseId}`: Standardized exercise library (`PredefinedExercise` model).

*   `userRoutines/{routineId}`: User-created workout routines (`UserRoutine` model).
    *   Fields include `userId` to link to the user.

*   `leagues/{leagueId}`: Information about fitness leagues (`LeagueInfo` model).

*   **NEW:** `posts/{postId}`: User-generated posts.
    *   Fields: `userId`, `authorUsername`, `authorProfilePicUrl`, `timestamp`, `type` (String, e.g., "standard"), `textContent`, `mediaUrl` (String, optional), `likedBy` (List<String>), `commentsCount` (int), `isCommentsEnabled` (bool), `relatedRoutineId` (String, optional), `routineSnapshot` (Map, optional), `recordDetails` (Map, optional), `isRecordVerified` (bool, optional), `updatedAt` (Timestamp).
    *   Subcollection `comments/{commentId}`: Comments related to a post.
        *   Fields: `postId`, `userId`, `authorUsername`, `authorProfilePicUrl`, `text`, `timestamp`.

## 8. Firebase Cloud Functions Logic (`functions/src/index.ts`)

Server-side logic is handled by Firebase Cloud Functions:

*   `createUserProfile`: Creates Firestore user profile on new Firebase Auth user.
*   `calculateAndAwardXpAndStreak`: Processes completed workouts, awards XP/level, updates streak, awards "First Workout" achievement.
*   `checkProfileSetupCompletionAchievements`: Awards "Early Bird" achievement on profile setup completion.
*   `seedPredefinedExercises`: Populates `predefinedExercises` collection.
*   **NEW:** `onCommentCreated`: (Firestore v2 Trigger - `onDocumentCreated` on `posts/{postId}/comments/{commentId}`) Increments `commentsCount` and updates `updatedAt` on the parent post document.
*   **NEW:** `onCommentDeleted`: (Firestore v2 Trigger - `onDocumentDeleted` on `posts/{postId}/comments/{commentId}`) Decrements `commentsCount` and updates `updatedAt` on the parent post document.

## 9. Setup and Running the Project

(Content mostly unchanged regarding Flutter SDK, Firebase Project Setup, Dependencies, App Icons, Running App, Seeding Exercises)

**Updated Firestore Security Rules Example:**

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /notifications/{notificationId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /workoutLogs/{sessionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    match /predefinedExercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if false; // Or admin/functions only
    }
    match /userRoutines/{routineId} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    match /leagues/{leagueId} {
      allow read: if true;
      allow write: if false;
    }

    match /posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;

      allow update: if request.auth != null &&
                      (
                        (resource.data.userId == request.auth.uid &&
                           !request.resource.data.diff(resource.data).affectedKeys().hasAny(['likedBy', 'commentsCount', 'userId', 'authorUsername', 'authorProfilePicUrl', 'timestamp']) &&
                           (request.resource.data.diff(resource.data).affectedKeys().hasOnly(['textContent', 'mediaUrl', 'isCommentsEnabled', 'type', 'relatedRoutineId', 'routineSnapshot', 'recordDetails', 'isRecordVerified', 'updatedAt']) ||
                            request.resource.data.diff(resource.data).affectedKeys().hasOnly(['updatedAt'])
                           )
                        ) ||
                        (
                           request.resource.data.diff(resource.data).affectedKeys().hasAll(['likedBy', 'updatedAt']) &&
                           request.resource.data.diff(resource.data).affectedKeys().size() == 2 &&
                           (
                             (request.resource.data.likedBy.toSet().difference(resource.data.likedBy.toSet()).hasOnly([request.auth.uid])) ||
                             (resource.data.likedBy.toSet().difference(request.resource.data.likedBy.toSet()).hasOnly([request.auth.uid]))
                           ) &&
                           request.resource.data.userId == resource.data.userId &&
                           request.resource.data.type == resource.data.type &&
                           request.resource.data.textContent == resource.data.textContent &&
                           request.resource.data.mediaUrl == resource.data.mediaUrl &&
                           request.resource.data.isCommentsEnabled == resource.data.isCommentsEnabled &&
                           request.resource.data.commentsCount == resource.data.commentsCount
                        )
                      );
      allow delete: if request.auth != null && resource.data.userId == request.auth.uid;

      match /comments/{commentId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null && request.resource.data.userId == request.auth.uid
                      && request.resource.data.postId == postId;
        allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
      }
    }
  }
}

## 10. Roadmap & Future Development

MuscleUP aims to become a comprehensive social fitness platform.

Phase 2: Social Interaction (Finalizing)

[✔️] Basic Post System (Standard Posts)

[✔️] Explore Feed to view posts

[✔️] Likes on Posts

[✔️] Comments on Posts (view, add, edit, delete own)

[✔️] Cloud Functions for commentsCount

[✔️] Enable/Disable comments by post author

Phase 3: Advanced Post Types & Interactions

Post "Share Routine" (routineShare):

UI for creating routineShare posts.

UI for displaying routineShare posts in the feed.

Logic to "Add to my routines".

Post "Record Claim" (recordClaim):

UI for creating recordClaim posts (link to video evidence).

UI for displaying recordClaim posts with voting options.

Logic for vote casting and storage.

(Optional) Cloud Function for vote tallying and verification status.

Phase 4: Core Social Graph

User Following/Followers:

Update UserProfile for following list and followersCount.

UI for Follow/Unfollow buttons (on profiles, in post headers).

Cloud Functions to manage follow/unfollow relationships and update counts.

Personalized Feed (Future for "Explore" or new "Feed" tab):

Logic to show posts from followed users.

Phase 5: Enhancements & Polish

Media in Posts:

Image/Video upload (Firebase Storage).

Display media in PostListItem and PostDetailScreen.

Notifications for Social Interactions:

New Like on your post.

New Comment on your post.

New Follower.

UI/UX Refinements for Social Features:

Post options menu (edit/delete own post, report post).

Filtering/Sorting options in Explore feed.

User profile pages (viewable by others).

Full Implementation of Other Screens: Complete "Profile" details (advanced stats, activity feed related to social).

Long-Term Vision (Beyond current scope):

Direct Messaging.

Public Records & Leaderboards (community-validated).

Advanced Gamification (more achievements, challenges, seasonal leagues, virtual rewards).

Personalized Goal Setting (more granular).

Push Notifications via FCM.

Comprehensive Testing (Unit, Widget, Integration).

Admin Panel.

Wearable Device Integration.

Offline Support.

