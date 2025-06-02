# MuscleUP: Next-Gen Fitness Application

Motto: Level Up Your Lifts, Connect Your Crew, Achieve Your Goals. Build Your Strength, Together.

1. Introduction

MuscleUP is an innovative mobile fitness application designed to revolutionize your approach to training. Our mission is to create a highly motivating, socially interactive, and gamified environment that not only helps users achieve their fitness goals but also makes the process enjoyable, fostering long-term engagement. MuscleUP enables detailed workout tracking, personalized goal setting, progress analysis through unique metrics (like RPE for each repetition), and community support by sharing achievements.

This document provides a comprehensive overview of the MuscleUP project, including its current features, core business logic, software architecture, backend design with Firebase, and detailed functionality of its components. It emphasizes modularity, scalability, and maintainability.

2. Current Project Status (Version 0.3.x - Progress Tracking Update)

MuscleUP has evolved significantly, incorporating a robust set of core features and recently introducing a comprehensive Progress Tracking module.

Key Implemented Features:

Authentication & User Profile:

Secure Email/Password and Google Sign-In.

Automated initial profile creation in Cloud Firestore (`profileSetupComplete: false`) via `createUserProfile` Firebase Function.

Dedicated `ProfileSetupScreen` for detailed user information (username, gender, DOB, height, weight, goals, activity level).

Real-time user profile updates via `UserProfileCubit`.

Automatic "Early Bird" achievement award upon profile setup completion, managed by `checkProfileSetupCompletionAchievements` Firebase Function.

Main Navigation & Dashboard (`HomePage` & `DashboardScreen`):

Central AppBar with dynamic titles ("MuscleUP | Screen Name").

BottomNavigationBar for navigation: Routines, Explore, Progress, Profile.

"START WORKOUT" FloatingActionButton on the `DashboardScreen`:
    *   Checks for an active (in-progress) `WorkoutSession`. If found, navigates to `ActiveWorkoutScreen` to resume it.
    *   If no active session:
        *   If user has existing routines, navigates to the "ROUTINES" tab (`UserRoutinesScreen`).
        *   If no routines exist, navigates directly to `CreateEditRoutineScreen`.
        *   If a new routine is created from `CreateEditRoutineScreen` (when prompted by FAB), navigates to the "ROUTINES" tab.

Dashboard: Personalized greeting, workout streak icon (clickable to go to Progress screen), basic stats cards, and an interactive Notifications Section with unread count, swipe-to-delete, detail view (`NotificationDetailScreen`), and "Read All" functionality.

Exercise Library (`ExerciseExplorerScreen`):

Browse standardized exercises from Firestore (populated by `seedPredefinedExercises` Firebase Function).

Selection mode for adding exercises to routines.

Powered by `ExerciseExplorerCubit`.

Workout Routine Management (`features/routines`):

`UserRoutinesScreen`: View, create, edit, and delete custom routines.

`CreateEditRoutineScreen`: Define routine name, description, schedule (days of the week), and add exercises.

Exercises are added via `AddExerciseToRoutineDialog`, allowing configuration of sets and notes per exercise.

State managed by `UserRoutinesCubit` (for list display) and `ManageRoutineCubit` (for creation/editing).

Workout Tracking (`ActiveWorkoutScreen`):

Start workouts from routines (via `UserRoutinesScreen`) or as empty sessions (implicitly when no active session and no routines, leading to `CreateEditRoutineScreen` first).

Auto-resume incomplete sessions by fetching active session data.

`CurrentSetDisplay`:
    *   Log weight (kg) and number of repetitions for each set.
    *   Unique RPE (Rate of Perceived Exertion) Sliders: After setting reps, a corresponding number of vertical sliders (0-10 scale) appear, allowing users to rate the perceived difficulty of each individual repetition. RPE data is stored in `LoggedSet.notes` as "RPE_DATA:val1,val2,...".

Navigate between sets/exercises, confirm finish/cancel actions.

Managed by `ActiveWorkoutCubit`.

Workout Completion (`WorkoutCompleteScreen`):

Celebratory screen featuring a Lottie trophy animation (`assets/animations/trophy_animation.json`) and a `ConfettiWidget` effect.

Displays workout summary: routine name (if applicable), duration, and total volume (from the completed `WorkoutSession`).

XP & Level Up System:
    *   Shows XP gained for the workout (estimated by `ActiveWorkoutCubit`).
    *   Animates XP progression towards the next level on a progress bar.
    *   Displays level-up information if the user advanced a level, based on the updated `UserProfile` data (fetched after the `calculateAndAwardXpAndStreak` Firebase Function processes the workout).

Automatic "First Workout" achievement award, managed by the `calculateAndAwardXpAndStreak` Firebase Function.

