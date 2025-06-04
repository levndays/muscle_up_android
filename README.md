# MuscleUP! - Next-gen Fitness App

**Mission:** To be a next-generation fitness application that helps users reach new heights in their fitness journey, accompanied by a supportive community.

**Version:** 0.7.0 (as per `pubspec.yaml`)

## Table of Contents

1.  [Key Features](#key-features)
2.  [Tech Stack](#tech-stack)
3.  [Project Structure](#project-structure)
    *   [Root Directory](#root-directory)
    *   [Flutter Application (`lib/`)](#flutter-application-lib)
    *   [Firebase Functions (`functions/`)](#firebase-functions-functions)
    *   [Platform Specific (`android/`, `ios/`)](#platform-specific-android-ios)
    *   [Assets (`assets/`)](#assets-assets)
4.  [Core Logic & Architecture](#core-logic--architecture)
    *   [State Management (BLoC/Cubit)](#state-management-bloccubit)
    *   [Authentication Flow](#authentication-flow)
    *   [Data Flow](#data-flow)
    *   [Entities](#entities)
    *   [Repositories](#repositories)
5.  [Firebase Backend Integration](#firebase-backend-integration)
    *   [Firebase Services Used](#firebase-services-used)
    *   [Cloud Functions (`functions/src/index.ts`)](#cloud-functions-functionssrcindexts)
        *   [Auth Triggers](#auth-triggers)
        *   [Firestore Triggers](#firestore-triggers)
        *   [Scheduled Functions](#scheduled-functions)
    *   [Firestore Database Structure (Inferred)](#firestore-database-structure-inferred)
    *   [Firebase Storage Structure](#firebase-storage-structure)
6.  [Detailed Feature Breakdown](#detailed-feature-breakdown)
    *   [User Authentication](#user-authentication)
    *   [Profile Setup](#profile-setup)
    *   [User Profile Viewing](#user-profile-viewing)
    *   [Dashboard](#dashboard)
    *   [Routines Management](#routines-management)
    *   [Workout Tracking](#workout-tracking)
    *   [Exercise Explorer](#exercise-explorer)
    *   [Social Feed (Explore)](#social-feed-explore)
    *   [Post Creation & Interaction](#post-creation--interaction)
    *   [Record Claims & Voting](#record-claims--voting)
    *   [Following System](#following-system)
    *   [Progress Tracking & Leagues](#progress-tracking--leagues)
    *   [Notifications](#notifications)
    *   [Achievements](#achievements)
7.  [UI/UX Highlights](#uiux-highlights)
8.  [Setup & Running the Project](#setup--running-the-project)
9.  [Potential Future Enhancements](#potential-future-enhancements)

## Key Features

*   **User Authentication:** Secure sign-up/sign-in with Email/Password and Google Sign-In.
*   **Profile Management:** Comprehensive user profiles with personal details, fitness stats, and avatar uploads.
*   **Personalized Dashboard:** Overview of stats, upcoming workouts, and recent notifications.
*   **Workout Routines:** Create, manage, and schedule custom workout routines.
*   **Active Workout Tracking:** Log sets, reps, weight, and RPE during workouts.
*   **Social Feed:** Share progress, routines, and record claims. Interact with posts via likes and comments.
*   **Record Claim System:** Users can claim personal records, which are then verified or disputed by the community through a voting system.
*   **Following System:** Users can follow/unfollow each other to build a fitness community.
*   **Progress Tracking:**
    *   XP and Leveling system.
    *   Workout streaks.
    *   Volume tracking per muscle group (visualized on a muscle map).
    *   RPE (Rate of Perceived Exertion) and working weight trends.
*   **Leagues & Leaderboards:** Users are placed in leagues based on their level, with leaderboards for friendly competition.
*   **Achievements:** Unlockable badges for various milestones.
*   **Notifications:** In-app notifications for achievements, new followers, workout reminders, shared routines, and system messages.
*   **Exercise Explorer:** A library of predefined exercises.
*   **Image Picker:** For uploading profile pictures and post media.

## Tech Stack

*   **Frontend:** Flutter (Dart)
*   **Backend:** Firebase
    *   Firebase Authentication
    *   Cloud Firestore (NoSQL Database)
    *   Firebase Storage (File Uploads)
    *   Cloud Functions for Firebase (Serverless Backend Logic - TypeScript)
*   **State Management:** flutter_bloc / bloc
*   **UI:**
    *   Material Design 3
    *   Custom animations and graphics (`flutter_svg`, `lottie`, `animated_background`, `confetti`)
*   **Utilities:**
    *   `equatable`: For value equality.
    *   `intl`: For date/number formatting.
    *   `image_picker`: For selecting images from gallery/camera.
    *   `google_sign_in`: For Google authentication.

## Project Structure

### Root Directory

*   `.firebaserc`: Configures Firebase project aliases (default: `muscle-up-8c275`).
*   `firebase.json`: Configures Firebase services, including Firestore rules (not present in snapshot but typical) and Cloud Functions deployment. Specifies `google-services.json` output.
*   `.gitignore`: Specifies intentionally untracked files that Git should ignore.
*   `pubspec.yaml`: Flutter project manifest; declares dependencies, assets, fonts, and app version.
*   `analysis_options.yaml`: Configures Dart static analysis (uses `flutter_lints`).
*   `assets/`: Contains static assets like images, fonts, and Lottie animations.
*   `functions/`: Directory for Firebase Cloud Functions (Node.js/TypeScript).
*   `lib/`: Main Dart application code.
*   `android/`, `ios/`, `web/`: Platform-specific project files.

### Flutter Application (`lib/`)

The `lib/` directory is structured following a feature-first approach combined with layers (domain, data, presentation).

*   **`main.dart`**: Entry point of the application. Initializes Firebase, sets up `RepositoryProvider`s for dependency injection, configures `MaterialApp` and global theme.
*   **`auth_gate.dart`**: Handles authentication state. Redirects users to `LoginPage`, `ProfileSetupScreen`, or `HomePage` based on auth status and profile completion.
*   **`login_page.dart`**: UI for user sign-in and sign-up.
*   **`home_page.dart`**: Main screen after login, containing a `BottomNavigationBar` to switch between Dashboard, Routines, Explore (Social Feed), Progress, and Profile.

*   **`core/`**: Shared code used across multiple features.
    *   `domain/entities/`: Plain Dart objects representing core data structures (e.g., `UserProfile`, `UserRoutine`, `Post`, `AppNotification`, `PredefinedExercise`, `WorkoutSession`, `LoggedExercise`, `LoggedSet`, `LeagueInfo`, `Comment`, `VoteType`).
    *   `domain/repositories/`: Abstract contracts (interfaces) for data operations (e.g., `UserProfileRepository`, `RoutineRepository`).
    *   `services/`: Utility services (e.g., `ImagePickerService`).

*   **`features/`**: Contains individual feature modules. Each feature typically has:
    *   `data/repositories/`: Concrete implementations of the repository interfaces defined in `core/domain/repositories/` or feature-specific domain layers. These interact directly with Firebase.
        *   e.g., `features/profile_setup/data/repositories/user_profile_repository_impl.dart`
    *   `presentation/cubit/`: BLoC/Cubit classes for managing the state of the feature.
        *   e.g., `features/profile/presentation/cubit/user_profile_cubit.dart`
    *   `presentation/screens/`: UI screens for the feature.
        *   e.g., `features/profile/presentation/screens/profile_screen.dart`
    *   `presentation/widgets/`: Reusable UI components specific to the feature.
        *   e.g., `features/progress/presentation/widgets/league_title_widget.dart`

    **List of Features (sub-directories):**
    *   `dashboard/`: Main landing screen content.
    *   `exercise_explorer/`: Browsing predefined exercises.
    *   `leagues/`: Displaying league information and leaderboards (part of Progress).
    *   `notifications/`: Managing and displaying user notifications.
    *   `profile/`: User profile display.
    *   `profile_setup/`: Initial user profile configuration.
    *   `progress/`: Visualizing user progress, stats, and leagues.
    *   `routines/`: Managing workout routines.
    *   `social/`: Social feed, post creation, interactions.
    *   `workout_tracking/`: Active workout logging and completion screens.

*   **`widgets/`**: General reusable UI widgets not specific to any single feature.
    *   `lava_lamp_background.dart`: Animated background for the login page.

*   **`firebase_options.dart`**: Auto-generated Firebase configuration for different platforms.
*   **`utils/`**: Utility functions like `duration_formatter.dart`.

### Firebase Functions (`functions/`)

Contains backend logic written in TypeScript, deployed to Cloud Functions for Firebase.

*   `package.json`: Defines Node.js dependencies (`firebase-admin`, `firebase-functions`, linters, TypeScript).
*   `tsconfig.json`: TypeScript compiler options.
*   `src/index.ts`: Main file containing all Cloud Functions.
    *   Handles user creation, workout completion logic (XP, streaks), achievement unlocking, post interaction side-effects (comment counts, media deletion), record claim deadline processing, and follower/following count management.

### Platform Specific (`android/`, `ios/`)

*   Contain native project files for Android and iOS.
*   **`android/app/build.gradle.kts`**: Android build configuration, dependencies (e.g., `google-services`).
*   **`android/app/src/main/AndroidManifest.xml`**: Android app manifest (permissions, activities).
*   **`android/app/google-services.json`**: Firebase configuration for Android.
*   **`ios/Runner/Info.plist`**: iOS app manifest (permissions, bundle ID).
*   **`ios/Runner/AppDelegate.swift`**: iOS application delegate.
*   **`ios/Runner/GoogleService-Info.plist`**: (Expected, though not explicitly in snapshot, but `firebase.json` implies its generation for iOS).

### Assets (`assets/`)

*   `images/`: App icons, logos, SVG body models (`male_front.svg`, `male_back.svg`, etc.).
*   `fonts/`: Custom fonts (`Inter`, `IBMPlexMono`).
*   `animations/`: Lottie animation files (e.g., `trophy_animation.json`).

## Core Logic & Architecture

### State Management (BLoC/Cubit)

The application uses the BLoC (Business Logic Component) pattern, specifically Cubits, for state management.
*   **Cubits** (`_cubit.dart` files) are responsible for managing the state of a feature or a part of it. They receive events (method calls) and emit new states.
*   **States** (`_state.dart` files) represent the UI state. Widgets listen to state changes and rebuild accordingly. `Equatable` is used for efficient state comparison.
*   **UI Widgets** (`_screen.dart`, `_widget.dart` files) use `BlocBuilder`, `BlocListener`, or `BlocConsumer` to interact with Cubits and react to state changes. `RepositoryProvider` and `BlocProvider` are used for dependency injection.

### Authentication Flow

1.  **`AuthGate` (`lib/auth_gate.dart`)**:
    *   Listens to `FirebaseAuth.instance.authStateChanges()`.
    *   If user is not authenticated, navigates to `LoginPage`.
    *   If user is authenticated, it uses a `_ProfileCheckGate`.
2.  **`_ProfileCheckGate`**:
    *   Takes `userId` of the authenticated user.
    *   Streams the `UserProfile` from `UserProfileRepository`.
    *   If profile stream is waiting or returns null (profile not yet synced after creation by backend function), shows a loading indicator.
    *   If profile exists:
        *   If `profileSetupComplete` is `false`, navigates to `ProfileSetupScreen`.
        *   If `profileSetupComplete` is `true`, navigates to `HomePage` (providing `UserProfileCubit`).
3.  **`LoginPage` (`lib/login_page.dart`)**:
    *   Provides UI for email/password sign-in/sign-up and Google Sign-In.
    *   Uses `FirebaseAuth` for authentication.
    *   Cloud Function (`createUserProfile` in `functions/src/index.ts`) automatically creates a basic user document in Firestore upon new Firebase Auth user creation.
4.  **`ProfileSetupScreen` (`lib/features/profile_setup/presentation/screens/profile_setup_screen.dart`)**:
    *   Allows new users to complete their profile (username, display name, gender, DOB, etc.).
    *   Uses `ProfileSetupCubit` to manage form state and save data via `UserProfileRepository`.
    *   Supports avatar image picking and upload to Firebase Storage.
    *   Upon successful save, sets `profileSetupComplete` to `true` and navigates to `HomePage`.

### Data Flow

A typical data flow for features is:

1.  **Firebase (Firestore/Storage)**: Raw data source.
2.  **Repository Implementation** (e.g., `UserProfileRepositoryImpl` in `features/profile_setup/data/repositories/`):
    *   Fetches data from Firebase.
    *   Transforms Firestore `DocumentSnapshot`s or Storage URLs into domain Entities.
3.  **Repository Interface** (e.g., `UserProfileRepository` in `core/domain/repositories/`):
    *   Abstract contract defining data operations.
4.  **Cubit** (e.g., `UserProfileCubit` in `features/profile/presentation/cubit/`):
    *   Uses the repository interface to fetch/manage data.
    *   Holds the current state of the feature.
    *   Emits new states to the UI.
5.  **UI (Screens/Widgets)**:
    *   Uses `BlocBuilder` or `BlocListener` to react to Cubit state changes and display data.
    *   Dispatches events (calls Cubit methods) based on user interactions.

### Entities

Located in `lib/core/domain/entities/`, these are plain Dart objects representing the data models:

*   `UserProfile`: User details, stats, achievements.
*   `UserRoutine`: Workout routine structure, exercises, schedule.
*   `RoutineExercise`: An exercise within a routine (ID, name snapshot, sets).
*   `WorkoutSession`: A logged workout, including start/end times, status, and logged exercises.
*   `LoggedExercise`: An exercise performed during a workout session.
*   `LoggedSet`: A single set within a `LoggedExercise` (weight, reps, RPE).
*   `PredefinedExercise`: Details of an exercise from the global library.
*   `Post`: Social feed item (standard, routine share, record claim).
*   `Comment`: A comment on a post.
*   `VoteType`: Enum for `verify`/`dispute` votes on record claims.
*   `AppNotification`: Structure for in-app notifications.
*   `LeagueInfo`: Details about a competitive league.
*   `Achievement`: Definition of an achievement/reward.

### Repositories

Interfaces in `lib/core/domain/repositories/` define contracts for data sources. Implementations in `features/.../data/repositories/` handle the actual data fetching/storage, primarily with Firebase.

## Firebase Backend Integration

### Firebase Services Used

*   **Firebase Authentication**: Manages user sign-up, sign-in (Email/Password, Google).
*   **Cloud Firestore**: NoSQL database for storing user profiles, routines, workout logs, posts, comments, notifications, leagues, predefined exercises.
*   **Firebase Storage**: Stores user-uploaded media (profile avatars via `user_avatars/`, post media via `post_media/`).
*   **Cloud Functions for Firebase**: Serverless functions (TypeScript) for backend logic triggered by Auth events, Firestore writes, or schedules.

### Cloud Functions (`functions/src/index.ts`)

These server-side functions handle logic that shouldn't be client-authoritative or requires elevated privileges.

#### Auth Triggers

*   **`createUserProfile` (v1 `onAuthUserCreate`)**:
    *   Triggered when a new Firebase Auth user is created.
    *   Creates a corresponding user document in the `users` collection in Firestore with initial default values (UID, email, XP, level, timestamps, etc.).

#### Firestore Triggers

*   **`calculateAndAwardXpAndStreak` (`onDocumentUpdated` for `users/{userId}/workoutLogs/{sessionId}`)**:
    *   Triggered when a workout log's status changes to `completed`.
    *   Calculates XP based on duration and volume.
    *   Updates user's XP, level.
    *   Calculates and updates current and longest workout streaks based on scheduled routine adherence.
    *   Awards `firstWorkout` achievement and sends a notification.
*   **`checkProfileSetupCompletionAchievements` (`onDocumentWritten` for `users/{userId}`)**:
    *   Triggered when a user document is created or updated.
    *   If `profileSetupComplete` changes from `false` to `true`, awards the `earlyBird` achievement and sends a notification.
*   **`onCommentCreated` (`onDocumentCreated` for `posts/{postId}/comments/{commentId}`)**:
    *   Increments `commentsCount` on the parent post document.
    *   Updates `updatedAt` on the parent post.
*   **`onCommentDeleted` (`onDocumentDeleted` for `posts/{postId}/comments/{commentId}`)**:
    *   Decrements `commentsCount` on the parent post document.
    *   Updates `updatedAt` on the parent post.
*   **`onPostDeleted` (`onDocumentDeleted` for `posts/{postId}`)**:
    *   Deletes all associated comments from the `posts/{postId}/comments` subcollection in batches.
    *   If the post had a `mediaUrl` in `post_media/`, deletes the corresponding file from Firebase Storage.
*   **`onRecordClaimPostCreated` (`onDocumentCreated` for `posts/{postId}`)**:
    *   If the post type is `recordClaim`, sets a `recordVerificationDeadline` (24 hours from creation) and initial `recordVerificationStatus` to `pending`.
*   **`onRecordClaimVoteCasted` (`onDocumentUpdated` for `posts/{postId}`)**:
    *   Triggered when `verificationVotes` field on a `recordClaim` post changes.
    *   If a user votes and hasn't been rewarded for voting on this post yet:
        *   Awards `XP_FOR_VOTING` (15 XP) to the voter.
        *   Adds voter's ID to `votedAndRewardedUserIds` on the post.
        *   Sends a system notification to the voter about the XP reward.
*   **`handleUserFollowListUpdate` (`onDocumentWritten` for `users/{userId}`)**:
    *   Triggered when a user's document (specifically their `following` array) is updated.
    *   If a user A starts following user B:
        *   Increments `followersCount` on user B's profile.
        *   Sends a `newFollower` notification to user B.
    *   If user A unfollows user B:
        *   Decrements `followersCount` on user B's profile.
    *   Updates `followingCount` on user A's profile based on the new length of their `following` array.

#### Scheduled Functions

*   **`processRecordClaimDeadlines` (v2 `onSchedule`, every 1 hour)**:
    *   Queries for `recordClaim` posts where `recordVerificationStatus` is `pending` and `recordVerificationDeadline` has passed.
    *   For each such post:
        *   Calculates vote counts (verify vs. dispute).
        *   If `verifyRatio >= MIN_VOTE_PERCENTAGE_FOR_VERIFICATION` (0.55):
            *   Sets status to `verified`.
            *   Awards `XP_FOR_RECORD_BASE` + volume-based XP to the post author.
            *   Awards `personalRecordSet` achievement to the author.
            *   Sends "Record Verified!" and "Achievement Unlocked" notifications to the author.
        *   Else if total votes > 0:
            *   Sets status to `rejected`.
            *   Sends "Record Claim Denied" notification to the author.
        *   Else (no votes):
            *   Sets status to `expired`.
            *   Sends "Record Claim Expired" notification to the author.
        *   Updates `isRecordVerified` and `updatedAt` on the post.

### Firestore Database Structure (Inferred)

*   **`users/{userId}`**: Stores `UserProfile` data.
    *   `notifications/{notificationId}`: Subcollection for `AppNotification`.
    *   `workoutLogs/{sessionId}`: Subcollection for `WorkoutSession`.
*   **`predefinedExercises/{exerciseId}`**: Stores `PredefinedExercise` data.
*   **`userRoutines/{routineId}`**: Stores `UserRoutine` data.
*   **`posts/{postId}`**: Stores `Post` data.
    *   `comments/{commentId}`: Subcollection for `Comment`.
*   **`leagues/{leagueId}`**: Stores `LeagueInfo` data.

### Firebase Storage Structure

*   **`user_avatars/{userId}.jpg`**: Stores user profile pictures.
*   **`post_media/{userId}/{postId}.jpg`**: Stores media attached to posts.

## Detailed Feature Breakdown

### User Authentication

*   **Screens**: `LoginPage` (`login_page.dart`), `AuthGate` (`auth_gate.dart`).
*   **Logic**: Uses `FirebaseAuth` for email/password and Google Sign-In. `AuthGate` manages routing based on auth state.
*   **Backend**: Firebase Authentication. `createUserProfile` Cloud Function initializes Firestore user document.

### Profile Setup

*   **Screen**: `ProfileSetupScreen` (`features/profile_setup/presentation/screens/profile_setup_screen.dart`).
*   **Cubit**: `ProfileSetupCubit`.
*   **Logic**: Collects initial user details (username, display name, DOB, gender, fitness goals, activity level, avatar).
*   **Backend**: Saves data to the user's document in Firestore via `UserProfileRepository`. Avatar images are uploaded to Firebase Storage. Cloud Function `checkProfileSetupCompletionAchievements` awards `earlyBird` achievement.

### User Profile Viewing

*   **Screens**:
    *   `ProfileScreen` (`features/profile/presentation/screens/profile_screen.dart`): For the authenticated user's own profile.
    *   `ViewUserProfileScreen` (`features/social/presentation/screens/view_user_profile_screen.dart`): For viewing other users' profiles.
*   **Cubits**:
    *   `UserProfileCubit` (global, for authenticated user).
    *   `UserInteractionCubit` (for `ViewUserProfileScreen`, handles follow/unfollow logic for the viewed profile).
    *   `UserPostsFeedCubit` (for displaying posts by the user whose profile is being viewed).
*   **Logic**: Displays user information, stats (level, XP, streak, weight), achievements, and posts. Allows following/unfollowing (for other users).
*   **Backend**: Fetches data from `/users/{userId}`.

### Dashboard

*   **Screen**: `DashboardScreen` (`features/dashboard/presentation/screens/dashboard_screen.dart`).
*   **Cubits**:
    *   `DashboardStatsCubit`: Fetches and provides data for volume trend chart and adherence percentage.
    *   `UpcomingScheduleCubit`: Fetches and displays the user's workout schedule for the next 7 days.
    *   `UserProfileCubit` (global): Provides user's name, streak for display.
    *   `NotificationsCubit` (global): Provides recent notifications.
*   **Logic**: Shows a welcome message, quick stats (weight, streak), volume trend chart, adherence, upcoming schedule, and recent notifications. Provides navigation to Profile and Progress screens.
*   **Backend**: Aggregates data from `users/{userId}`, `userRoutines`, and `workoutLogs`.

### Routines Management

*   **Screens**:
    *   `UserRoutinesScreen` (`features/routines/presentation/screens/user_routines_screen.dart`): Lists user's routines, allows starting a workout or creating a new routine. Can also be used in "selection mode" to pick a routine.
    *   `CreateEditRoutineScreen` (`features/routines/presentation/screens/create_edit_routine_screen.dart`): UI for creating or editing a `UserRoutine`.
*   **Cubits**:
    *   `UserRoutinesCubit`: Manages the list of user's routines.
    *   `ManageRoutineCubit`: Handles the state and logic for creating/editing a single routine.
*   **Logic**: Users can create routines with multiple exercises, set target sets, add notes, and schedule them for specific days of the week.
*   **Backend**: Stores routines in `userRoutines` collection.

### Workout Tracking

*   **Screens**:
    *   `ActiveWorkoutScreen` (`features/workout_tracking/presentation/screens/active_workout_screen.dart`): UI for an ongoing workout. Displays current exercise/set, allows inputting weight/reps, RPE per rep.
    *   `WorkoutCompleteScreen` (`features/workout_tracking/presentation/screens/workout_complete_screen.dart`): Summary screen shown after completing a workout, displaying XP gained, level up animations.
*   **Cubit**: `ActiveWorkoutCubit`.
*   **Logic**:
    *   Starts a new `WorkoutSession` (optionally based on a `UserRoutine`).
    *   Tracks duration.
    *   Allows users to log `LoggedSet` data (weight, reps, RPE via notes like "RPE_DATA:7,8,9").
    *   Handles completion or cancellation of workouts.
*   **Backend**:
    *   Stores workout sessions in `users/{userId}/workoutLogs`.
    *   `calculateAndAwardXpAndStreak` Cloud Function processes completed workouts.

### Exercise Explorer

*   **Screen**: `ExerciseExplorerScreen` (`features/exercise_explorer/presentation/screens/exercise_explorer_screen.dart`).
*   **Cubit**: `ExerciseExplorerCubit`.
*   **Logic**: Displays a list of `PredefinedExercise`s. Can be used for browsing or selecting an exercise to add to a routine or log a record claim.
*   **Backend**: Fetches data from `predefinedExercises` collection.

### Social Feed (Explore)

*   **Screen**: `ExploreScreen` (`features/social/presentation/screens/explore_screen.dart`). (Replaced old Exercise Explorer tab).
*   **Cubit**: `ExploreFeedCubit`.
*   **Logic**: Displays a feed of all public posts (standard, routine shares, record claims) in reverse chronological order. Allows pull-to-refresh.
*   **Backend**: Streams posts from the `posts` collection.

### Post Creation & Interaction

*   **Screens**:
    *   `CreatePostScreen` (`features/social/presentation/screens/create_post_screen.dart`): UI for creating/editing posts. Supports text, image upload, routine sharing, and record claims.
    *   `PostDetailScreen` (`features/social/presentation/screens/post_detail_screen.dart`): Displays a single post with its comments.
*   **Cubits**:
    *   `CreatePostCubit`: Manages state for post creation/editing.
    *   `PostInteractionCubit`: Manages state for a single post (likes, comments, votes, editing, deletion).
*   **Widgets**: `PostListItem`, `CommentListItem`, `PostCardContentWidget`.
*   **Logic**:
    *   Users can create standard posts with text and/or image.
    *   Share routines as posts.
    *   Submit record claims as posts.
    *   Like/unlike posts.
    *   Add, edit, delete comments on posts (if enabled by author).
    *   Authors can edit/delete their posts and toggle comment enabling.
*   **Backend**:
    *   Posts stored in `posts` collection.
    *   Comments in `posts/{postId}/comments` subcollection.
    *   Media uploaded to Firebase Storage (`post_media/`).
    *   Cloud Functions handle `commentsCount` updates and media deletion on post delete.

### Record Claims & Voting

*   **Part of**: `CreatePostScreen`, `PostCardContentWidget`, `PostDetailScreen`.
*   **Cubit**: `PostInteractionCubit` (handles vote casting).
*   **Logic**:
    *   Users create `recordClaim` type posts with exercise details (name, weight, reps, optional video URL).
    *   Other users can vote to `verify` or `dispute` the claim.
    *   Visual progress bar shows vote distribution.
    *   Users cannot vote on their own claims.
*   **Backend**:
    *   `onRecordClaimPostCreated` function sets a 24-hour voting deadline.
    *   `onRecordClaimVoteCasted` function awards XP to voters.
    *   `processRecordClaimDeadlines` scheduled function evaluates votes after deadline, updates post status, awards XP/achievements to claim author if verified.

### Following System

*   **Screens**: `ViewUserProfileScreen`, `FollowListScreen`.
*   **Cubits**: `UserInteractionCubit` (for follow/unfollow actions on a viewed profile), `FollowListCubit` (for displaying follower/following lists).
*   **Logic**: Users can follow and unfollow other users. Profile screens display follower/following counts.
*   **Backend**:
    *   `UserProfile.following` array stores IDs of users the current user is following.
    *   `handleUserFollowListUpdate` Cloud Function updates `followersCount` on the target user's profile and `followingCount` on the current user's profile, and sends a `newFollower` notification.

### Progress Tracking & Leagues

*   **Screen**: `ProgressScreen` (`features/progress/presentation/screens/progress_screen.dart`).
*   **Cubits**: `ProgressCubit`.
*   **Widgets**: `LeagueTitleWidget`, `XPProgressBarWidget`, `MuscleMapWidget`, `ValueSparkline`.
*   **Logic**:
    *   Displays current level, XP progress to next level.
    *   Shows current league and allows navigation to `LeagueScreen`.
    *   Visualizes workout volume per muscle group (sets) for the last 7 days on an SVG muscle map.
    *   Shows RPE trend (avg RPE per exercise over last N workouts).
    *   Shows working weight trend (avg weight per exercise over last N workouts).
    *   Displays recent "Advice" type notifications.
*   **Backend**:
    *   XP, level, streaks are updated by `calculateAndAwardXpAndStreak` Cloud Function.
    *   League data fetched from `leagues` collection. Leaderboards fetched by querying `users` collection based on league criteria (level, XP).

### Notifications

*   **Part of**: `DashboardScreen`, `NotificationDetailScreen`.
*   **Cubit**: `NotificationsCubit` (global, provided in `HomePage`).
*   **Widgets**: `NotificationListItem`.
*   **Logic**:
    *   Fetches and displays user-specific notifications (achievements, new followers, system messages, advice, etc.).
    *   Shows unread count.
    *   Allows marking as read or deleting notifications.
    *   Real-time updates for new notifications.
    *   Special pop-up alerts for new achievements and advice.
*   **Backend**: Notifications stored in `users/{userId}/notifications`. Cloud Functions create most notifications.

### Achievements

*   **Entities**: `Achievement`, `AchievementId` enum (`lib/core/domain/entities/achievement.dart`).
*   **Logic**:
    *   Defined in `allAchievements` map.
    *   Conditions checked/awarded by Cloud Functions (e.g., `earlyBird`, `firstWorkout`, `personalRecordSet`).
    *   `achievedRewardIds` array in `UserProfile` stores IDs of unlocked achievements.
    *   Displayed on the user's `ProfileScreen`.

## UI/UX Highlights

*   **Custom Animated Backgrounds**:
    *   `LavaLampBackground` on `LoginPage` for a visually appealing entry.
    *   `AnimatedSpotlightBackground` on `LeagueScreen` for a dynamic and engaging leaderboard view.
*   **Visual Feedback**:
    *   `Confetti` and `Lottie` (`trophy_animation.json`) animations on `WorkoutCompleteScreen` to celebrate user achievements.
    *   Animated `XPProgressBarWidget` to show progress towards the next level.
*   **Data Visualization**:
    *   `MuscleMapWidget`: Dynamically colors SVG body parts based on workout volume, providing a quick overview of muscle engagement.
    *   `VolumeTrendChartWidget` (on Dashboard): Shows recent workout volume trends with a gradient line.
    *   `ValueSparkline` (on ProgressScreen): Compact line charts for RPE and weight trends per exercise.
*   **Theming**: Consistent Material 3 theming with a primary orange accent, custom fonts (`Inter`, `IBMPlexMono`), and styled components (buttons, cards, input fields).
*   **User Experience**:
    *   Pull-to-refresh on lists.
    *   Loading indicators and error messages.
    *   Intuitive navigation with `BottomNavigationBar` and context-specific actions.
    *   Dialogs for confirmations (delete, logout) and input (edit comment, set weight).

## Setup & Running the Project

1.  **Prerequisites**:
    *   Flutter SDK installed (version compatible with `^3.8.0` Dart SDK).
    *   Firebase CLI installed and configured.
    *   A Firebase project created with Authentication, Firestore, and Storage enabled.
2.  **Firebase Configuration**:
    *   Place your Android `google-services.json` in `android/app/`.
    *   Place your iOS `GoogleService-Info.plist` in `ios/Runner/`.
    *   Ensure the Firebase project ID in `.firebaserc` (`muscle-up-8c275`) matches your project.
3.  **Flutter Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Firebase Functions Deployment**:
    *   Navigate to the `functions/` directory.
    *   Install Node.js dependencies: `npm install`
    *   Build TypeScript: `npm run build`
    *   Deploy functions: `firebase deploy --only functions` (or use `npm run deploy`)
5.  **Run the App**:
    ```bash
    flutter run
    ```
    Select a connected device or emulator.

## Potential Future Enhancements

*   **Dark Mode**: Full dark mode support based on system settings or user preference.
*   **Offline Support**: Cache data for offline access.
*   **Detailed Exercise Instructions/Videos**: Integrate or allow users to add more detailed exercise guides.
*   **Advanced Analytics**: More in-depth charts and progress reports.
*   **Workout Planning**: Calendar view for planning future workouts.
*   **Social Features**: Direct messaging, user groups, challenges.
*   **Wearable Integration**: Sync workouts from fitness trackers.
*   **Localization**: Support for multiple languages.
*   **Admin Panel**: For managing predefined exercises, users, and content.