NEW: Progress Tracking Screen (`ProgressScreen`):

Purpose: Provides users with a visual and statistical overview of their fitness journey, highlighting achievements, training focus, and strength progression to enhance motivation and inform training decisions.

`ProgressCubit`: Orchestrates data fetching from `UserProfileRepository`, `LeagueRepository`, `WorkoutLogRepository`, and `PredefinedExerciseRepository`. It processes raw workout data to calculate derived statistics and subscribes to `UserProfile` updates for real-time XP/level changes.

League System:
    *   `LeagueInfo` entities (from `leagues` Firestore collection) define fitness leagues (e.g., "BEGINNER LEAGUE", "BRONZE LEAGUE") with `minLevel`, `maxLevel`, `minXp`, `maxXp`, name, and `gradientColors`.
    *   `LeagueTitleWidget` displays the user's current league name with its custom gradient and their current level number.

XP & Level Progress:
    *   `XPProgressBarWidget` provides an animated visualization of XP progress within the current level, showing XP earned and XP remaining for the next level. Values (`xpForCurrentLevelStart`, `xpForNextLevelTotal`) are calculated by `ProgressCubit` consistent with Firebase Function logic.

Muscle Map Visualization (`MuscleMapWidget`):
    *   Uses `flutter_svg` to render gender-specific front and back body SVGs (e.g., `assets/images/female_front.svg`). SVGs contain `<g>` elements tagged with muscle ID attributes (e.g., `id="chest"`).
    *   `ProgressCubit` calculates `volumePerMuscleGroup7Days` (map of SVG muscle ID to total number of *completed sets* for that muscle group over the last 7 days).
    *   `MuscleMapWidget` dynamically colors SVG paths: color intensity (interpolated between `baseColor`, `midColor`, and `maxColor` based on `midThreshold` and `maxThreshold`) reflects training volume.

Training Statistics:
    *   Average RPE per Exercise (Last 30 Days): Calculated by `ProgressCubit` from "RPE_DATA:..." strings in `LoggedSet.notes`.
    *   Working Weight Trend per Exercise (Last N Workouts): `ProgressCubit` calculates and `ValueSparkline` widget displays the trend of average working weight for each distinct exercise over the last ~15 workouts where it was performed.
    *   RPE Trend per Exercise (Last N Workouts): `ProgressCubit` calculates and `ValueSparkline` widget displays the trend of average RPE for each distinct exercise over the last ~15 workouts.
    *   Exercise names for statistics are retrieved using `PredefinedExerciseRepository`.

Data Refresh: Includes a `RefreshIndicator` for users to manually pull and refresh all progress data.

Notification System (`features/notifications`):

`AppNotification` model (with `id`, `type`, `title`, `message`, `timestamp`, `isRead`, `relatedEntityId`, `relatedEntityType`, `iconName`) and `NotificationType` enum (including `achievementUnlocked`, `workoutReminder`, `systemMessage`, `advice`).

`NotificationRepository` for Firestore interaction with `users/{userId}/notifications` subcollection.

`NotificationsCubit` manages notification state, real-time updates, unread count, and includes an `achievementAlertController` (for immediate SnackBar alerts for new achievements) and an `adviceAlertController` (for new advice alerts).

Firebase Cloud Functions (TypeScript, Node.js v20):

`createUserProfile` (Auth v1 Trigger): Creates Firestore user profile document on new Firebase Auth user.

`calculateAndAwardXpAndStreak` (Firestore v2 Trigger): Processes completed workouts. Awards XP (base 50 + (totalVolume / 100) + (durationSeconds / 300), capped at 200 XP). Updates user's level (iterative calculation based on XP needed for each level), streak, and awards "First Workout" achievement.

`checkProfileSetupCompletionAchievements` (Firestore v2 Trigger): Awards "Early Bird" achievement on profile setup completion.

`seedPredefinedExercises` (HTTPS v2 Trigger): Populates the `predefinedExercises` collection (optionally key-protected).

Achievements System:

`AchievementId` enum and `Achievement` entity (see `lib/core/domain/entities/achievement.dart`).
Achievements like "Early Bird" and "First Workout" are awarded by Firebase Functions. Awarded IDs are stored in `achievedRewardIds` list in `UserProfile`.
Displayed on `ProfileScreen`.

3. Core Architectural Principles

The project adheres to modern software development best practices:

Modularity (Feature-First): Functionality is organized into self-contained feature modules within `lib/features/`, promoting separation of concerns and easier maintenance.

Clean Architecture (Layered Approach): Each feature, and the app globally, attempts to follow a layered structure (Presentation, Domain, Data) to decouple business logic from UI and data sources.

State Management (BLoC/Cubit): `flutter_bloc` is extensively used for managing UI state and business logic, ensuring predictability, testability, and a clear flow of data.

Dependency Injection: `RepositoryProvider` and `BlocProvider` from `flutter_bloc` are used to provide dependencies (repositories, cubits) down the widget tree.

Data Abstraction (Repositories): Repository pattern abstracts data sources (primarily Firebase Firestore), providing a clean API to the domain and presentation layers.

Scalability: The architecture is designed for future expansion, allowing new features to be added with minimal impact on existing code.

Testability: Separation of logic facilitates unit testing for business logic (Cubits, repositories) and widget testing for UI components.

4. Technology Stack

Frontend:

Framework: Flutter (Dart SDK `^3.8.0`)

Programming Language: Dart

State Management: `flutter_bloc: ^9.1.1`, `bloc: ^9.0.0`

Object Equality: `equatable: ^2.0.5` (for BLoC states/events and entities)

Date/Time Formatting: `intl: ^0.19.0`

SVG Rendering: `flutter_svg: ^2.0.10+1` (for muscle maps in Progress screen)

Animations & UI Effects:

`animated_background: ^2.0.0` (for `LavaLampBackground` on `LoginPage`)

`confetti: ^0.7.0` (for celebratory effect on `WorkoutCompleteScreen`)

`lottie: ^3.1.2` (for trophy animation on `WorkoutCompleteScreen`)

Navigation: Standard Flutter Navigation (MaterialPageRoute, Navigator.push/pop/pushAndRemoveUntil).

Backend (Firebase):

Core: `firebase_core: ^3.13.1`

Authentication: `firebase_auth: ^5.5.4` (Email/Password, Google Sign-In)

Google Sign-In Helper: `google_sign_in: ^6.2.1`

Database: `cloud_firestore: ^5.6.8` (NoSQL database for user profiles, routines, exercises, notifications, workout logs, leagues)

Serverless Logic: Firebase Cloud Functions (TypeScript, Node.js v20, `firebase-functions: ^6.0.1`, `firebase-admin: ^12.6.0` in `functions/package.json`)

Development Tools:

Linting: `flutter_lints: ^5.0.0`

App Icon Generation: `flutter_launcher_icons: ^0.13.1`

Project Snapshots: Custom Python script (`create_snapshot.py`)

5. Project Structure

The project follows a "feature-first" directory structure, promoting modularity and separation of concerns.


muscle_up/
├── android/ # Android-specific platform code
├── assets/ # Application assets
│ ├── animations/
│ │ └── trophy_animation.json # Lottie animation for WorkoutCompleteScreen
│ ├── fonts/ # Custom fonts (Inter, IBMPlexMono)
│ └── images/ # Image assets (logos, icons, muscle maps)
│ ├── app_icon.png
│ ├── google_logo.png
│ ├── male_front.svg # SVG for male front muscle map
│ ├── male_back.svg # SVG for male back muscle map
│ ├── female_front.svg # SVG for female front muscle map
│ └── female_back.svg # SVG for female back muscle map
├── functions/ # Firebase Cloud Functions (TypeScript)
│ ├── src/
│ │ └── index.ts # Main Cloud Functions logic (Auth, Firestore triggers, HTTP)
│ ├── package.json # NPM dependencies for Cloud Functions
│ ├── tsconfig.json # TypeScript configuration for Functions
│ └── .eslintrc.js # ESLint configuration for Functions code quality
├── ios/ # iOS-specific platform code
├── lib/ # Main Dart application code
│ ├── auth_gate.dart # Handles auth state changes and profile setup redirection
│ ├── firebase_options.dart # Firebase configuration (generated by FlutterFire CLI)
│ ├── home_page.dart # Main screen with BottomNavigationBar, AppBar, FAB
│ ├── login_page.dart # Login/Registration screen with animated background
│ ├── main.dart # App entry point, MaterialApp, RepositoryProviders, Theme setup
│ │
│ ├── core/ # Shared core logic, domain entities, and repository interfaces
│ │ └── domain/
│ │ ├── entities/ # Plain Dart Objects representing business models
│ │ │ ├── achievement.dart # Model for achievements
│ │ │ ├── app_notification.dart # Model for in-app notifications
│ │ │ ├── league_info.dart # Model for fitness leagues
│ │ │ ├── logged_exercise.dart # Model for an exercise logged in a workout
│ │ │ ├── logged_set.dart # Model for a set logged in an exercise
│ │ │ ├── predefined_exercise.dart# Model for standardized exercises
│ │ │ ├── routine.dart # Models for UserRoutine and RoutineExercise
│ │ │ ├── user_profile.dart # Model for user profile data
│ │ │ └── workout_session.dart # Model for a workout session
│ │ └── repositories/ # Abstract interfaces for data repositories
│ │ ├── league_repository.dart # Interface for league data
│ │ ├── notification_repository.dart # Interface for notification data
│ │ ├── predefined_exercise_repository.dart # Interface for exercise library data
│ │ ├── routine_repository.dart # Interface for user routine data
│ │ ├── user_profile_repository.dart # Interface for user profile data
│ │ └── workout_log_repository.dart # Interface for workout log data
│ │
│ ├── features/ # Feature-specific modules
│ │ ├── dashboard/
│ │ │ └── presentation/screens/dashboard_screen.dart # UI for the main dashboard tab
│ │ ├── exercise_explorer/ # Feature for browsing and selecting exercises
│ │ │ ├── data/repositories/predefined_exercise_repository_impl.dart
│ │ │ └── presentation/ # Cubit, screens, and widgets
│ │ ├── notifications/ # Feature for managing and displaying notifications
│ │ │ ├── data/repositories/notification_repository_impl.dart
│ │ │ └── presentation/ # Cubit, screens, and widgets
│ │ ├── profile/ # Feature for displaying user profile
│ │ │ └── presentation/ # Cubit and screen
│ │ ├── profile_setup/ # Feature for initial user profile configuration
│ │ │ ├── data/repositories/user_profile_repository_impl.dart
│ │ │ └── presentation/ # Cubit and screen
│ │ ├── progress/ # Feature for tracking and visualizing user progress
│ │ │ ├── data/repositories/league_repository_impl.dart
│ │ │ └── presentation/
│ │ │ ├── cubit/ # Cubit and state for progress screen logic
│ │ │ │ ├── progress_cubit.dart
│ │ │ │ └── progress_state.dart
│ │ │ ├── screens/progress_screen.dart # Main UI for the progress screen
│ │ │ └── widgets/ # Reusable widgets for the progress screen
│ │ │ ├── league_title_widget.dart # Displays current league and level
│ │ │ ├── muscle_map_widget.dart # Renders and colors SVG muscle map
│ │ │ └── xp_progress_bar_widget.dart # Animated XP progress bar
│ │ ├── routines/ # Feature for managing user workout routines
│ │ │ ├── data/repositories/routine_repository_impl.dart
│ │ │ └── presentation/ # Cubits, screens, and widgets
│ │ └── workout_tracking/ # Feature for active workout tracking and completion
│ │ ├── data/repositories/workout_log_repository_impl.dart
│ │ └── presentation/ # Cubit, screens (ActiveWorkoutScreen, WorkoutCompleteScreen), widgets
│ │
│ ├── utils/ # General utility functions
│ │ └── duration_formatter.dart # Formats Duration objects
│ │
│ └── widgets/ # Common reusable widgets
│ └── lava_lamp_background.dart # Animated background for LoginPage
│
├── pubspec.yaml # Project configuration, dependencies, assets
├── README.md # This file
└── ... # Other config files (.firebaserc, firebase.json, .gitignore)

6. Deep Dive into Key Components & UX
6.1. Authentication & Profile Setup

`LoginPage`: The initial screen for unauthenticated users, featuring an attractive `LavaLampBackground`. It provides forms for Email/Password sign-in/sign-up and a "Sign in with Google" button.

`AuthGate`: This central widget listens to Firebase Auth state changes.
    *   Upon successful authentication, it streams the user's profile from Firestore via `UserProfileRepository`.
    *   It gracefully handles potential delays between Firebase Auth user creation and the Firestore document creation by the `createUserProfile` Firebase Function by displaying a loading indicator ("Finalizing account setup...").
    *   If the fetched `UserProfile` has `profileSetupComplete == false`, the user is navigated to `ProfileSetupScreen`.
    *   If `profileSetupComplete == true`, the user is navigated to `HomePage`.
    *   `AuthGate` also provides the `UserProfileCubit` to `HomePage` and its descendants.

Firebase Function `createUserProfile` (Auth v1 Trigger): Automatically triggers when a new user is created in Firebase Authentication. It creates a corresponding document in the `users` collection in Firestore, initializing default fields like `email`, `displayName` (if available from Auth provider), `xp: 0`, `level: 1`, and critically, `profileSetupComplete: false`.

`ProfileSetupScreen`: A guided form allowing users to input essential profile details: a unique `username` (mandatory), `displayName`, `gender`, `dateOfBirth`, `heightCm`, `weightKg`, `fitnessGoal`, and `activityLevel`. This screen uses `ProfileSetupCubit` to manage form state and save data. Upon successful submission, `profileSetupComplete` is set to `true` in the user's profile.

Firebase Function `checkProfileSetupCompletionAchievements` (Firestore v2 Trigger): This function monitors writes to user documents. If the `profileSetupComplete` field changes from `false` (or non-existent) to `true`, and the "Early Bird" achievement (`AchievementId.EARLY_BIRD`) hasn't been awarded yet, it adds the achievement ID to the user's `achievedRewardIds` array and creates a corresponding notification.

`UserProfileCubit`: A globally accessible Cubit (provided via `AuthGate` to `HomePage`) responsible for loading and providing `UserProfile` data from Firestore. It listens to real-time changes in the user's profile to update the UI dynamically.

6.2. Main Navigation: `HomePage` & `DashboardScreen`

`HomePage`: The central hub of the application after successful authentication and profile setup.
    *   AppBar: Displays "MuscleUP" (clickable to return to the Dashboard) alongside the title of the currently active tab (e.g., "MuscleUP | My Routines").
    *   BottomNavigationBar: Allows easy switching between:
        *   "ROUTINES": `UserRoutinesScreen`
        *   "EXPLORE": `ExerciseExplorerScreen`
        *   "PROGRESS": `ProgressScreen`
        *   "PROFILE": `ProfileScreen`
    *   FloatingActionButton ("START WORKOUT"): Located on the `DashboardScreen` tab (when `_selectedIndex = -1`). Tapping it:
        *   Checks for an active (in-progress) `WorkoutSession` via `WorkoutLogRepository`. If one exists, navigates to `ActiveWorkoutScreen` to resume it.
        *   If no active session:
            *   Checks if the user has any existing routines. If yes, it navigates to the "ROUTINES" tab (`UserRoutinesScreen`).
            *   If no routines exist, it navigates to `CreateEditRoutineScreen` to prompt routine creation. If a routine is successfully created and the user returns, they are navigated to the "ROUTINES" tab.
    *   Provides `NotificationsCubit` to its children, enabling the Dashboard to display notifications.

`DashboardScreen`: The content for the primary "MuscleUP" tab.
    *   Displays a personalized greeting and a workout streak icon. Tapping the greeting navigates to `ProfileScreen`; tapping the streak icon navigates to `ProgressScreen`.
    *   "STATS" Section: Placeholder for a "Total Volume" graph. Displays cards for "WEIGHT", "STREAK", and "ADHERENCE".
    *   "NOTIFICATIONS" Section: Dynamically lists recent notifications using `NotificationListItem`, shows an unread notifications count, and includes a "READ ALL" button. Powered by `NotificationsCubit`.

6.3. Notification System

`AppNotification` Model: Defines notification structure (ID, type, title, message, timestamp, read status, related entity, icon). `NotificationType` enum includes `achievementUnlocked`, `workoutReminder`, `systemMessage`, `advice`.

`NotificationRepositoryImpl`: Handles CRUD operations for notifications in `users/{userId}/notifications` subcollection.

`NotificationsCubit`: Manages the list of notifications, listens to Firestore changes, and updates the UI. Includes `achievementAlertController` for immediate SnackBar alerts for new achievements and `adviceAlertController` for new advice.

`NotificationListItem` & `NotificationDetailScreen`: Widgets for displaying individual notifications and their details. Supports swipe-to-delete on list items.

6.4. Exercise Library

`PredefinedExercise` Model: Standardized exercise data (name, muscle groups, equipment, description, video URL, difficulty).

`PredefinedExerciseRepositoryImpl`: Fetches exercises from the `predefinedExercises` Firestore collection.

Firebase Function `seedPredefinedExercises` (HTTPS v2 Trigger): An admin function to populate the `predefinedExercises` collection.

`ExerciseExplorerCubit` & `ExerciseExplorerScreen`: Load and display the list of exercises. Supports a selection mode for adding exercises to routines.

6.5. Workout Routine Management

`UserRoutine` & `RoutineExercise` Models: Define user-created routines and the exercises within them (sets, notes, exercise snapshot).

`RoutineRepositoryImpl`: CRUD operations for routines in `userRoutines` collection (user-specific).

`UserRoutinesCubit`: Fetches and displays the list of a user's routines.

`ManageRoutineCubit`: Manages state for creating or editing a routine.

`UserRoutinesScreen` & `CreateEditRoutineScreen`: UI for listing, creating, and editing routines. `AddExerciseToRoutineDialog` facilitates adding exercises from the library.

6.6. Workout Tracking

Entities: `WorkoutSession`, `LoggedExercise`, `LoggedSet`.
    *   `WorkoutSession`: Core entity for a training session (ID, user ID, routine ID/name, start/end times, duration, completed exercises, notes, status, total volume).
    *   `LoggedExercise`: An exercise performed within a session.
    *   `LoggedSet`: A single set performed (weight, reps, RPE data in `notes`, completion status).

`WorkoutLogRepositoryImpl`: Manages workout sessions in `users/{userId}/workoutLogs`.

`ActiveWorkoutCubit`:
    *   Manages the state of an active workout. On initialization, it subscribes to `getActiveWorkoutSessionStream` to automatically load an in-progress session if one exists.
    *   `startNewWorkout({UserRoutine? fromRoutine})`: Creates a new `WorkoutSession` in Firestore (`status: inProgress`). If a `UserRoutine` is provided, its exercise structure is copied.
    *   `updateLoggedSet(...)`: Updates `LoggedSet` details (weight, reps, RPE data) locally and syncs to Firestore.
    *   `completeWorkout()`: Sets `WorkoutSession.status` to `completed`, calculates `durationSeconds` and `totalVolume`. This Firestore update triggers the `calculateAndAwardXpAndStreak` Firebase Function. The Cubit then fetches the updated `UserProfile` to pass to `WorkoutCompleteScreen`.
    *   `cancelWorkout()`: Sets `WorkoutSession.status` to `cancelled`.
    *   Maintains an in-app timer for workout duration.

Firebase Function `calculateAndAwardXpAndStreak` (Firestore v2 Trigger):
    *   Triggers when a `WorkoutSession` document's `status` becomes `completed`.
    *   Calculates XP: base XP (50) + (totalVolume / 100) + (durationSeconds / 300), capped at 200 XP per workout.
    *   Updates the user's `UserProfile`: increments `xp`, recalculates `level` (based on an iterative formula where XP to complete level `N` is `200 + (N-1)*50`), updates `currentStreak` (resets or increments), `longestStreak`, and `lastWorkoutTimestamp`.
    *   Awards the "First Workout" achievement (`AchievementId.FIRST_WORKOUT`) if not already achieved and creates a notification.

`ActiveWorkoutScreen`:
    *   Main UI for an ongoing workout.
    *   Displays routine name/ "Active Workout", and an elapsed time timer.
    *   `CurrentSetDisplay` Widget:
        *   Displays current exercise name, set number, target sets.
        *   Input field for `weightKg` (editable via dialog) and `reps` (+/- buttons).
        *   Unique RPE Sliders: After setting reps, corresponding vertical RPE sliders (0-10 scale) appear for each rep. RPE data is compiled into "RPE_DATA:val1,val2,..." string and stored in `LoggedSet.notes`.
    *   Navigation buttons ("PREV. SET", "NEXT SET", "NEXT EXERCISE", "FINISH WORKOUT").

`WorkoutCompleteScreen`:
    *   Navigated to after successful workout completion.
    *   Features a Lottie animation (`assets/animations/trophy_animation.json`) and `ConfettiWidget` effect.
    *   Displays workout summary (routine name, duration, total volume).
    *   Shows XP gained (estimated by `ActiveWorkoutCubit`) and animates XP progression.
    *   Displays level-up information if applicable, using the `updatedUserProfile` passed from `ActiveWorkoutCubit`.

6.7. Progress Tracking (`ProgressScreen` & `ProgressCubit`)

The `ProgressScreen` offers users a multifaceted view of their fitness journey, emphasizing visual feedback and statistical insights.

Purpose: To provide users with a clear understanding of their training achievements, how their efforts are distributed across different muscle groups, and their strength progression over time. This aims to enhance motivation and inform future training decisions.

`ProgressCubit`: The core logic unit for the Progress screen.
    *   Fetches data from `UserProfileRepository` (current XP, level), `LeagueRepository` (league definitions), `WorkoutLogRepository` (historical workout data), and `PredefinedExerciseRepository` (to map exercise IDs to names and muscle groups).
    *   Subscribes to real-time updates of the `UserProfile`.
    *   Processes raw workout data to calculate derived statistics.
    *   Caches `_allLeagues` and `_allPredefinedExercises` on initialization.

League System:
    *   `LeagueInfo` entities (stored in `leagues` Firestore collection) define fitness leagues (e.g., "BEGINNER LEAGUE", "BRONZE LEAGUE", "GOLDEN LEAGUE") with `minLevel`, `maxLevel` (optional), `minXp`, `maxXp` (optional), name, `description`, and `gradientColors`.
    *   `ProgressCubit` determines the user's `currentLeague` based on `UserProfile.level`.
    *   `LeagueTitleWidget` displays the current league name with its gradient and the user's level.

XP & Leveling Progress:
    *   `XPProgressBarWidget` displays an animated progress bar showing XP accumulation within the current level and XP needed for the next level. Values (`xpForCurrentLevelStart`, `xpForNextLevelTotal`) are calculated by `ProgressCubit`.

Muscle Map Visualization (`MuscleMapWidget`):
    *   Uses `flutter_svg` to render gender-specific front and back body SVGs (e.g., `assets/images/female_front.svg`), which contain `<g>` elements with muscle `id` attributes (e.g., `id="chest"`).
    *   `ProgressCubit` calculates `volumePerMuscleGroup7Days`: a map of SVG muscle ID to the total number of *completed sets* for that muscle group from workout logs over the last 7 days.
    *   `MuscleMapWidget` dynamically colors SVG paths. Color intensity transitions from a `baseColor` through a `midColor` to a `maxColor` based on `midThreshold` and `maxThreshold` values, reflecting training volume.

Training Statistics:
    *   Average RPE per Exercise (Last 30 Days): `ProgressCubit` parses RPE data (from "RPE_DATA:..." in `LoggedSet.notes`) from workout logs and calculates the average RPE for each distinct exercise.
    *   Working Weight Trend per Exercise: `ProgressCubit` aggregates `weightKg` data for each exercise from completed sets in recent workouts (approx. last 15) and `ValueSparkline` widget displays this trend.
    *   RPE Trend per Exercise: Similarly, `ProgressCubit` calculates and `ValueSparkline` displays the trend of average RPE per exercise over recent workouts.

Data Refresh: The `ProgressScreen` uses a `RefreshIndicator` to allow users to manually trigger `ProgressCubit.refreshData()`.

6.8. Achievements System

`AchievementId` Enum & `Achievement` Entity: `AchievementId` (e.g., `EARLY_BIRD`, `FIRST_WORKOUT`) provides unique identifiers. The `Achievement` class (in `lib/core/domain/entities/achievement.dart`) stores details like name, description, `IconData`, and an optional `conditionCheckerMessage` function. A global map `allAchievements` centralizes these definitions.

Awarding Logic: Achievements are primarily awarded by Firebase Cloud Functions (`checkProfileSetupCompletionAchievements`, `calculateAndAwardXpAndStreak`).

Storage & Notifications: Awarded `AchievementId.name` (e.g., "earlyBird") is added to `achievedRewardIds` in `UserProfile`. An `AppNotification` of type `achievementUnlocked` is also created.

Display: Achieved rewards are visualized on `ProfileScreen`. `NotificationsCubit`'s `achievementAlertController` can trigger immediate SnackBars.

6.9. Quality of Life & UX Details

Animated Background: `LavaLampBackground` on `LoginPage` for a captivating first impression.

Custom Theming: Detailed Material 3 theme in `main.dart` using custom fonts (Inter, IBMPlexMono).

Intuitive Navigation: Clear set/exercise navigation in `ActiveWorkoutScreen`.

Confirmation Dialogs: For critical actions (deleting routines, canceling workouts, logout).

Visual Feedback: SnackBars for operations, loading indicators.

RPE Sliders: Unique RPE-per-repetition sliders in `CurrentSetDisplay`.

Celebratory Animations: Confetti and Lottie animations on `WorkoutCompleteScreen`.

Automatic UI Updates: Leveraging Flutter BLoC/Cubit and Firestore streams.

7. Backend: Firebase Cloud Firestore Structure

The Firestore database is organized as follows:

`users/{userId}`: User-specific data.
    *   Fields: `uid`, `email`, `displayName`, `profilePictureUrl`, `username`, `gender`, `dateOfBirth`, `heightCm`, `weightKg`, `fitnessGoal`, `activityLevel`, `xp`, `level`, `currentStreak`, `longestStreak`, `lastWorkoutTimestamp`, `followersCount`, `followingCount`, `achievedRewardIds` (List<String>), `profileSetupComplete`, `createdAt`, `updatedAt`.
    *   Subcollection `notifications/{notificationId}`: User notifications (`AppNotification` model).
    *   Subcollection `workoutLogs/{sessionId}`: Workout session data (`WorkoutSession` model).
        *   `completedExercises` (List of `LoggedExercise` objects).
        *   Each `LoggedExercise` contains `completedSets` (List of `LoggedSet` objects with RPE data in `notes`).

`predefinedExercises/{exerciseId}`: Standardized exercise library (`PredefinedExercise` model).

`userRoutines/{routineId}`: User-created workout routines (`UserRoutine` model).
    *   `exercises` (List of `RoutineExercise` objects).

`leagues/{leagueId}`: Information about fitness leagues (`LeagueInfo` model).
    *   Fields: `name`, `minLevel`, `maxLevel` (optional), `minXp`, `maxXp` (optional), `gradientColors` (List<String> hex), `description` (optional).

8. Firebase Cloud Functions Logic (`functions/src/index.ts`)

Server-side logic is handled by Firebase Cloud Functions written in TypeScript (Node.js v20 environment, default region `us-central1`):

`createUserProfile` (Auth v1 Trigger - `onCreate`):
    *   Triggered when a new user signs up via Firebase Authentication.
    *   Creates a corresponding user document in `users/{userId}` with initial profile data (`xp: 0`, `level: 1`, `profileSetupComplete: false`, etc.).

`calculateAndAwardXpAndStreak` (Firestore v2 Trigger - `onDocumentUpdated` on `users/{userId}/workoutLogs/{sessionId}`):
    *   Triggers when a `workoutLogs` document's `status` changes to `completed`.
    *   Calculates XP: base (50) + (totalVolume / 100) + (durationSeconds / 300), capped at 200 XP.
    *   Updates user's `xp`, `level` (based on an iterative formula: XP to complete level `N` is `200 + (N-1)*50`), `currentStreak`, `longestStreak`, and `lastWorkoutTimestamp`.
    *   Awards `AchievementId.FIRST_WORKOUT` if not already achieved and creates a notification.

`checkProfileSetupCompletionAchievements` (Firestore v2 Trigger - `onDocumentWritten` on `users/{userId}`):
    *   Triggers on user document creation or update.
    *   If `profileSetupComplete` changes from `false` (or non-existent) to `true`, awards `AchievementId.EARLY_BIRD` and creates a notification.

`seedPredefinedExercises` (HTTPS v2 Trigger - `onRequest`):
    *   An HTTP-callable function to populate the `predefinedExercises` collection.
    *   Optionally protected by an admin key (`APP_ADMIN_KEY` or `ADMIN_KEY` environment variable).
    *   Avoids duplicates by checking `normalizedName`.

9. Setup and Running the Project

Flutter SDK: Ensure Flutter SDK (`^3.8.0` or compatible) is installed.

Clone Repository: Clone this project to your local machine.

Firebase Project Setup:
    *   Create a new project in the Firebase Console (Project ID used in snapshot: `muscle-up-8c275`).
    *   Add Android and/or iOS apps.
        *   Android: Package Name `com.example.muscle_up`. Download `google-services.json` to `android/app/`.
        *   iOS: Bundle ID `com.example.muscleUp`. Download `GoogleService-Info.plist` to `ios/Runner/`.
    *   Authentication: Enable Email/Password and Google Sign-In methods.
    *   Cloud Firestore: Enable. Start with test rules, then secure for production (see below).
    *   Firebase Functions:
        *   Install Firebase CLI: `npm install -g firebase-tools`.
        *   Login: `firebase login`. Select project: `firebase use YOUR_PROJECT_ID`.
        *   Install dependencies: `cd functions && npm install && cd ..`
        *   (Optional) For `seedPredefinedExercises` key protection: `firebase functions:config:set app.admin_key="YOUR_SECRET_KEY"` and redeploy.
        *   Deploy functions: `firebase deploy --only functions`.

Flutter Dependencies: Run `flutter pub get` in the project root.

App Icons: (Optional) If `assets/images/app_icon.png` is changed, regenerate: `flutter pub run flutter_launcher_icons`.

Run App: `flutter run` on an emulator or device.

Seed Exercises: Call `seedPredefinedExercises` HTTPS URL (e.g., `https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net/seedPredefinedExercises?key=YOUR_SECRET_KEY` if key configured).

Example Firestore Security Rules (Update for production):
```firestore
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
    match /leagues/{leagueId} { // New rule for leagues
      allow read: if true; // Publicly readable or `if request.auth != null;`
      allow write: if false; // Admin/functions only
    }
  }
}


Future Development

MuscleUP aims to become a comprehensive social fitness platform. Future enhancements include:

Full Implementation of Screens: Complete "Posts", "Profile" details (advanced stats, activity feed).

Enhanced Social Features: User following/followers, activity feeds, comments, likes, direct messaging.

Public Records & Leaderboards: System for submitting and validating personal records, community-validated leaderboards.

Advanced Gamification: More diverse achievements, challenges, seasonal leagues, virtual rewards.

Personalized Goal Setting: More granular goal types (e.g., weight goals for specific lifts, rep max goals).

Push Notifications: Via Firebase Cloud Messaging for reminders, achievements, social interactions.

Comprehensive Testing: Unit, widget, and integration tests.

UI/UX Refinements: Based on user feedback and A/B testing.

Admin Panel: For content management (exercises, moderation).

Wearable Device Integration: Syncing data from fitness trackers.

Offline Support: Basic offline capabilities for workout logging.

Advanced Analytics: Deeper insights into training patterns, recovery, and performance trends.
